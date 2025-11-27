# Deploy Guide (Module C)

End-to-end steps to build, scan, and deploy the full project.

## Prereqs
- Docker, kubectl, terraform, make
- Kubernetes cluster context set (namespace `devops-demo` suggested)

## Steps
1) **Build & Scan Image**
```bash
make docker-build IMAGE_TAG=dev
make docker-scan IMAGE_TAG=dev
```

2) **Terraform Infra (S3/IAM/logs)**
```bash
cd terraform
terraform init
terraform plan
terraform apply  # if permitted
```

3) **K8s Deploy**
```bash
kubectl create namespace devops-demo || true
make k8s-deploy
kubectl get deploy,svc,hpa,networkpolicy,pdb -n devops-demo
```

4) **Health Check**
```bash
kubectl port-forward -n devops-demo svc/devops-demo 8000:80
curl -s localhost:8000/health
curl -s localhost:8000/metrics | head
```

## Related Labs
- Observability stack: `practice_examples/observability-stack/`
- K8s hardening: `practice_examples/k8s-hardening/`
