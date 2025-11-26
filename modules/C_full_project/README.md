# Module C – Full DevOps Project (Production-Grade)

Enterprise-ready end-to-end DevOps project demonstrating best practices for containerization, infrastructure as code, and Kubernetes deployment.

## Architecture

```
├── app/                    # Python web application
│   ├── app.py             # Production-grade web service
│   └── requirements.txt   # Python dependencies
├── docker/                # Container configuration
│   ├── Dockerfile         # Multi-stage, non-root, security-hardened
│   └── .dockerignore      # Optimize build context
├── terraform/             # Infrastructure as Code
│   ├── main.tf           # AWS resources with security controls
│   ├── backend.hcl       # State backend configuration
│   ├── terraform.tfvars.example
│   └── .tflint.hcl       # Linting configuration
├── k8s/                   # Kubernetes manifests
│   ├── deployment.yaml    # Production deployment with security contexts
│   ├── service.yaml       # ClusterIP service
│   ├── networkpolicy.yaml # Network security
│   ├── hpa.yaml          # Horizontal pod autoscaler
│   ├── pdb.yaml          # Pod disruption budget
│   └── kustomization.yaml # Kustomize configuration
├── tests/                 # Application tests
│   └── test_app.py       # Integration tests
├── .github/workflows/     # CI/CD pipelines
│   ├── full-project-ci.yaml   # Lint, test, build, scan
│   └── terraform-checks.yaml  # Terraform fmt/validate/tflint/tfsec
└── Makefile              # Common operations

## Features

### Application (app.py)
- ✅ Structured logging with configurable levels
- ✅ Health, readiness, and metrics endpoints
- ✅ Graceful shutdown handling (SIGTERM/SIGINT)
- ✅ Prometheus-compatible metrics
- ✅ Environment-based configuration
- ✅ Zero external dependencies

### Docker (Dockerfile)
- ✅ Multi-stage build (reduced image size)
- ✅ Non-root user (UID 1000)
- ✅ Minimal base image (python:3.11-slim)
- ✅ Security scanning ready
- ✅ Health check built-in
- ✅ Proper signal handling
- ✅ Layer caching optimization

### Terraform (main.tf)
- ✅ S3 bucket with encryption and versioning
- ✅ IAM roles with least privilege
- ✅ CloudWatch log groups
- ✅ Public access blocking
- ✅ Lifecycle policies
- ✅ Input validation
- ✅ Comprehensive outputs
- ✅ State encryption

### Kubernetes (k8s/)
- ✅ Security contexts (non-root, read-only FS)
- ✅ Resource limits and requests
- ✅ Liveness, readiness, startup probes
- ✅ Rolling update strategy
- ✅ Pod disruption budgets
- ✅ Network policies
- ✅ Horizontal pod autoscaling
- ✅ Anti-affinity rules
- ✅ Prometheus annotations

## Quick Start

### Prerequisites
```bash
# Install required tools
brew install docker kubectl terraform make

# Or use Docker Desktop
```

### Local Development

```bash
# Run application locally
make run

# Test endpoints
curl http://localhost:8000/health
curl http://localhost:8000/metrics
```

### Docker Build & Run

```bash
# Build image
make docker-build

# Run container
make docker-run

# Scan for vulnerabilities
make docker-scan

# Test container
curl http://localhost:8000/health
```

### Kubernetes Deployment

```bash
# Create namespace
kubectl create namespace devops-demo

# Deploy all resources
make k8s-deploy

# Check status
kubectl get all -n devops-demo
kubectl logs -n devops-demo -l app.kubernetes.io/name=devops-demo

# Port forward
kubectl port-forward -n devops-demo svc/devops-demo 8000:80

# Test
curl http://localhost:8000/health
```

### Terraform Infrastructure

```bash
# Initialize
make terraform-init

# Plan changes
make terraform-plan

# Apply infrastructure
make terraform-apply

