# Problem 4 – Multi-Tenant Cluster Guardrails

**Objective**: Define guardrails for multi-tenant Kubernetes clusters.

## Requirements
- Namespaces per team with RBAC boundaries and quota limits.
- PodSecurity/PSA configuration to enforce restricted baseline.
- NetworkPolicies for tenant isolation.
- Admission controls (OPA/Kyverno) for image policies and label/annotation standards.

## Deliverables
- Policy manifests (RBAC, quotas, NetworkPolicies, admission rules).
- README explaining how tenants onboard and how guardrails are enforced.
