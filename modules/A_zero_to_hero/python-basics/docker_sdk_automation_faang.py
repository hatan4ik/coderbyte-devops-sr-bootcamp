#!/usr/bin/env python3
"""FAANG-Grade Docker SDK Automation with Result Monad and Metrics"""

import asyncio
import json
import sys
from dataclasses import dataclass
from typing import Optional, Protocol

import docker
import structlog
from prometheus_client import Counter, Gauge, generate_latest

log = structlog.get_logger()

# Metrics
containers_total = Gauge('docker_containers_total', 'Total containers', ['status'])
operations_total = Counter('docker_operations_total', 'Total operations', ['operation', 'status'])

@dataclass(frozen=True)
class Result:
    value: Optional[dict] = None
    error: Optional[str] = None
    
    @property
    def is_ok(self) -> bool:
        return self.error is None

class DockerClient(Protocol):
    def list_containers(self) -> Result: ...
    def get_stats(self, name: str) -> Result: ...

@dataclass
class FAANGDockerClient:
    timeout: int = 10
    
    def __post_init__(self):
        try:
            self.client = docker.from_env(timeout=self.timeout)
            self.client.ping()
        except Exception as e:
            log.error("docker_connection_failed", error=str(e))
            raise
    
    def list_containers(self) -> Result:
        try:
            containers = self.client.containers.list(all=True)
            
            result = []
            status_counts = {'running': 0, 'exited': 0, 'paused': 0}
            
            for c in containers:
                status = c.status
                status_counts[status] = status_counts.get(status, 0) + 1
                
                result.append({
                    'id': c.id[:12],
                    'name': c.name,
                    'image': c.image.tags[0] if c.image.tags else c.image.id[:12],
                    'status': status,
                    'created': c.attrs['Created']
                })
            
            for status, count in status_counts.items():
                containers_total.labels(status=status).set(count)
            
            operations_total.labels(operation='list', status='success').inc()
            log.info("containers_listed", count=len(result))
            
            return Result(value={'containers': result, 'total': len(result)})
        except Exception as e:
            operations_total.labels(operation='list', status='error').inc()
            log.error("list_containers_failed", error=str(e))
            return Result(error=str(e))
    
    def get_stats(self, name: str) -> Result:
        try:
            container = self.client.containers.get(name)
            stats = container.stats(stream=False)
            
            cpu_delta = stats['cpu_stats']['cpu_usage']['total_usage'] - \
                       stats['precpu_stats']['cpu_usage']['total_usage']
            system_delta = stats['cpu_stats']['system_cpu_usage'] - \
                          stats['precpu_stats']['system_cpu_usage']
            cpu_percent = (cpu_delta / system_delta) * 100.0 if system_delta > 0 else 0.0
            
            memory_usage = stats['memory_stats']['usage']
            memory_limit = stats['memory_stats']['limit']
            memory_percent = (memory_usage / memory_limit) * 100.0
            
            result = {
                'container': name,
                'cpu_percent': round(cpu_percent, 2),
                'memory_usage_mb': round(memory_usage / (1024**2), 1),
                'memory_limit_mb': round(memory_limit / (1024**2), 1),
                'memory_percent': round(memory_percent, 1),
                'network_rx_bytes': stats['networks']['eth0']['rx_bytes'] if 'networks' in stats else 0,
                'network_tx_bytes': stats['networks']['eth0']['tx_bytes'] if 'networks' in stats else 0
            }
            
            operations_total.labels(operation='stats', status='success').inc()
            log.info("container_stats", **result)
            
            return Result(value=result)
        except docker.errors.NotFound:
            operations_total.labels(operation='stats', status='error').inc()
            return Result(error=f"Container '{name}' not found")
        except Exception as e:
            operations_total.labels(operation='stats', status='error').inc()
            log.error("get_stats_failed", container=name, error=str(e))
            return Result(error=str(e))
    
    def get_metrics(self) -> str:
        return generate_latest().decode('utf-8')

def main(args: list[str]) -> int:
    if len(args) < 2:
        print("Usage: docker_sdk_automation_faang.py <command> [args]", file=sys.stderr)
        print("Commands:", file=sys.stderr)
        print("  list - List all containers", file=sys.stderr)
        print("  stats <name> - Container statistics", file=sys.stderr)
        print("  metrics - Prometheus metrics", file=sys.stderr)
        return 1
    
    try:
        client = FAANGDockerClient()
    except Exception:
        print(json.dumps({"error": "Failed to connect to Docker daemon"}))
        return 1
    
    command = args[1]
    
    if command == "list":
        result = client.list_containers()
    elif command == "stats" and len(args) > 2:
        result = client.get_stats(args[2])
    elif command == "metrics":
        print(client.get_metrics())
        return 0
    else:
        print(json.dumps({"error": "Invalid command"}), file=sys.stderr)
        return 1
    
    if result.is_ok:
        print(json.dumps(result.value, indent=2))
        return 0
    else:
        print(json.dumps({"error": result.error}), file=sys.stderr)
        return 1

if __name__ == "__main__":
    structlog.configure(
        processors=[
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer()
        ]
    )
    sys.exit(main(sys.argv))
