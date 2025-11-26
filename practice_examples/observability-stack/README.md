# Observability Stack Wiring (K8s)

Deploy the observability demo app to Kubernetes with Prometheus scrape annotations and alert rules. Includes a sample Grafana dashboard JSON.

## Files
- `k8s/deployment.yaml` — Deploys `local/observability-slo:dev` with probes and metrics annotations.
- `k8s/service.yaml` — ClusterIP on port 80 → 8000.
- `k8s/alerts.yaml` — Prometheus alert rules (error rate, p95 latency).
- `grafana/dashboard.json` — Minimal dashboard for requests/latency/errors.
- `k8s/kustomization.yaml` — Entry for apply/validation.

## Usage
```bash
# Build/push your image or adjust the image field
kustomize build k8s | kubeconform -strict -ignore-missing-schemas
kubectl apply -k k8s

# Load alerts into Prometheus/Alertmanager
kubectl create configmap slo-alerts --from-file=k8s/alerts.yaml -n monitoring
```

Adjust namespaces/selectors to match your cluster (e.g., monitoring stack). Dashboard JSON can be imported into Grafana.
