# Production Guide

Consolidated reference for production patterns, engineering standards, and best practices used across this bootcamp.

## Design Principles

### 1. Security First
- **Least Privilege**: IAM, RBAC, pipeline permissions scoped tightly; OIDC over long-lived keys
- **Defense in Depth**: NetworkPolicies, securityContext, encryption at rest/in transit
- **Zero Trust**: Default-deny networking with explicit ingress/egress
- **Secrets Management**: No hardcoded secrets; external managers only
- **Vulnerability Scanning**: Trivy/Semgrep/Gitleaks in CI; fail on HIGH/CRIT

### 2. Production Ready
- **High Availability**: Multi-replica + PDB + anti-affinity; rolling updates
- **Observability**: Structured logs, metrics, health probes, tracing hooks
- **Graceful Degradation**: Safe fallbacks + backpressure; timeouts/retries with jitter
- **Resource Management**: Requests/limits, HPA/VPA where appropriate
- **Disaster Recovery**: Backups + tested restores; rollback-first mindset

### 3. Infrastructure as Code
- **Version Control**: Everything in git; no console drift
- **Immutable Infrastructure**: Rebuild, don't mutate
- **Declarative Configuration**: Desired state > imperative commands
- **Modular Design**: Reusable modules/overlays; DRY variables and locals
- **Validation**: fmt/validate/tflint/tfsec + policy-as-code gates

### 4. DevOps Culture
- **Automation**: Pipelines for build/test/scan/deploy; no manual hotfixing
- **GitOps**: Git as source of truth; ArgoCD/Kustomize overlays
- **Collaboration**: Runbooks + module READMEs; small PRs with tests
- **Continuous Improvement**: Postmortems feed back into tests/policies
- **Shift Left**: Security and tests pre-merge

## Technology Stack

### Container Platform
- **Docker**: Multi-stage, slim, non-root; SBOM + signing ready
- **Kubernetes**: Restricted pod security, probes/limits, NetworkPolicies
- **Kustomize**: Overlays per environment
- **ArgoCD**: GitOps deployment

### Infrastructure
- **Terraform**: Remote state, locking, validation
- **AWS**: Default examples; patterns adapt to other clouds
- **CloudWatch**: Logging/metrics integration

### CI/CD
- **GitHub Actions**: Reusable templates; gating on lint/test/scan
- **Security Scans**: Trivy, Semgrep, Gitleaks baked into pipelines
- **Supply Chain**: SBOM (syft), signing (cosign), provenance

### Languages
- **Python**: App/service patterns with health/metrics
- **Bash**: Hardened scripts with `set -euo pipefail`
- **Go**: Services/tools with graceful shutdown
- **HCL**: Terraform configurations with validation and tagging

## Dependency Management
- **Poetry-first**: Install with `poetry install --sync`; run tooling/tests via `poetry run ...`.
- **Lockfile discipline**: `pyproject.toml` + `poetry.lock` are the source of truth; avoid ad-hoc `pip install` drift.
- **Base vs extras**: Base install omits AWS SDK/X-Ray. For AWS workflows, add extras: `poetry install --sync --extras aws` (or export with `--extras aws` to `requirements-aws.txt`).
- **Container builds**: Export pinned deps with `poetry export --without-hashes --format requirements.txt --output requirements.txt` (and include `--extras aws` if needed) before building Docker images that expect a `requirements.txt`.
- **Legacy compatibility**: `requirements.txt` (base) and `requirements-aws.txt` (AWS) are kept in sync via export for CI/containers that cannot run Poetry.

## Coding Standards

### Python
- Format with `black`, lint with `ruff`
- 120 char line guidance
- Type hints where practical
- Tests via `pytest`

### Shell
- `set -euo pipefail`
- Quote variables
- Prefer long-form flags
- Lint with `shellcheck`

### Docker
- Slim/non-root images
- Multi-stage builds
- Healthchecks
- Pinned bases

### YAML/JSON
- 2-space indent
- Use Kustomize for K8s
- Schema-valid manifests (kubeconform)

## Container Best Practices

### Image Build
- Multi-stage builds with minimal, pinned bases
- Use `.dockerignore`
- Non-root user and reproducible tags
- Scan images (Trivy) and sign artifacts
- Generate SBOM when possible

### Runtime Security
- Read-only root filesystem
- Drop all capabilities
- Seccomp `RuntimeDefault`
- Explicit healthchecks
- No privileged mode
- Set resource limits/requests

## Kubernetes Best Practices

