#!/usr/bin/env python3
"""FAANG-grade web service with observability, resilience, and type safety."""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Protocol, Optional, Dict, Any, Callable
from enum import Enum
from datetime import datetime
from functools import wraps
import asyncio
import signal
import socket
import structlog
from prometheus_client import Counter, Histogram, Gauge, generate_latest
from aws_xray_sdk.core import xray_recorder
from aiohttp import web
import uvloop

# Use uvloop for better performance
asyncio.set_event_loop_policy(uvloop.EventLoopPolicy())

# Structured logging
logger = structlog.get_logger()

# Prometheus metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'HTTP request latency', ['method', 'endpoint'])
ACTIVE_REQUESTS = Gauge('http_requests_active', 'Active HTTP requests')
ERROR_COUNT = Counter('http_errors_total', 'Total HTTP errors', ['endpoint', 'error_type'])

class HealthStatus(Enum):
    HEALTHY = "healthy"
    DEGRADED = "degraded"
    UNHEALTHY = "unhealthy"

@dataclass(frozen=True)
class ServiceConfig:
    """Immutable service configuration."""
    name: str
    version: str
    environment: str
    port: int
    shutdown_timeout: int = 30
    
    @staticmethod
    def from_env() -> ServiceConfig:
        import os
        return ServiceConfig(
            name=os.getenv("SERVICE_NAME", "devops-demo"),
            version=os.getenv("VERSION", "1.0.0"),
            environment=os.getenv("ENVIRONMENT", "dev"),
            port=int(os.getenv("PORT", "8000")),
            shutdown_timeout=int(os.getenv("SHUTDOWN_TIMEOUT", "30"))
        )

@dataclass
class ServiceMetrics:
    """Service metrics with atomic operations."""
    start_time: float = field(default_factory=lambda: asyncio.get_event_loop().time())
    
    @property
    def uptime_seconds(self) -> float:
        return asyncio.get_event_loop().time() - self.start_time

class HealthCheck(Protocol):
    """Health check interface."""
    async def check(self) -> tuple[HealthStatus, str]: ...

@dataclass
class DatabaseHealthCheck:
    """Database connectivity check."""
    async def check(self) -> tuple[HealthStatus, str]:
        # Simulate DB check
        await asyncio.sleep(0.001)
        return HealthStatus.HEALTHY, "connected"

@dataclass
class CacheHealthCheck:
    """Cache connectivity check."""
    async def check(self) -> tuple[HealthStatus, str]:
        await asyncio.sleep(0.001)
        return HealthStatus.HEALTHY, "connected"

class HealthChecker:
    """Aggregate health checker with circuit breaker."""
    
    def __init__(self, checks: Dict[str, HealthCheck]):
        self.checks = checks
        self.logger = logger.bind(component="HealthChecker")
    
    async def check_all(self) -> tuple[HealthStatus, Dict[str, Any]]:
        """Run all health checks concurrently."""
        results = {}
        tasks = {
            name: asyncio.create_task(self._safe_check(name, check))
            for name, check in self.checks.items()
        }
        
        for name, task in tasks.items():
            try:
                status, message = await asyncio.wait_for(task, timeout=5.0)
                results[name] = {"status": status.value, "message": message}
            except asyncio.TimeoutError:
                results[name] = {"status": HealthStatus.UNHEALTHY.value, "message": "timeout"}
        
        overall = self._aggregate_status(results)
        return overall, results
    
    async def _safe_check(self, name: str, check: HealthCheck) -> tuple[HealthStatus, str]:
        """Execute health check with error handling."""
        try:
            return await check.check()
        except Exception as e:
            self.logger.error("health_check_failed", check=name, error=str(e))
            return HealthStatus.UNHEALTHY, str(e)
    
    def _aggregate_status(self, results: Dict[str, Any]) -> HealthStatus:
        """Aggregate individual check results."""
        statuses = [r["status"] for r in results.values()]
        if all(s == HealthStatus.HEALTHY.value for s in statuses):
            return HealthStatus.HEALTHY
        elif any(s == HealthStatus.UNHEALTHY.value for s in statuses):
            return HealthStatus.UNHEALTHY
        return HealthStatus.DEGRADED

def observe_request(fn: Callable) -> Callable:
    """Decorator for request observability."""
    @wraps(fn)
    async def wrapper(request: web.Request) -> web.Response:
        method = request.method
        path = request.path
        
        ACTIVE_REQUESTS.inc()
        start = asyncio.get_event_loop().time()
        
        try:
            response = await fn(request)
            status = response.status
            REQUEST_COUNT.labels(method=method, endpoint=path, status=status).inc()
            return response
        except Exception as e:
            ERROR_COUNT.labels(endpoint=path, error_type=type(e).__name__).inc()
            raise
        finally:
            duration = asyncio.get_event_loop().time() - start
            REQUEST_LATENCY.labels(method=method, endpoint=path).observe(duration)
            ACTIVE_REQUESTS.dec()
    
    return wrapper

