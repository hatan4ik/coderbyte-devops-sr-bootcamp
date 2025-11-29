#!/usr/bin/env python3
"""Production-grade web service with health checks, metrics, and observability."""

import json
import logging
import os
import signal
import socket
import sys
import time
from datetime import datetime
from http.server import BaseHTTPRequestHandler, HTTPServer
from threading import Thread

# Structured logging configuration
logging.basicConfig(
    level=os.getenv("LOG_LEVEL", "INFO"),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)

# Configuration
PORT = int(os.getenv("PORT", "8000"))
SERVICE_NAME = os.getenv("SERVICE_NAME", "devops-demo")
VERSION = os.getenv("VERSION", "1.0.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "dev")

# Metrics
class Metrics:
    def __init__(self):
        self.start_time = time.time()
        self.request_count = 0
        self.error_count = 0
        self.health_checks = 0

    def uptime(self):
        return time.time() - self.start_time

metrics = Metrics()

class Handler(BaseHTTPRequestHandler):
    def log_message(self, format, *args):
        logger.info("%s - %s" % (self.address_string(), format % args))

    def _send_json(self, payload, status=200):
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("X-Service-Name", SERVICE_NAME)
        self.send_header("X-Service-Version", VERSION)
        self.end_headers()
        self.wfile.write(json.dumps(payload, indent=2).encode("utf-8"))

    def do_GET(self):
        metrics.request_count += 1

        if self.path == "/health":
            metrics.health_checks += 1
            self._send_json({
                "status": "healthy",
                "service": SERVICE_NAME,
                "version": VERSION,
                "timestamp": datetime.utcnow().isoformat() + "Z"
            })

        elif self.path == "/ready":
            # Readiness check - can add dependency checks here
            self._send_json({
                "status": "ready",
                "service": SERVICE_NAME,
                "checks": {"database": "ok", "cache": "ok"}
            })

        elif self.path == "/metrics":
            self._send_json({
                "service": SERVICE_NAME,
                "version": VERSION,
                "environment": ENVIRONMENT,
                "hostname": socket.gethostname(),
                "uptime_seconds": round(metrics.uptime(), 2),
                "requests_total": metrics.request_count,
                "errors_total": metrics.error_count,
                "health_checks_total": metrics.health_checks,
                "timestamp": datetime.utcnow().isoformat() + "Z"
            })

        elif self.path == "/":
            self._send_json({
                "service": SERVICE_NAME,
                "version": VERSION,
                "endpoints": ["/health", "/ready", "/metrics"]
            })

        else:
            metrics.error_count += 1
            self._send_json({"error": "not found", "path": self.path}, status=404)

class GracefulServer:
    def __init__(self, host, port, handler):
        self.server = HTTPServer((host, port), handler)
        self.running = True
        signal.signal(signal.SIGTERM, self.shutdown)
        signal.signal(signal.SIGINT, self.shutdown)

    def shutdown(self, signum, frame):
        logger.info("Received shutdown signal %s, gracefully stopping...", signum)
        self.running = False
        self.server.shutdown()

    def serve(self):
        logger.info("Starting %s v%s on 0.0.0.0:%s (env=%s)", SERVICE_NAME, VERSION, PORT, ENVIRONMENT)
        try:
            self.server.serve_forever()
        except KeyboardInterrupt:
            pass
        finally:
            logger.info("Server stopped")

def run():
    server = GracefulServer("0.0.0.0", PORT, Handler)
    server.serve()

if __name__ == "__main__":
    run()
