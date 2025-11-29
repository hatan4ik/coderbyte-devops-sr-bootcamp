# Problem 1 – Basic CI Pipeline

**Objective**: Build a minimal CI pipeline (lint, test, build) with clear quality gates.

## Requirements
- Lint and unit test steps must block merges on failure.
- Produce build artifacts for downstream stages.
- Run on pull request and main branch.
- Surface results in PR status checks.

## Deliverables
- Pipeline definition (GitHub Actions/Jenkins/GitLab CI).
- README describing triggers, stages, and how to run locally.
