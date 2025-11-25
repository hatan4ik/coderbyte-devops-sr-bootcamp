# GitOps Demo Starter

## Structure
- `app/`: Base Deployment + Service.
- `overlays/dev` and `overlays/prod`: Environment-specific patches.
- `argocd/application.yaml`: ArgoCD Application pointing at the prod overlay.

## Local apply
```bash
# dev overlay
kustomize build overlays/dev | kubectl apply -f -

# prod overlay
kustomize build overlays/prod | kubectl apply -f -
```

Update `repoURL`/`path` in the ArgoCD Application to match your repository before syncing.
