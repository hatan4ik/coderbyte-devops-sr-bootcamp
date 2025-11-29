# Problem 03: Build Self-Service Platform 🔴

**Time**: 75 min | **Difficulty**: Hard | **Points**: 150

## Scenario
Create self-service platform for developers to deploy apps with GitOps.

## Requirements
1. ArgoCD ApplicationSet for multi-app
2. Kustomize base + overlays (dev/staging/prod)
3. Automated PR-based deployments
4. Resource quotas per environment
5. RBAC for developer access
6. Documentation

## Platform Features
- **Self-Service**: Developers create PR to deploy
- **GitOps**: ArgoCD auto-syncs from Git
- **Multi-Env**: Dev, staging, prod with different configs
- **Security**: RBAC, network policies, quotas
- **Observability**: Metrics, logs, traces

## Deliverables
```
solution/
├── argocd/
│   ├── applicationset.yaml
│   └── appproject.yaml
├── base/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── kustomization.yaml
├── overlays/
│   ├── dev/
│   ├── staging/
│   └── prod/
├── rbac/
│   ├── developer-role.yaml
│   └── developer-rolebinding.yaml
└── README.md
```

## Success Criteria
- [ ] ApplicationSet deploys to all envs
- [ ] Developers can self-serve
- [ ] RBAC enforced
- [ ] Quotas prevent overuse
- [ ] Auto-sync works