### Security
- Restricted Pod Security Standards
- Default-deny NetworkPolicies
- RBAC least privilege with dedicated ServiceAccounts
- External secret providers
- Container securityContext (non-root, no privilege escalation, drop caps)

### Reliability
- Multiple replicas with PDBs and anti-affinity
- Rolling updates
- Liveness/readiness/startup probes
- Graceful shutdown handling
- HPA with right-sized requests/limits

## Infrastructure as Code

### Terraform
- Remote state with encryption and locking
- No state or `.terraform` in git
- Provider versions pinned
- Input validation
- Tags on all resources
- Modules for reuse
- Workspaces or var files per environment
- Least-priv IAM

### GitOps
- Git as source of truth
- Automated sync and self-heal with prune
- Kustomize overlays per environment
- RBAC on deploy permissions
- Audit trails

## CI/CD Practices

### Security Gates
- SAST/SCA scans
- Container scans
- Secret detection
- SBOM + signing
- Least-priv credentials (OIDC for cloud auth)
- Protected environments

### Efficiency
- Dependency caching
- Matrix builds
- Parallel stages
- Fail-fast patterns
- Artifact reuse

## Observability

### Logging
- Structured JSON with correlation IDs
- Configurable levels
- Central aggregation
- Retention and PII redaction

### Metrics
- Prometheus endpoints
- Track golden signals (latency, traffic, errors, saturation)
- Dashboards with alerting
- Define SLIs/SLOs

### Tracing
- Distributed tracing with context propagation
- Sampling strategies
- Performance profiling

## Security Practices

### Secrets and Access
- No secrets in git
- Use secret managers
- Rotate regularly
- Audit access
- Encrypt in transit and at rest
- Enforce least privilege, MFA, time-bound access
- Maintain audit logs

### Network
- Zero-trust segmentation
- TLS everywhere
- Managed certificates
- DDoS protections

## Disaster Recovery

### Backup Strategy
- Regular, encrypted backups
- Tested restores
- Retention policies
- Application state, configuration, infrastructure state, secrets

### Recovery Procedures
- **RTO**: < 1 hour
- **RPO**: < 15 minutes
- Automated failover
- Multi-region setup
- Quarterly DR drills

## Cost Optimization

### Compute
- Right-size resource requests
- Spot instances for non-critical workloads
- Cluster autoscaling
- Pod autoscaling based on metrics

### Storage
- Lifecycle policies for S3
- EBS volume optimization
- Compression and deduplication

### Network
- VPC endpoints to avoid NAT costs
- CloudFront for static content
- Efficient data transfer patterns

## Compliance & Governance

### Standards
- CIS Kubernetes Benchmark
- NIST Cybersecurity Framework
- SOC 2 Type II
- GDPR/CCPA compliance

### Policy Enforcement
- OPA (Open Policy Agent) for admission control
- Kyverno for Kubernetes policies
- Terraform Sentinel for IaC policies
- Pre-commit hooks for code quality

## Testing Strategy

### Unit Tests
- Individual function testing
- Mock external dependencies
- High code coverage (>80%)

### Integration Tests
- API endpoint testing
- Database integration
- External service mocking

### End-to-End Tests
- Full user workflows
- Production-like environment
- Automated in CI/CD

### Security Tests
- Penetration testing
- Vulnerability scanning
- Compliance validation

## Quality Gates

### Pre-commit
- Run `pre-commit install`
- Hooks: black, ruff, yamllint, shellcheck, hadolint, terraform fmt/validate/tflint/tfsec

### CI Workflows
- `full-project-ci`: lint/test/build/scan Module C
- `terraform-checks`: fmt/validate/tflint/tfsec
- `security-scan`: Trivy, Gitleaks, Semgrep

## Documentation Standards

### Code Documentation
- Inline comments for complex logic
- Function/class docstrings
- README in each module

### Operational Documentation
- Runbooks for common tasks
- Troubleshooting guides
- Architecture diagrams

### Change Documentation
- Git commit messages (conventional commits)
- Pull request descriptions
- Changelog maintenance

## References

See working examples throughout the repository:
- Container hardening: `coderbyte-problems/container-tasks/problem-01-optimize-dockerfile/`
- Pod debugging: `coderbyte-problems/debugging-tasks/problem-01-crashloop/`
- K8s manifests: `modules/C_full_project/k8s/`
- GitOps: `modules/B_mock_exam/exam_03/starter/`
- Terraform: `modules/C_full_project/terraform/`
- Observability: `practice_examples/observability-slo/`
- Policy as code: `practice_examples/security-policy/`
