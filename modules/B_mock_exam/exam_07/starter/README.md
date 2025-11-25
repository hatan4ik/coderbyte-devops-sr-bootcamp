# Observability Starter

## Run locally
```bash
cd app
pip install -r requirements.txt
python app.py
# in another terminal
curl -s localhost:8000/healthz
curl -s localhost:8000/metrics | head
```

## Prometheus
Use `observability/prometheus.yml` to scrape the service. Example:
```bash
prometheus --config.file=observability/prometheus.yml --web.listen-address=:9090
```
Load `observability/alerts.yml` as a rule file or wire to Alertmanager.

## Dashboard ideas
- RPS by route (`rate(http_requests_total[5m])`)
- Error rate (`sum(rate(http_requests_total{status!~"2.."}[5m])) / sum(rate(http_requests_total[5m]))`)
- p95 latency (`histogram_quantile` over `http_request_duration_seconds_bucket`)
