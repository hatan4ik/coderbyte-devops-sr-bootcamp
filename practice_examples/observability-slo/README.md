# Observability & SLO Example

Minimal Flask API with health/ready/metrics, plus sample alerting rules for error-rate and latency burn rates.

## Files
- `app.py` — Flask app with `/health`, `/ready`, `/metrics` using `prometheus_client`.
- `requirements.txt` — Flask + Prometheus client.
- `alerts.yaml` — Prometheus/Alertmanager rules: high error rate and high p95 latency (burn-rate style).

## Run locally
```bash
cd practice_examples/observability-slo
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
python app.py

# In another terminal
curl -s localhost:8000/health
curl -s localhost:8000/metrics | head
```

## Notes
- Metrics include request count, latency histogram, and error count.
- Alert rules use 5m/30m windows; adjust thresholds for your traffic profile.
