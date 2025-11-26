# Quorum Board: Crushing Coderbyte DevOps (Sr. Level)

## Board Members & Roles
- **Principal DevOps Architect (Chair)**: Architecture, pipelines, IaC, cloud patterns, GitOps, best practices; curates and continuously grooms repo content for production-grade standards.
- **Software Engineer (Backend + Scripting Expert)**: Python/Go/Bash algorithms, APIs, testability, fixtures, deterministic outputs.
- **Systems Engineer / Linux SME**: Kernel, networking, processes, filesystems, perf/debug tooling (strace, lsof, tcpdump).
- **SRE Specialist**: Reliability patterns, SLIs/SLOs, error budgets, alert hygiene, incident response/runbooks.
- **Cloud Architect (AWS + Azure)**: IAM/WIF-OIDC, VPC/VNet, KMS/Key Vault, secrets, landing zones, service wiring.
- **CI/CD & Automation Guru**: GitHub Actions, ADO, GitLab, Jenkins; reusable templates, gates, artifact signing, SBOM.
- **Containers + K8s Engineer**: Dockerfile optimization, Helm/Kustomize, clusters (EKS/AKS/RKE2), probes/limits, NetPol/PDB/HPA.
- **Security/DevSecOps Expert**: Scanning (SAST/SCA/Trivy/tfsec), OPA/Conftest, signing (cosign), policy enforcement, CVE triage.
- **Publishing Editor (O’Reilly-style)**: Ensures docs/readmes are structured, concise, and actionable; enforces zero-to-hero narrative, consistent terminology, and cross-links from guidance to runnable labs and modules.

## Assessment Types (What You Will Face)
- **Short scripts**: Bash/Python/Go utilities (parsers, health checks, file ops).
- **API/Web tasks**: Build/patch endpoints, health/metrics, logging.
- **Infra as Code**: Terraform/K8s manifests; fix security/HA issues.
- **Pipelines**: Write/fix CI for build/test/scan/deploy.
- **Security fixes**: Remove hardcoded secrets, add scans, tighten permissions.
- **Debug/optimize**: Find bugs, improve performance, add probes/limits.

## Zero → Hero Skill Plan
- **Week 1-2 (Foundations)**: Bash text processing; Python requests/json/re; Git basics; Dockerfile fundamentals.
- **Week 3-4 (Systems)**: K8s objects (Deploy/Service/HPA/PDB/NetPol); Terraform basics (providers, state, S3/LG/IGW/ECS/EKS patterns); logging/metrics.
- **Week 5-6 (Pipelines/Security)**: GitHub Actions/GitLab/Azure DevOps YAML; pre-commit; Trivy/semgrep/gitleaks/tfsec/hadolint; SBOM (syft) and signing (cosign).
- **Week 7+ (Polish)**: GitOps (Argo/Flux), canary/blue-green, SLO-based alerts, cost controls, chaos drills.

## Exact Techniques to Pass Coding Challenges
- **Read first**: Confirm inputs/outputs, constraints, forbidden/required tools.
- **Scaffold fast**: Add usage/help, arg validation, exit codes. Default to non-root, set `set -euo pipefail` in Bash.
- **Test as you go**: Create temp fixtures; run `pytest -q` or simple asserts; add sample logs/json.
- **Log + metrics**: Structured logging (JSON), add `/health`/`/ready`/`/metrics` if web.
- **Secure by default**: No hardcoded secrets; parametrize; validate inputs; fail closed.
- **Validate artifacts**: `shellcheck`, `ruff/black`, `hadolint`, `trivy`, `terraform validate|tflint|tfsec`, `kubeconform` for manifests.
- **Outputs**: Pretty JSON/text exactly as required; deterministic ordering when needed.

## DevOps-Specific Tasks Coderbyte Uses
- Bash: log greps, word/line counts, HTTP checks, backups, user/process listing, SSL checks.
- Python: log parsers, JSON filters, API clients, health monitors, CSV/INI parsers, concurrency basics.
- Containers: Fix Dockerfile (slim base, non-root, healthcheck, .dockerignore).
- K8s: Add probes, limits, securityContext, NetPol, HPA, PDB, kustomization.
- Terraform: S3 bucket with encryption/versioning/public-block; IAM least privilege; VPC/subnets/peering; remote state hygiene.
- CI/CD: GitHub Actions pipeline to lint/test/build/scan; Terraform fmt/validate; image push with trivy scan; secret handling.
- Security: Remove plaintext creds; add secret scanning; enforce TLS/https URLs; SBOM/signing (bonus).

## Mock Questions + Perfect Answers
- **Q:** Add liveness/readiness to this Deployment and lock it down. **A:** Add httpGet probes on `/health`/`/ready`, set `runAsNonRoot`, `readOnlyRootFilesystem`, drop `ALL` caps, set requests/limits, add PDB=1 and HPA min=2, add NetPol default-deny with ingress from ingress controller.
- **Q:** Fix this Dockerfile for prod. **A:** Use `python:3.11-slim`, add `.dockerignore`, multi-stage if builds, install deps with `--no-cache`, create non-root user, set `PYTHONDONTWRITEBYTECODE`/`PYTHONUNBUFFERED`, add `HEALTHCHECK`, expose only needed port, no apt cache, pin versions.
- **Q:** Secure this S3 Terraform. **A:** Add `block_public_acls/policy`, enable versioning + SSE AES256/KMS, lifecycle for noncurrent versions, tags, least-priv IAM policy (Get/Put/List only), remote state with locking.
- **Q:** Build a CI pipeline. **A:** Jobs: pre-commit (ruff/black/yamllint/shellcheck/hadolint), tests (pytest), build image, trivy scan (fail on HIGH/CRIT), terraform fmt/validate/tflint/tfsec, optional kubeconform on manifests, push image only if secrets present.
- **Q:** How to expose metrics? **A:** Add `/metrics` endpoint (Prometheus), instrument request count/latency/errors, add annotations `prometheus.io/scrape: "true"`, `prometheus.io/port: "8000"`, wire to Service; add basic alert rules (error rate >5%, p95>500ms).

## Full Training Roadmap
1) **Daily reps**: Solve 1–2 Bash/Python tasks from Module A with tests. 
2) **Containers**: Rebuild Dockerfiles non-root + healthcheck; run hadolint/trivy.
3) **K8s**: Patch Deployment with probes/limits/securityContext; add NetPol/HPA/PDB; validate with kubeconform.
4) **Terraform**: Author S3/VPC/IAM small stacks; run fmt/validate/tflint/tfsec.
5) **Pipelines**: Adapt templates in `ci-templates/` for Actions/GitLab/Azure; include scans and gates.
6) **GitOps**: Practice ArgoCD/kustomize overlays; deploy dev/prod variants.
7) **Observability**: Add structured logs + `/metrics`; create basic alerts.
8) **Security**: Run gitleaks/semgrep/trivy/tfsec regularly; remove secrets; add SBOM/signing.
9) **Mock exams**: Run Module B timers; aim for clean, tested, scanned deliverables in under timebox.
10) **Review & polish**: Write short README for each task; note trade-offs and assumptions.
