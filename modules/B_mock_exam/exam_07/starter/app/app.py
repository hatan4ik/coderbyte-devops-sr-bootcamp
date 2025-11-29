#!/usr/bin/env python3
"""SRE-instrumented web service with Prometheus metrics."""
from flask import Flask, jsonify, request
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import logging

logging.basicConfig(level='INFO', format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Prometheus metrics
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'HTTP request latency', ['method', 'endpoint'])
ERROR_COUNT = Counter('http_errors_total', 'Total HTTP errors', ['method', 'endpoint'])

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    latency = time.time() - request.start_time
    REQUEST_LATENCY.labels(method=request.method, endpoint=request.path).observe(latency)
    REQUEST_COUNT.labels(method=request.method, endpoint=request.path, status=response.status_code).inc()
    
    if response.status_code >= 400:
        ERROR_COUNT.labels(method=request.method, endpoint=request.path).inc()
    
    logger.info(f"{request.method} {request.path} {response.status_code} {latency:.3f}s")
    return response

@app.route('/healthz')
def health():
    return jsonify({"status": "healthy"}), 200

@app.route('/metrics')
def metrics():
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}

@app.route('/')
def index():
    return jsonify({"service": "sre-demo", "endpoints": ["/healthz", "/metrics"]}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