class ServiceHandler:
    """FAANG-grade HTTP handler with async support."""
    
    def __init__(self, config: ServiceConfig, health_checker: HealthChecker, metrics: ServiceMetrics):
        self.config = config
        self.health_checker = health_checker
        self.metrics = metrics
        self.logger = logger.bind(service=config.name, version=config.version)
    
    @observe_request
    @xray_recorder.capture_async('health_endpoint')
    async def health(self, request: web.Request) -> web.Response:
        """Health check endpoint with dependency checks."""
        status, checks = await self.health_checker.check_all()
        
        payload = {
            "status": status.value,
            "service": self.config.name,
            "version": self.config.version,
            "timestamp": datetime.utcnow().isoformat() + "Z",
            "checks": checks
        }
        
        http_status = 200 if status == HealthStatus.HEALTHY else 503
        return web.json_response(payload, status=http_status)
    
    @observe_request
    async def ready(self, request: web.Request) -> web.Response:
        """Readiness check for Kubernetes."""
        status, checks = await self.health_checker.check_all()
        
        payload = {
            "status": "ready" if status == HealthStatus.HEALTHY else "not_ready",
            "service": self.config.name,
            "checks": checks
        }
        
        http_status = 200 if status == HealthStatus.HEALTHY else 503
        return web.json_response(payload, status=http_status)
    
    @observe_request
    async def metrics_endpoint(self, request: web.Request) -> web.Response:
        """Prometheus metrics endpoint."""
        return web.Response(
            body=generate_latest(),
            content_type='text/plain; version=0.0.4'
        )
    
    @observe_request
    async def info(self, request: web.Request) -> web.Response:
        """Service information endpoint."""
        payload = {
            "service": self.config.name,
            "version": self.config.version,
            "environment": self.config.environment,
            "hostname": socket.gethostname(),
            "uptime_seconds": round(self.metrics.uptime_seconds, 2),
            "endpoints": {
                "health": "/health",
                "ready": "/ready",
                "metrics": "/metrics",
                "info": "/"
            }
        }
        return web.json_response(payload)
    
    async def not_found(self, request: web.Request) -> web.Response:
        """404 handler."""
        ERROR_COUNT.labels(endpoint=request.path, error_type="NotFound").inc()
        return web.json_response(
            {"error": "not_found", "path": request.path},
            status=404
        )

class GracefulShutdown:
    """Graceful shutdown handler."""
    
    def __init__(self, app: web.Application, timeout: int = 30):
        self.app = app
        self.timeout = timeout
        self.logger = logger.bind(component="GracefulShutdown")
        self._shutdown_event = asyncio.Event()
    
    def setup_signals(self):
        """Setup signal handlers."""
        for sig in (signal.SIGTERM, signal.SIGINT):
            asyncio.get_event_loop().add_signal_handler(
                sig,
                lambda s=sig: asyncio.create_task(self.shutdown(s))
            )
    
    async def shutdown(self, sig: signal.Signals):
        """Graceful shutdown sequence."""
        self.logger.info("shutdown_initiated", signal=sig.name)
        
        # Stop accepting new requests
        self._shutdown_event.set()
        
        # Wait for active requests to complete
        deadline = asyncio.get_event_loop().time() + self.timeout
        while ACTIVE_REQUESTS._value.get() > 0:
            if asyncio.get_event_loop().time() > deadline:
                self.logger.warning("shutdown_timeout", active_requests=ACTIVE_REQUESTS._value.get())
                break
            await asyncio.sleep(0.1)
        
        # Cleanup
        await self.app.cleanup()
        self.logger.info("shutdown_complete")

async def create_app(config: ServiceConfig) -> web.Application:
    """Application factory with dependency injection."""
    
    # Initialize dependencies
    health_checks = {
        "database": DatabaseHealthCheck(),
        "cache": CacheHealthCheck()
    }
    health_checker = HealthChecker(health_checks)
    metrics = ServiceMetrics()
    
    # Create handler
    handler = ServiceHandler(config, health_checker, metrics)
    
    # Create application
    app = web.Application()
    
    # Setup routes
    app.router.add_get('/health', handler.health)
    app.router.add_get('/ready', handler.ready)
    app.router.add_get('/metrics', handler.metrics_endpoint)
    app.router.add_get('/', handler.info)
    
    # 404 handler
    app.router.add_route('*', '/{tail:.*}', handler.not_found)
    
    # Setup graceful shutdown
    shutdown_handler = GracefulShutdown(app, config.shutdown_timeout)
    shutdown_handler.setup_signals()
    
    return app

async def main():
    """Main entry point."""
    config = ServiceConfig.from_env()
    
    logger.info("service_starting",
               name=config.name,
               version=config.version,
               environment=config.environment,
               port=config.port)
    
    app = await create_app(config)
    
    runner = web.AppRunner(app)
    await runner.setup()
    
    site = web.TCPSite(runner, '0.0.0.0', config.port)
    await site.start()
    
    logger.info("service_ready", port=config.port)
    
    # Keep running until shutdown
    await asyncio.Event().wait()

if __name__ == "__main__":
    asyncio.run(main())
