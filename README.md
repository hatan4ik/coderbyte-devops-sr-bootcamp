# Coderbyte DevOps Sr Bootcamp (AWS-First, Production-Grade)

Enterprise training ground for senior DevOps/SRE/Platform engineers. Core modules, assessments, and the full project are now standardized on **AWS** (S3 backend, CloudWatch, IAM, EKS-ready Kubernetes). The GCP content remains as a **porting track**, not a peer primary stack.

## Cloud Strategy (Critical Update)
- **Primary cloud: AWS.** Module C infrastructure, Module B Terraform tasks, and the practice VPC labs are all AWS-based with S3/DynamoDB backends and CloudWatch integrations.
- **Secondary/porting track: GCP.** The [gcp-zero-to-hero/](gcp-zero-to-hero/README.md) path teaches translation and migration. Keep state/config separate; do not mix providers or backends within the same workspace.
- **What changed:** The landing page, navigation, and Terraform guidance now anchor on AWS. See [Cloud Strategy](CLOUD_STRATEGY.md) for the decision record and migration guardrails.

## Use This Repository
- Start with [Coderbyte Mastery Guide](CODERBYTE_MASTERY_GUIDE.md) for the zero-to-hero learning path.
- Keep [Index](INDEX.md) open for deep links to modules, exams, and labs; [Site Map](SITE_MAP.md) for a full sitemap.
- Follow module-level READMEs while you work; use [practice_examples/](practice_examples/README.md) for hands-on reps.
- Review [Production Guide](PRODUCTION_GUIDE.md) and [Security](SECURITY.md) before submitting any assessment-quality work.
- Cloud alignment and porting guardrails live in [Cloud Strategy](CLOUD_STRATEGY.md).
- Dependency management: install once with `poetry install --sync`, then run tools via `poetry run ...`.

## Dependency Management (Poetry)
- `pyproject.toml` + `poetry.lock` are the source of truth; avoid ad-hoc `pip install` drift.
- Bootstrap: `poetry install --sync` (Makefile `setup` wraps this) and run commands with `poetry run <cmd>`.
- Base install is lean (no AWS SDK/X-Ray). For AWS extras, install with `poetry install --sync --extras aws` or use the exported `requirements-aws.txt`.
- Export pinned requirements for container builds: `poetry export --without-hashes --format requirements.txt --output requirements.txt` (base) and `poetry export --without-hashes --format requirements.txt --extras aws --output requirements-aws.txt` (AWS).
- Legacy `requirements.txt` files are maintained via export for environments that cannot run Poetry.

## Navigation Shortcuts
- [Production standards](PRODUCTION_GUIDE.md)
- [Security posture](SECURITY.md)
- [Cloud strategy](CLOUD_STRATEGY.md)
- [Full project guide](modules/C_full_project/README.md)
- [Brownfield/state refactor (canonical)](modules/F_state_refactoring/README.md)
- [Legacy brownfield module (archived)](modules/F_brownfield_scenarios/README.md)
- [Mock exam walkthrough (GitOps)](modules/B_mock_exam/exam_03/starter/README.md)
- [Complete site map](SITE_MAP.md)

## Baseline Controls (production defaults)
- Full baseline details: [Production Guide](PRODUCTION_GUIDE.md) and [Security](SECURITY.md)
### Security
- Multi-stage Docker builds with non-root users ([modules/C_full_project/docker/Dockerfile](modules/C_full_project/docker/Dockerfile))
- Pod security contexts with seccomp and dropped capabilities ([modules/C_full_project/k8s/deployment.yaml](modules/C_full_project/k8s/deployment.yaml))
- Network policies enforcing explicit ingress/egress ([modules/C_full_project/k8s/networkpolicy.yaml](modules/C_full_project/k8s/networkpolicy.yaml))
- Encrypted Terraform state with locking; secret scanning in CI (Trivy, Semgrep, Gitleaks) ([modules/C_full_project/terraform/backend.hcl](modules/C_full_project/terraform/backend.hcl), [.github/workflows/security-scan.yaml](.github/workflows/security-scan.yaml))
- Pre-commit hooks for linting, IaC validation, and secret detection ([.pre-commit-config.yaml](.pre-commit-config.yaml))

### Availability and Resilience
- Pod Disruption Budgets, anti-affinity, and rolling updates
- Horizontal Pod Autoscaling with sensible requests/limits
- Health checks (liveness, readiness, startup) and graceful shutdowns

### Observability
- Structured logging and Prometheus metrics
- Health/readiness endpoints and tracing-ready instrumentation
- CloudWatch integration for AWS examples

### Infrastructure as Code
- [Terraform](modules/C_full_project/terraform/main.tf) with validation + policy scanning
- [Kustomize manifests](modules/C_full_project/k8s/kustomization.yaml) per environment (extend via env-specific overlays as needed)
- [ArgoCD-driven GitOps deployments](modules/B_mock_exam/exam_03/starter/README.md)

