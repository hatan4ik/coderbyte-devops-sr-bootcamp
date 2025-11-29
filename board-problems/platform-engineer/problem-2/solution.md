# Solution – GitOps Bootstrap

## Approach
- Bootstrap ArgoCD/Flux with a clear repo structure and promotion model.

## Steps
- Define repo layout: `apps/base`, `apps/overlays/{dev,stage,prod}` plus shared infra.
- Create ArgoCD/Flux app manifests; enable sync/drift detection; configure PR-based promotions.
- Provide onboarding guide for new services (template manifests + values).

## Validation
- Bootstrap to a test cluster; deploy a sample app; induce drift and observe reconciliation.
- Promotion from dev→stage→prod follows PR/approval flow.
