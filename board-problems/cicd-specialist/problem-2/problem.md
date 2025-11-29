# Problem 2 – Supply Chain Scanning

**Objective**: Add secret scanning, SAST, and SBOM generation to the CI pipeline.

## Requirements
- Secret scan (e.g., Gitleaks) must fail on HIGH/CRITICAL.
- SAST (Semgrep/CodeQL) must run on PRs.
- Generate and publish SBOM (Syft/Trivy) as an artifact.
- Document how to run the scanners locally.

## Deliverables
- Updated pipeline definition with gates.
- SBOM artifact and sample scan reports.