## Modules at a Glance
- **[Module A: Zero to Hero](modules/A_zero_to_hero/README.md)** — Bash/Python/Go fundamentals with production patterns. Run tests: `cd modules/A_zero_to_hero && ./run_tests.sh`
- **[Module B: Mock Exams (10 timed)](modules/B_mock_exam/README.md)** — Realistic challenges across web services, pipelines, cloud, K8s, security, networking. Example start: `cd modules/B_mock_exam/exam_03 && ./start_exam.sh`
- **[Module C: Full Project (AWS)](modules/C_full_project/README.md)** — Production Python service, hardened Dockerfile, Kubernetes manifests, Terraform stack (S3 backend), CI/CD. Run locally: `make docker-build && make docker-run`; Deploy: `make k8s-deploy` | Infra: `make terraform-plan`
- **[Module D: Practice Challenges](modules/D_practice_challenges/README.md)** — Standalone labs mirroring interview asks (log parsing, API clients, Dockerfile fixes, Terraform, K8s).
- **[Module E: Custom Plan](modules/E_custom_plan/README.md)** — Skills mapping, gap analysis, and job-specific prep checklists.
- **[Module F: State Refactoring](modules/F_state_refactoring/README.md)** — Brownfield Terraform imports and `terraform state mv` drills (AWS-only).

## Quality Gates and Testing
- Pre-commit: `pre-commit install` (black, ruff, yamllint, shellcheck, hadolint, terraform fmt/validate/tflint/tfsec, secret scans).
- CI workflows:
  - [`full-project-ci.yaml`](.github/workflows/full-project-ci.yaml) – lint, test, build, scan for Module C.
  - [`terraform-checks.yaml`](.github/workflows/terraform-checks.yaml) – fmt/validate/tflint/tfsec across Terraform stacks.
  - [`security-scan.yaml`](.github/workflows/security-scan.yaml) – Trivy, Gitleaks, Semgrep.
- Local testing quick hits:
  - `make test` (all) | `cd modules/C_full_project && pytest -v`
  - `make security-scan` | `make lint`

## AWS Terraform Inputs (core stack)
Core variables for `modules/C_full_project/terraform/`:

| Name | Description | Type | Default | Required |
|---|---|---|---|:---:|
| `region` | Primary AWS region | `string` | `"us-east-1"` | No |
| `environment` | Environment (`dev`, `stage`, `prod`) | `string` | `"dev"` | No |
| `service_name` | Service name (lowercase, hyphenated) | `string` | `"devops-demo"` | No |
| `owner` | Team/owner tag | `string` | `"devops-team"` | No |
| `enable_versioning` | Enable S3 versioning | `bool` | `true` | No |
| `enable_encryption` | Enable S3 SSE | `bool` | `true` | No |

**Example `terraform.tfvars`:**
```hcl
region            = "us-east-1"
environment       = "dev"
service_name      = "devops-demo"
owner             = "platform-team"
enable_versioning = true
enable_encryption = true
```

**Backend config (`backend.hcl`):**
```hcl
bucket         = "terraform-state-bucket"
key            = "devops-demo/terraform.tfstate"
region         = "us-east-1"
encrypt        = true
dynamodb_table = "terraform-state-lock"
```

## Commands You’ll Use
- `./menu.sh` – interactive entry point
- `make setup` – bootstrap tooling
- `make test` | `make lint` | `make security-scan`
- `make docker-build` | `make docker-run`
- `make k8s-deploy`
- `make terraform-init` | `make terraform-plan`
- `make clean`
- `poetry install --sync` | `poetry run <command>`

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

## Performance Guardrails
- Docker image size: ~150MB (slim, non-root, multi-stage)
- Build time: 2–3 minutes with cache
- Startup time: <5 seconds
- Memory footprint: 50–100MB per pod
- Target test coverage: 80%+

## Learning Path
- Weeks 1-2: [Module A](modules/A_zero_to_hero/README.md) (Bash, Python, Go fundamentals)
- Weeks 3-4: [Module C](modules/C_full_project/README.md) (full project)
- Weeks 5-6: [Module B exams 1-5](modules/B_mock_exam/README.md)
- Weeks 7-8: [Module B exams 6-10](modules/B_mock_exam/README.md)
- Week 9: [Module D challenges](modules/D_practice_challenges/README.md)
- Week 10: [Module E customization](modules/E_custom_plan/README.md) and interview prep

## Success Criteria
- [ ] Complete [Module A exercises](modules/A_zero_to_hero/README.md)
- [ ] Pass 8/10 [mock exams](modules/B_mock_exam/README.md)
- [ ] Deploy [Module C](modules/C_full_project/README.md) to production (AWS)
- [ ] Implement security controls across modules
- [ ] Maintain 80%+ test coverage
- [ ] Document decisions and trade-offs

## References
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [12-Factor App](https://12factor.net/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
