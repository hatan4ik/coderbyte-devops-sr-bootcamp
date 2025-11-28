# DevOps Best Practices Guide

Use this as the editorial checklist for every module, exam, and lab. Defaults are production-first, secure by design, and observable.

## Containers
### Image build
- Multi-stage builds with minimal, pinned bases; use `.dockerignore`.
- Non-root user and reproducible tags; avoid cached package indexes.
- Scan images (Trivy) and sign artifacts; generate SBOM when possible.

### Runtime security
- Read-only root filesystem; drop all capabilities; seccomp `RuntimeDefault`.
- Explicit healthchecks; no privileged mode; set resource limits/requests.

## Kubernetes
### Security
- Restricted Pod Security Standards; default-deny NetworkPolicies.
- RBAC least privilege with dedicated ServiceAccounts; external secret providers.
- Enforce container securityContext (non-root, no privilege escalation, drop caps).

### Reliability and operations
- Multiple replicas with PDBs and anti-affinity; rolling updates.
- Liveness/readiness/startup probes; graceful shutdown handling.
- HPA with right-sized requests/limits; node/pod affinity where required.

## Infrastructure as Code
### Terraform
- Remote state with encryption and locking; no state or `.terraform` in git.
- Provider versions pinned; input validation; tags on all resources.
- Modules for reuse; workspaces or var files per environment; least-priv IAM.

### GitOps
- Git as source of truth; automated sync and self-heal with prune.
- Kustomize overlays per environment; RBAC on deploy permissions; audit trails.

## CI/CD
### Security gates
- SAST/SCA scans, container scans, secret detection, SBOM + signing.
- Least-priv credentials (OIDC for cloud auth); protected environments.

### Efficiency
- Dependency caching, matrix builds, parallel stages, fail-fast patterns, artifact reuse.

### Platform notes
- GitHub Actions: status checks + CODEOWNERS, reusable workflows (lint/test, terraform fmt/validate/tflint/tfsec, Trivy image scans), OIDC auth, SARIF upload, SBOM + cosign provenance for multi-arch.
- GitLab CI: lint → test → build → scan → deploy stages; protected variables/runners; manual gates for terraform apply; review apps with auto teardown; Helm deploys with rollback; compliance pipelines.
- Azure DevOps: multi-stage YAML (CI → QA → Prod) with approvals; Key Vault-backed variable groups; ACR via managed identity; AKS blue/green or canary; tfsec/Checkov gates; cosign + SBOM publishing; Defender integration.

## Observability
### Logging
- Structured JSON with correlation IDs; configurable levels; central aggregation; retention and PII redaction.

### Metrics
- Prometheus endpoints; track golden signals; dashboards with alerting; define SLIs/SLOs.

### Tracing
- Distributed tracing with context propagation; sampling strategies; performance profiling where relevant.

## Security
### Secrets and access
- No secrets in git; use secret managers; rotate regularly; audit access; encrypt in transit and at rest.
- Enforce least privilege, MFA, and time-bound access; maintain audit logs.

### Network
- Zero-trust segmentation; TLS everywhere; managed certificates; DDoS protections where applicable.

## Disaster Recovery and High Availability
- Regular, encrypted backups with tested restores and retention policies.
- Multi-AZ deployments, auto-scaling, load balancing, and documented RTO/RPO.
- Periodic failover testing and runbooks.

## Cost Optimization
- Right-size compute; use spot/preemptible where safe; auto-scaling and shutdown for non-prod.
- Storage lifecycle policies, compression/dedupe, tiering, and cleanup of unused assets.
- Cost allocation tags, budget alerts, and periodic usage reports.

## Compliance
- Map controls to CIS, PCI DSS, HIPAA, SOC 2, GDPR, ISO 27001 as applicable.
- Enforce policy-as-code checks (tfsec/OPA/Gatekeeper/Sentinel) in pipelines.
- Enable immutable audit logs with regular reviews and compliance scanning.
