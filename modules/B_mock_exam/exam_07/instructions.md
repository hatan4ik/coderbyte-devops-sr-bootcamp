# Mock Exam #7 – SRE & Observability

## Scenario
Instrument a web service and ship alerts/dashboards so on-call engineers can see traffic and error signals.

## Requirements
1. **App instrumentation** (in `starter/app`)
   - Expose HTTP `/metrics` for Prometheus.
   - Add request logging and track request latency and error counts.
   - Include a `/healthz` endpoint returning 200/JSON.
2. **Dashboards & Alerts** (in `starter/observability`)
   - Provide a `prometheus.yml` scrape config targeting the app.
   - Add example alert rules for high error rate and high latency (SLO-style burn rate).
   - Add a README with Grafana dashboard suggestions (panels for RPS, p95 latency, error rate).
3. **Runbook**
   - Document in `starter/README.md` how to run the app locally with metrics enabled and how to load the Prometheus config.

### Deliverables
- Instrumented app code and Dockerfile.
- Prometheus config + alert rules.
- Runbook notes.