# View outputs
terraform output -json
```

## CI/CD Pipeline

The GitHub Actions workflows include:

1. **Full Project CI (`full-project-ci.yaml`)**
   - Ruff/black linting
   - Pytest (with app running)
   - Docker build + Trivy image scan
   - Kustomize + kubeconform validation

2. **Terraform Checks (`terraform-checks.yaml`)**
   - Fmt/validate
   - TFLint
   - tfsec

## Security Best Practices

### Container Security
- Non-root user execution
- Read-only root filesystem
- Minimal attack surface
- No secrets in images
- Regular vulnerability scanning

### Kubernetes Security
- Pod Security Standards (restricted)
- Network policies (zero-trust)
- Resource quotas
- RBAC with least privilege
- Security contexts enforced

### Infrastructure Security
- Encrypted state storage
- IAM least privilege
- S3 public access blocked
- Versioning enabled
- Audit logging

## Monitoring & Observability

### Application Metrics
```bash
# View metrics
curl http://localhost:8000/metrics

# Response includes:
# - uptime_seconds
# - requests_total
# - errors_total
# - health_checks_total
```

### Kubernetes Monitoring
```bash
# Pod metrics
kubectl top pods -n devops-demo

# HPA status
kubectl get hpa -n devops-demo

# Events
kubectl get events -n devops-demo --sort-by='.lastTimestamp'
```

### Logs
```bash
# Application logs
kubectl logs -n devops-demo -l app.kubernetes.io/name=devops-demo --tail=100 -f

# Previous container logs
kubectl logs -n devops-demo <pod-name> --previous
```

## Testing

```bash
# Run unit tests
pytest tests/ -v

# Run with coverage
pytest tests/ --cov=app --cov-report=html

# Integration tests (requires running app)
python app/app.py &
pytest tests/test_app.py
```

## Troubleshooting

### Container Issues
```bash
# Check container logs
docker logs <container-id>

# Inspect container
docker inspect <container-id>

# Execute shell in container
docker exec -it <container-id> sh
```

### Kubernetes Issues
```bash
# Describe pod
kubectl describe pod <pod-name> -n devops-demo

# Check events
kubectl get events -n devops-demo

# Debug with ephemeral container
kubectl debug <pod-name> -n devops-demo -it --image=busybox
```

### Terraform Issues
```bash
# Validate configuration
terraform validate

# Format code
terraform fmt -recursive

# Show state
terraform show

# Refresh state
terraform refresh
```

## Production Checklist

- [ ] Image scanning in CI/CD
- [ ] Secrets management (external-secrets/sealed-secrets)
- [ ] Resource limits tuned for workload
- [ ] HPA configured with appropriate metrics
- [ ] PDB set to maintain availability
- [ ] Network policies tested
- [ ] Monitoring and alerting configured
- [ ] Backup and disaster recovery plan
- [ ] Documentation updated
- [ ] Runbooks created

## Performance Optimization

### Application
- Zero external dependencies
- Efficient HTTP handling
- Minimal memory footprint
- Fast startup time

### Container
- Multi-stage build reduces size by 60%
- Layer caching optimized
- Minimal base image
- No unnecessary packages

### Kubernetes
- Resource requests prevent overcommitment
- HPA scales based on actual load
- Anti-affinity spreads pods
- Readiness gates prevent bad deployments

## Cost Optimization

- Right-sized resource requests
- HPA prevents over-provisioning
- Spot instances compatible
- Efficient image layers
- S3 lifecycle policies

## Compliance & Governance

- Infrastructure as Code (audit trail)
- Immutable infrastructure
- Version-controlled configurations
- Automated security scanning
- Policy enforcement via OPA (optional)

## Next Steps

1. **Add observability**: Integrate Prometheus, Grafana, Jaeger
2. **Implement GitOps**: Use ArgoCD or Flux
3. **Add service mesh**: Istio or Linkerd for advanced traffic management
4. **Enhance security**: Add OPA policies, Falco runtime security
5. **Multi-region**: Deploy across regions for HA
6. **Chaos engineering**: Test resilience with Chaos Mesh

## References

- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [12-Factor App](https://12factor.net/)
