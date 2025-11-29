# Security Architect Problems - Sarah Chen

**Expertise**: Container security, IAM, secrets management, zero-trust  
**Mantra**: "If it's not encrypted, it's not production"

## Problems Overview (Available)

- [Problem 1: Non-Root Container](problem-1/problem.md) — Docker security, user permissions ([solution](problem-1/solution.md), [code](problem-1/solution))
- [Problem 2: Secrets Management](problem-2/problem.md) — Kubernetes secrets, external secrets ([solution](problem-2/solution.md), [code](problem-2/solution))
- [Problem 3: Zero-Trust Network Policy](problem-3/problem.md) — Kubernetes network policies, microsegmentation ([solution](problem-3/solution.md), [code](problem-3/solution))
- [Problem 4: IAM Least Privilege](problem-4/problem.md) — Scope/condition IAM policies, MFA requirements ([solution](problem-4/solution.md), [code](problem-4/solution))
- [Problem 5: Container Image Scanning Pipeline](problem-5/problem.md) — Trivy/Grype scans, SBOM with Syft ([solution](problem-5/solution.md), [code](problem-5/solution))
- [Problem 6: Pod Security Standards](problem-6/problem.md) — Enforce restricted profile via admission/PSA ([solution](problem-6/solution.md), [code](problem-6/solution))
- [Problem 7: Secrets Rotation](problem-7/problem.md) — Managed secrets with rotation Lambda ([solution](problem-7/solution.md), [code](problem-7/solution))
- [Problem 8: Zero-Trust Network Policy (Advanced)](problem-8/problem.md) — Default deny + explicit service egress/ingress ([solution](problem-8/solution.md), [code](problem-8/solution))

### 🔴 Hard Problems (60-90 min each)

#### Problem 07: Multi-Tenant Security Architecture
**Skills**: RBAC, namespaces, network policies, resource quotas  
**Time**: 75 min  
Design and implement secure multi-tenant K8s cluster.

#### Problem 08: Complete Security Audit & Remediation
**Skills**: Comprehensive security assessment, remediation  
**Time**: 90 min  
Audit entire stack and fix all vulnerabilities.

## Key Concepts Covered

### Container Security
- Non-root users
- Read-only filesystems
- Capability dropping
- Seccomp profiles
- AppArmor/SELinux

### Secrets Management
- Kubernetes secrets
- External Secrets Operator
- HashiCorp Vault
- AWS Secrets Manager
- Secret rotation

### Network Security
- Network policies
- Service mesh
- mTLS
- Ingress/egress rules
- Zero-trust architecture

### IAM & Access Control
- Least privilege
- RBAC
- Policy conditions
- Service accounts
- Workload identity

### Compliance & Scanning
- CIS benchmarks
- Trivy scanning
- Policy enforcement
- SBOM generation
- Vulnerability management

## Success Criteria

- [ ] All containers run as non-root
- [ ] No hardcoded secrets
- [ ] Network policies enforced
- [ ] IAM follows least privilege
- [ ] All scans pass
- [ ] Pod security standards enforced
- [ ] Zero HIGH/CRITICAL vulnerabilities
- [ ] Complete documentation
