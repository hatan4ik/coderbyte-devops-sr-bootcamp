# Helm + Policy Check Example

Run Helm lint and Conftest (OPA) against a sample chart to enforce policies (e.g., no privileged containers, labels present).

## Files
- `chart/` — Minimal Helm chart (Deployment + Service).
- `policy/helm.rego` — OPA policies for Helm-rendered manifests.
- `conftest.sh` — Render chart and run Conftest.

## Usage
```bash
cd practice_examples/helm-policy
helm lint chart
./conftest.sh
```

Adjust values/policies as needed.
