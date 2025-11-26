# DevOps Best Practices Guide

## Container Best Practices

### Image Building
✅ Use multi-stage builds
✅ Minimize layers
✅ Use specific base image tags
✅ Run as non-root user
✅ Use .dockerignore
✅ Scan for vulnerabilities
✅ Sign images

### Runtime Security
✅ Read-only root filesystem
✅ Drop all capabilities
✅ Use seccomp profiles
✅ Set resource limits
✅ No privileged mode
✅ Use health checks

## Kubernetes Best Practices

### Security
✅ Pod Security Standards (restricted)
✅ Network policies (default deny)
✅ RBAC with least privilege
✅ Secrets via external providers
✅ Security contexts enforced
✅ Image pull policies

### Reliability
✅ Multiple replicas
✅ Pod disruption budgets
✅ Anti-affinity rules
✅ Liveness probes
✅ Readiness probes
✅ Startup probes
✅ Graceful shutdown

### Resource Management
✅ Set requests and limits
✅ Use HPA for scaling
✅ Monitor resource usage
✅ Right-size workloads
✅ Use node affinity

## Infrastructure as Code

### Terraform
✅ Use remote state
✅ Enable state locking
✅ Encrypt state
✅ Use workspaces
✅ Validate inputs
✅ Tag all resources
✅ Use modules
✅ Version providers

### GitOps
✅ Git as single source of truth
✅ Automated sync
✅ Self-healing enabled
✅ Prune orphaned resources
✅ Use overlays for environments
✅ Implement RBAC
✅ Audit all changes

## CI/CD Best Practices

### Pipeline Security
✅ Scan code (SAST)
✅ Scan dependencies (SCA)
✅ Scan containers
✅ Detect secrets
✅ Sign artifacts
✅ Generate SBOM
✅ Use least privilege

### Pipeline Efficiency
✅ Cache dependencies
✅ Parallel execution
✅ Fail fast
✅ Incremental builds
✅ Artifact reuse
✅ Matrix builds

### Platform Checklists
**GitHub Actions**
- Require status checks + signed commits; use CODEOWNERS for critical paths
- Reusable workflows: lint/test, terraform checks (fmt/validate/tflint/tfsec), image scan with Trivy
- OIDC for cloud auth; avoid long-lived keys; upload SARIF for security scans
- Matrix builds (amd64/arm64) with SBOM (syft) + provenance (cosign); protected environments for promotions

**GitLab CI**
- Stages: lint → test → build → scan → deploy; protect variables and runners
- Terraform plan/apply with manual gates; container/SAST/secret scans enabled
- Dynamic review apps with auto teardown; Helm deploys with rollback; compliance pipelines for licenses/security

**Azure DevOps**
- Multi-stage YAML (CI → QA → Prod) with approvals/gates; variable groups + Key Vault for secrets
- ACR push via managed identity; AKS blue/green or canary with health gates
- Policy gates (tfsec/Checkov), signed images (cosign), SBOM publish; Defender for Cloud integration

## Observability

### Logging
✅ Structured logging (JSON)
✅ Include correlation IDs
✅ Log levels configurable
✅ Centralized aggregation
✅ Retention policies
✅ PII redaction

### Metrics
✅ Expose Prometheus metrics
✅ Track golden signals
✅ Set up alerting
✅ Dashboard creation
✅ SLI/SLO definition

### Tracing
✅ Distributed tracing
✅ Span context propagation
✅ Sampling strategies
✅ Performance profiling

## Security Best Practices

### Secrets Management
✅ Never commit secrets
✅ Use secret managers
✅ Rotate regularly
✅ Audit access
✅ Encrypt at rest
✅ Encrypt in transit

### Access Control
✅ Principle of least privilege
✅ MFA enforcement
✅ Regular access reviews
✅ Audit logging
✅ Time-bound access

### Network Security
✅ Zero-trust networking
✅ Network segmentation
✅ TLS everywhere
✅ Certificate management
✅ DDoS protection

## Disaster Recovery

### Backup Strategy
✅ Regular backups
✅ Test restores
✅ Off-site storage
✅ Encryption
✅ Retention policies
✅ Automation

### High Availability
✅ Multi-AZ deployment
✅ Auto-scaling
✅ Load balancing
✅ Failover testing
✅ RTO/RPO defined

## Cost Optimization

### Compute
✅ Right-size instances
✅ Use spot instances
✅ Auto-scaling policies
✅ Reserved instances
✅ Shutdown non-prod

### Storage
✅ Lifecycle policies
✅ Compression
✅ Deduplication
✅ Tiered storage
✅ Delete unused

### Monitoring
✅ Cost allocation tags
✅ Budget alerts
✅ Usage reports
✅ Optimization recommendations

## Compliance

### Standards
✅ CIS Benchmarks
✅ PCI DSS
✅ HIPAA
✅ SOC 2
✅ GDPR
✅ ISO 27001

### Auditing
✅ Audit logs enabled
✅ Immutable logs
✅ Regular reviews
✅ Compliance scanning
✅ Policy enforcement
