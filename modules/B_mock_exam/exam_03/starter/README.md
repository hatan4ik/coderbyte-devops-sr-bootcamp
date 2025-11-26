# GitOps Demo with ArgoCD & Kustomize

Production-grade GitOps deployment using Kustomize for environment overlays and ArgoCD for continuous deployment.

## Architecture

```
├── app/                    # Base Kubernetes manifests
│   ├── deployment.yaml     # Base deployment with security contexts
│   ├── service.yaml        # ClusterIP service
│   ├── networkpolicy.yaml  # Network security policy
│   ├── pdb.yaml           # Pod disruption budget
│   └── kustomization.yaml  # Base kustomization
├── overlays/
│   ├── dev/               # Development environment
│   │   ├── kustomization.yaml
│   │   └── deployment-patch.yaml
│   └── prod/              # Production environment
│       ├── kustomization.yaml
│       ├── deployment-patch.yaml
│       └── hpa.yaml       # Horizontal pod autoscaler
└── argocd/
    ├── application.yaml    # ArgoCD application
    └── appproject.yaml     # ArgoCD project for governance
```

## Features

### Security
- Non-root containers (UID 1000)
- Read-only root filesystem
- Security contexts with seccomp profiles
- Network policies for ingress/egress control
- Pod security standards compliance

### High Availability
- Pod disruption budgets
- Anti-affinity rules (in base)
- Rolling update strategy with zero downtime
- Horizontal pod autoscaling (prod)

### Observability
- Prometheus metrics annotations
- Structured logging
- Health and readiness probes
- Startup probes for slow-starting apps

## Local Development

### Prerequisites
```bash
# Install tools
brew install kustomize kubectl argocd

# Or use Docker
docker run --rm -v $(pwd):/workspace k8s.gcr.io/kustomize/kustomize:v5.0.0
```

### Build and Validate

```bash
# Build dev overlay
kustomize build overlays/dev

# Build prod overlay
kustomize build overlays/prod

# Validate manifests
kustomize build overlays/prod | kubectl apply --dry-run=client -f -

# Check differences between environments
diff <(kustomize build overlays/dev) <(kustomize build overlays/prod)
```

### Apply Locally

```bash
# Create namespace
kubectl create namespace gitops-demo-dev

# Apply dev environment
kustomize build overlays/dev | kubectl apply -f -

# Check deployment
kubectl get all -n gitops-demo-dev
kubectl logs -n gitops-demo-dev -l app=gitops-demo

# Port forward to test
kubectl port-forward -n gitops-demo-dev svc/gitops-demo 8080:8080
curl http://localhost:8080/health
```

## ArgoCD Deployment

### Install ArgoCD

```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Deploy Application

```bash
# Create AppProject (optional but recommended)
kubectl apply -f argocd/appproject.yaml

# Create Application
kubectl apply -f argocd/application.yaml

# Check sync status
argocd app get gitops-demo-prod
argocd app sync gitops-demo-prod
argocd app wait gitops-demo-prod --health
```

### ArgoCD CLI Operations

```bash
# Login
argocd login localhost:8080

# List applications
argocd app list

# Get application details
argocd app get gitops-demo-prod

# Sync application
argocd app sync gitops-demo-prod

# View diff
argocd app diff gitops-demo-prod

# Rollback
argocd app rollback gitops-demo-prod

# Delete application
argocd app delete gitops-demo-prod
```

## Environment Differences

### Development
- 1 replica
- Image tag: `dev`
- Log level: `debug`
- Namespace: `gitops-demo-dev`
- No HPA

### Production
- 3 replicas (min)
- Image tag: `stable`
- Log level: `info`
- Namespace: `gitops-demo-prod`
- HPA enabled (3-10 replicas)
- Resource limits enforced

## GitOps Workflow

1. **Developer commits code** → Triggers CI pipeline
2. **CI builds and tests** → Pushes image with tag
3. **Update manifest** → Change image tag in overlay
4. **ArgoCD detects change** → Syncs automatically
5. **Deployment rolls out** → Zero downtime update
6. **Health checks pass** → Traffic shifted to new pods

## Promotion Strategy

```bash
# Promote dev to prod
# 1. Test in dev
kustomize build overlays/dev | kubectl apply -f -

# 2. Update prod overlay image tag
cd overlays/prod
kustomize edit set image ghcr.io/example/gitops-demo:stable=ghcr.io/example/gitops-demo:v1.2.3

# 3. Commit and push
git add .
git commit -m "Promote v1.2.3 to production"
git push

# 4. ArgoCD auto-syncs (or manual sync)
argocd app sync gitops-demo-prod
```

## Troubleshooting

```bash
# Check ArgoCD application status
kubectl get application -n argocd

# View application events
kubectl describe application gitops-demo-prod -n argocd

# Check sync status
argocd app get gitops-demo-prod --refresh

# View application logs
kubectl logs -n gitops-demo-prod -l app=gitops-demo --tail=100

# Force sync
argocd app sync gitops-demo-prod --force

# Prune resources
argocd app sync gitops-demo-prod --prune
```

## Best Practices

1. **Never commit secrets** - Use sealed-secrets or external-secrets
2. **Pin image tags** - Never use `latest` in production
3. **Use AppProjects** - Enforce RBAC and resource restrictions
4. **Enable auto-sync** - With self-heal for drift detection
5. **Set resource limits** - Prevent resource exhaustion
6. **Implement health checks** - Ensure proper rollout validation
7. **Use PDB** - Maintain availability during updates
8. **Network policies** - Implement zero-trust networking

## Security Checklist

- [x] Non-root containers
- [x] Read-only root filesystem
- [x] Security contexts configured
- [x] Network policies defined
- [x] Resource limits set
- [x] No privileged containers
- [x] Capabilities dropped
- [x] Seccomp profile enabled
- [x] Pod disruption budgets
- [x] Image scanning in CI

## Monitoring

```bash
# Check pod metrics
kubectl top pods -n gitops-demo-prod

# View HPA status
kubectl get hpa -n gitops-demo-prod

# Check network policy
kubectl describe networkpolicy gitops-demo -n gitops-demo-prod

# View PDB status
kubectl get pdb -n gitops-demo-prod
```
