# Mock Exam #1 – Reference Solution Outline

Use this as a rubric/example; adapt to your environment.

## 1) App (Python)
- Add `/health` endpoint returning `{"status":"ok"}`.
- Add basic logging for each request.

## 2) Dockerfile
- Use `python:3.11-slim`.
- Copy app + requirements; install deps with `--no-cache-dir`.
- Create non-root user; set `PYTHONDONTWRITEBYTECODE`/`PYTHONUNBUFFERED`.
- Add `HEALTHCHECK` on `/health`.

## 3) Terraform
- Define `variable "environment" {}`.
- Create an S3 bucket (or mock resource) with versioning enabled.
- Tag resources.

## 4) Kubernetes
- Deployment (2 replicas) using your image.
- Probes: liveness/readiness on `/health` port 8000.
- Security: runAsNonRoot, drop ALL caps, readOnlyRootFilesystem.
- Service exposing port 8000.

## Commands (example)
```bash
# app
python app.py

# docker
docker build -t yourrepo/exam01:dev -f starter/Dockerfile ./starter

# terraform
cd starter/terraform
terraform init -backend=false
terraform fmt -check && terraform validate && terraform plan

# k8s
kubectl apply -f starter/k8s/deployment.yaml
kubectl apply -f starter/k8s/service.yaml
kubectl rollout status deploy/devops-demo
kubectl get pods -l app=devops-demo
```

## Notes
- Keep image non-root and add `.dockerignore` for lean builds.
- Probes + resource requests help with stability during rollout.
- Use `terraform plan` output as evidence; no need to apply in exam environment unless required.
