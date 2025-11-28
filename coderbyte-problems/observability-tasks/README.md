# Observability Tasks

Two practical problems backed by runnable labs.

1) **Add Metrics & Alerts (Easy)**  
- **Problem**: Wire Prometheus metrics and a minimal alert to an existing service.  
- **Code reference**: `practice_examples/observability-slo/` (Flask app with `/metrics`, alert rules, tests).  
- **How to run**: `cd practice_examples/observability-slo && make test` (or `pytest -q`).  

2) **Deploy Observability Stack (Medium)**  
- **Problem**: Deploy Prometheus + Alertmanager + Grafana with scrape configs for your app.  
- **Code reference**: `practice_examples/observability-stack/` (K8s manifests and dashboards).  
- **How to run**: `cd practice_examples/observability-stack && kustomize build . | kubectl apply -f -`.

Use these labs as the source for observability tasks referenced in the problem guides.
