import time
from flask import Flask, jsonify, request, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "Request latency",
    ['method', 'endpoint'],
)
REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ['method', 'endpoint', 'status']
)

@app.before_request
def start_timer():
    request._start_time = time.time()

@app.after_request
def record_metrics(response):
    elapsed = time.time() - getattr(request, "_start_time", time.time())
    endpoint = request.endpoint or "unknown"
    REQUEST_LATENCY.labels(request.method, endpoint).observe(elapsed)
    REQUEST_COUNT.labels(request.method, endpoint, response.status_code).inc()
    return response

@app.route("/healthz", methods=["GET"])
def healthz():
    return jsonify({"status": "ok"}), 200

@app.route("/hello", methods=["GET"])
def hello():
    name = request.args.get("name", "world")
    return jsonify({"message": f"hello {name}"})

@app.route("/metrics", methods=["GET"])
def metrics():
    data = generate_latest()
    return Response(data, mimetype=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
