# Coderbyte DevOps Sr Bootcamp (Production-Grade)

Enterprise training ground for senior-level DevOps assessments with production patterns, security hardening, and battle-tested labs.

## Table of Contents
- Use This Repository
- Navigation Shortcuts
- Baseline Controls
- Modules at a Glance
- Quality Gates and Testing
- Security Baseline (snippets)
- CI/CD Flow
- Commands You’ll Use
- Learning Path
- Troubleshooting
- Performance Guardrails
- Success Criteria
- References

## Use This Repository
- Start with `CODERBYTE_MASTERY_GUIDE.md` for the zero-to-hero learning path.
- Keep `INDEX.md` open for deep links to modules, exams, and labs.
- Follow module-level READMEs while you work; use `practice_examples/` for hands-on reps.
- Review `ENGINEERING.md` and `SECURITY.md` before submitting any assessment-quality work.

## Navigation Shortcuts
- Overview: `ARCHITECTURE.md`
- Standards and workflows: `ENGINEERING.md`, `BEST_PRACTICES.md`
- Security posture: `SECURITY.md`
- Full project guide: `modules/C_full_project/README.md`
- Mock exam walkthrough (GitOps): `modules/B_mock_exam/exam_03/starter/README.md`

## Baseline Controls (production defaults)
### Security
- Multi-stage Docker builds with non-root users
- Pod security contexts with seccomp and dropped capabilities
- Network policies enforcing explicit ingress/egress
- Encrypted Terraform state with locking; secret scanning in CI (Trivy, Semgrep, Gitleaks)
- Pre-commit hooks for linting, IaC validation, and secret detection

### Availability and Resilience
- Pod Disruption Budgets, anti-affinity, and rolling updates
- Horizontal Pod Autoscaling with sensible requests/limits
- Health checks (liveness, readiness, startup) and graceful shutdowns

### Observability
- Structured logging and Prometheus metrics
- Health/readiness endpoints and tracing-ready instrumentation
- CloudWatch integration for AWS examples

### Infrastructure as Code
- Terraform with validation + policy scanning
- Kustomize overlays per environment
- ArgoCD-driven GitOps deployments

## Modules at a Glance
### Module A: Zero to Hero
- Bash, Python, and Go fundamentals with production-grade patterns.
- Run tests: `cd modules/A_zero_to_hero && ./run_tests.sh`

### Module B: Mock Exams (10 timed)
- Realistic Coderbyte-style challenges covering web services, pipelines, cloud, K8s, security, and networking.
- Example start: `cd modules/B_mock_exam/exam_03 && ./start_exam.sh`

### Module C: Full Project
- Production-ready Python service, hardened Dockerfile, Kubernetes manifests, Terraform stack, and CI/CD pipelines.
- Run locally: `make docker-build && make docker-run`
- Deploy: `make k8s-deploy` | Infra: `make terraform-plan`

### Module D: Practice Challenges
- Standalone exercises that mirror common interview asks (log parsing, API clients, Dockerfile fixes, Terraform, K8s).

### Module E: Custom Plan
- Skills mapping, gap analysis, and job-specific prep checklists.

## Quality Gates and Testing
- Pre-commit: `pre-commit install` (black, ruff, yamllint, shellcheck, hadolint, terraform fmt/validate/tflint/tfsec, secret scans).
- CI workflows:
  - `.github/workflows/full-project-ci.yaml` – lint, test, build, scan for Module C.
  - `.github/workflows/terraform-checks.yaml` – fmt/validate/tflint/tfsec across Terraform stacks.
  - `.github/workflows/security-scan.yaml` – Trivy, Gitleaks, Semgrep.
- Local testing quick hits:
  - `make test` (all) | `cd modules/C_full_project && pytest -v`
  - `make security-scan` | `make lint`

## Security Baseline (snippets)
### Container
```yaml
# Non-root user, read-only FS, least privilege
USER 1000
readOnlyRootFilesystem: true
capabilities:
  drop: [ALL]
seccompProfile:
  type: RuntimeDefault
```

### Kubernetes
```yaml
policyTypes: [Ingress, Egress]
runAsNonRoot: true
allowPrivilegeEscalation: false
resources:
  limits:
    cpu: 500m
    memory: 512Mi
```

### Terraform
```hcl
backend "s3" {
  encrypt = true
}

block_public_acls = true

versioning_configuration {
  status = "Enabled"
}
```

## CI/CD Flow
```
┌─────────────┐
│  Git Push   │
└──────┬──────┘
       ↓
┌──────────────────┐
│ Security Scan    │
│ - Trivy          │
│ - Gitleaks       │
│ - Semgrep        │
└──────┬───────────┘
       ↓
┌──────────────────┐
│ Build & Test     │
│ - Docker build   │
│ - Unit tests     │
│ - Image scan     │
└──────┬───────────┘
       ↓
┌──────────────────┐
│ Deploy           │
│ - Push image     │
│ - Update K8s     │
│ - Verify health  │
└──────────────────┘
```

## Commands You’ll Use
- `./menu.sh` – interactive entry point
- `make setup` – bootstrap tooling
- `make test` | `make lint` | `make security-scan`
- `make docker-build` | `make docker-run`
- `make k8s-deploy`
- `make terraform-init` | `make terraform-plan`
- `make clean`

## Learning Path
- Weeks 1-2: Module A (Bash, Python, Go fundamentals)
- Weeks 3-4: Module C (full project)
- Weeks 5-6: Module B exams 1-5
- Weeks 7-8: Module B exams 6-10
- Week 9: Module D challenges
- Week 10: Module E customization and interview prep

## Troubleshooting
### Docker
- Check daemon: `docker info`
- Clean artifacts: `docker system prune -a`

### Kubernetes
- Cluster health: `kubectl cluster-info`
- Logs: `kubectl logs -n <namespace> <pod>`
- Events/describe: `kubectl describe pod <pod>`

### Terraform
- Validate: `terraform validate`
- Inspect state: `terraform show`
- Refresh: `terraform refresh`

## Performance Guardrails
- Docker image size: ~150MB (slim, non-root, multi-stage)
- Build time: 2–3 minutes with cache
- Startup time: <5 seconds
- Memory footprint: 50–100MB per pod
- Target test coverage: 80%+

## Success Criteria
- [ ] Complete Module A exercises
- [ ] Pass 8/10 mock exams
- [ ] Deploy Module C to production
- [ ] Implement security controls across modules
- [ ] Maintain 80%+ test coverage
- [ ] Document decisions and trade-offs

## References
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [12-Factor App](https://12factor.net/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
