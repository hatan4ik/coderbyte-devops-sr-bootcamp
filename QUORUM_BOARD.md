# Quorum Board: Editorial + FAANG Review

The quorum operates like an O’Reilly editorial board backed by FAANG-level specialists. Its mandate: keep every artifact production-ready, readable, and directly tied to hands-on labs.

## Roster and Responsibilities
- Principal DevOps Architect (Chair): architecture, pipelines, IaC, GitOps; curates production standards.
- Software Engineer (Backend/Scripting): Python/Go/Bash correctness, testability, deterministic outputs.
- Systems Engineer (Linux): kernel/process/network expertise; performance and debugging discipline.
- SRE Specialist: SLIs/SLOs, alert hygiene, incident response, runbooks.
- Cloud Architect (AWS/Azure): IAM/OIDC, VPC/VNet, KMS/Key Vault, landing zones, secrets.
- CI/CD and Automation Lead: GitHub Actions/Azure DevOps/GitLab/Jenkins, reusable templates, artifact signing, SBOM.
- Containers + Kubernetes Engineer: Dockerfile optimization, Helm/Kustomize, NetPol/PDB/HPA/probes/limits.
- Security/DevSecOps Expert: SAST/SCA/Trivy/tfsec, OPA/Conftest, signing (cosign), CVE triage and policy enforcement.
- Publishing Editor (O’Reilly): structure, clarity, consistent terminology, zero-to-hero story, cross-links to runnable labs.

## Operating Model
- Review cadence: gate changes against `ENGINEERING.md`, `BEST_PRACTICES.md`, and module READMEs.
- Acceptance criteria: production defaults (non-root, probes, limits, encryption, least privilege), tests and scanners passing, documentation updated with links back to labs.
- Style guardrails: short sections, verbs first, links to code or exercises, consistent naming across modules and exams.

## Assessment Coverage
- Short scripts: Bash/Python/Go utilities (parsers, health checks, file ops).
- API/Web: build/patch endpoints, add health/metrics/logging.
- Infrastructure as Code: Terraform/K8s fixes for security and HA.
- Pipelines: build/test/scan/deploy with quality gates and artifact security.
- Security: secret removal, scanning, policy enforcement.
- Debug/Optimize: root-cause analysis, performance fixes, probes/limits.

## Zero-to-Hero Plan (macro view)
- Weeks 1–2: Bash/Python/Go foundations; Dockerfile fundamentals.
- Weeks 3–4: Kubernetes objects (Deploy/Service/HPA/PDB/NetPol) and Terraform basics (providers, state, VPC/S3 patterns); logging/metrics.
- Weeks 5–6: CI/CD YAML (Actions/GitLab/Azure DevOps), pre-commit, Trivy/Semgrep/Gitleaks/tfsec/hadolint, SBOM (syft) + signing (cosign).
- Week 7+: GitOps (Argo/Flux), canary/blue-green, SLO-based alerts, cost controls, chaos drills.

## Execution Playbook
- Read first: confirm inputs/outputs, constraints, required/forbidden tools.
- Scaffold fast: usage/help, arg validation, exit codes; `set -euo pipefail` in Bash; default to non-root.
- Test continuously: fixtures and sample data; `pytest -q` or asserts for scripts.
- Ship observability: structured JSON logs, `/health` `/ready` `/metrics` endpoints.
- Secure by default: no hardcoded secrets, input validation, fail closed, least privilege IAM/RBAC.
- Validate artifacts: `shellcheck`, `ruff/black`, `hadolint`, `trivy`, `terraform fmt|validate|tflint|tfsec`, `kubeconform`.
- Deterministic outputs: stable ordering and exact formatting for graders.

## DevOps Tasks You Will See
- Bash: log greps, word/line counts, HTTP checks, backups, user/process listing, SSL checks.
- Python: log parsers, JSON filters, API clients, health monitors, CSV/INI parsers, concurrency basics.
- Containers: Slim/non-root Dockerfiles, `.dockerignore`, healthcheck.
- Kubernetes: Probes, limits, securityContext, NetworkPolicy, HPA, PDB, Kustomize overlays.
- Terraform: S3 encryption/versioning/public-block, IAM least privilege, VPC/subnets/peering, remote state hygiene.
- CI/CD: Pipelines with lint/test/build/scan, Terraform fmt/validate, image scan + push with secrets handled safely.
- Security: Secret scanning, TLS enforcement, SBOM/signing when possible.

## Mock Answers (condensed reference)
- Harden a Deployment: add liveness/readiness on `/health` and `/ready`, `runAsNonRoot`, `readOnlyRootFilesystem`, drop `ALL` caps, set requests/limits, add PDB=1 and HPA min=2, default-deny NetPol with ingress from ingress controller/monitoring.
- Production Dockerfile: `python:3.11-slim`, `.dockerignore`, multi-stage when building, install deps with `--no-cache`, create non-root user, set `PYTHONDONTWRITEBYTECODE`/`PYTHONUNBUFFERED`, add `HEALTHCHECK`, expose only needed port, pin bases.
- Secure S3 Terraform: block public ACL/policy, enable versioning + SSE (AES256/KMS), lifecycle for noncurrent versions, tags, least-priv IAM (Get/Put/List), remote state with locking.
- CI pipeline shape: pre-commit (ruff/black/yamllint/shellcheck/hadolint), tests (pytest), docker build, trivy scan (fail HIGH/CRIT), terraform fmt/validate/tflint/tfsec, optional kubeconform, push image only if secrets configured.

## Training Roadmap (keep in rotation)
1. Daily reps: 1–2 Bash/Python tasks from Module A with tests.
2. Containers: rebuild Dockerfiles non-root with healthchecks; run hadolint/trivy.
3. Kubernetes: patch Deployments with probes/limits/securityContext; add NetPol/HPA/PDB; validate with kubeconform.
4. Terraform: author S3/VPC/IAM stacks; run fmt/validate/tflint/tfsec.
5. Pipelines: adapt `ci-templates/` for Actions/GitLab/Azure; include scans and gates.
6. GitOps: practice ArgoCD/Kustomize overlays; deploy dev/prod variants.
7. Observability: structured logs + `/metrics`; basic alerts.
8. Security: run gitleaks/semgrep/trivy/tfsec regularly; remove secrets; add SBOM/signing.
9. Mock exams: run Module B timers; target clean, tested, scanned deliverables inside timebox.
10. Review and polish: short README per task; note trade-offs and assumptions.
