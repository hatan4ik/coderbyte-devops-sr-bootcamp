# Security Architect Problems - Sarah Chen

**Expertise**: Container security, IAM, secrets management, zero-trust  
**Mantra**: "If it's not encrypted, it's not production"

## Problems Overview

### 🟢 Easy Problems (15-20 min each)

#### Problem 01: Implement Non-Root Container
**Skills**: Docker security, user permissions  
**Time**: 15 min  
Convert root container to non-root with proper permissions.

#### Problem 02: Add Secret Management
**Skills**: Kubernetes secrets, external secrets  
**Time**: 20 min  
Replace hardcoded secrets with proper secret management.

### 🟡 Medium Problems (30-45 min each)

#### Problem 03: Implement Zero-Trust Network Policy
**Skills**: Kubernetes network policies, microsegmentation  
**Time**: 35 min  
Create network policies for zero-trust architecture.

#### Problem 04: Secure IAM with Least Privilege
**Skills**: AWS IAM, policy scoping, conditions  
**Time**: 40 min  
Fix overly permissive IAM policies.

#### Problem 05: Container Image Scanning Pipeline
**Skills**: Trivy, Syft, SBOM, vulnerability management  
**Time**: 35 min  
Build complete container security scanning pipeline.

#### Problem 06: Implement Pod Security Standards
**Skills**: PSS, admission controllers, policy enforcement  
**Time**: 40 min  
Enforce restricted pod security standards.

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
