# Engineering Playbook

Guiding conventions for this repository across code, infrastructure, CI/CD, and security.

## Coding Standards
- Python: format with `black`, lint with `ruff`; 120 char line guidance; type hints where practical.
- Shell: `set -euo pipefail`, quote variables, prefer long-form flags, lint with `shellcheck`.
- Docker: slim/non-root images, multi-stage builds, healthchecks, pinned bases where feasible.
- YAML/JSON: 2-space indent, use Kustomize for K8s; keep manifests schema-valid (kubeconform).

## Git & Branching
- Main branch is stable; feature branches per task.
- Commit messages: concise imperative (e.g., "Add kubeconform to CI").
- Avoid committing secrets; secret scanning runs in CI.

## Testing & Quality Gates
- Pre-commit hooks: run `pre-commit install`. Hooks cover black, ruff, yamllint, shellcheck, hadolint, terraform fmt/validate/tflint/tfsec.
- CI workflows:
  - `full-project-ci`: lint/test/build/scan Module C, validate K8s manifests.
  - `terraform-checks`: fmt/validate/tflint/tfsec across Terraform stacks.
  - `security-scan`: Trivy fs, Gitleaks, Semgrep.
- Python tests via `pytest`; container builds must pass Trivy (CRITICAL/HIGH fail CI).

## Infrastructure as Code
- Terraform: no unpinned providers; public access blocked; versioning/encryption enabled on S3; validate & tfsec in CI.
- K8s: use `kustomization.yaml` as entrypoint; enforce non-root, read-only FS, probes, resource requests/limits, PDB, HPA, NetworkPolicy; prefer restricted pod security.
- State: remote S3 backend with encryption; avoid committing state or `.terraform`.

## CI/CD Expectations
- Build images with explicit tags (SHA or semver) and non-root users.
- Scan images (Trivy) and lint Dockerfiles (hadolint) before push.
- Validate manifests with kubeconform; prefer canary/rolling updates.

## Security Practices
- Secrets: never commit; use CI secrets/OIDC. Secret scanning via Gitleaks and Semgrep.
- Dependencies: pin where possible; update regularly. Prefer minimal base images.
- Network: default deny via NetworkPolicies; ingress limited to needed namespaces/apps.
- Logging/Observability: structured logs; expose `/health`, `/ready`, `/metrics` where applicable.

## Operations
- Make targets: build/test/run/docker/k8s/terraform; parameterize images via `IMAGE_NAME/IMAGE_TAG/REGISTRY`.
- Runbooks: tests under `modules/*/tests`; instructions per exam in `modules/B_mock_exam/*/instructions.md`; module C README covers deploy steps.
- Cleanup: `make clean` removes bytecode and pytest cache.

## How to Contribute
- Run `pre-commit run --all-files` before PRs.
- Ensure CI passes; add/refresh tests when changing behavior.
- Document changes in module-specific READMEs when altering interfaces or deployment steps.
