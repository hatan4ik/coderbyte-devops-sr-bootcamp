# Platform Engineer Problems - Aisha Patel

**Focus**: Kubernetes platforms, GitOps, developer self-service  
**Mantra**: "Make the right thing the easy thing."

## Available Problems
- [Problem 1: Harden Kubernetes Deployment](problem-1/problem.md) — Secure manifests, probes, resources, NetworkPolicies ([solution](problem-1/solution.md), [code](problem-1/solution))
- [Problem 2: GitOps Bootstrap](problem-2/problem.md) — ArgoCD/Flux repo structure, overlays, promotion ([solution](problem-2/solution.md), [code](problem-2/solution))
- [Problem 3: Build Self-Service Platform](problem-3/problem.md) — ArgoCD ApplicationSets, Kustomize overlays, RBAC, quotas, and self-service workflows ([solution](problem-3/solution.md), [code](problem-3/solution))
- [Problem 4: Multi-Tenant Cluster Guardrails](problem-4/problem.md) — RBAC, quotas, PodSecurity/PSA, NetworkPolicies, admission policies ([solution](problem-4/solution.md), [code](problem-4/solution))

## How to Use
- Treat Problem 03 as the reference pattern for platform enablement.
- Reuse the GitOps scaffolding (ApplicationSets, overlays) in your own clusters.
- Capture operational runbooks as you solve to speed up future platform asks.
