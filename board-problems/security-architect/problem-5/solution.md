# Solution – Container Image Scanning Pipeline

## Approach
- Add supply-chain scanning and SBOM generation to CI with enforced gates.

## Steps
- Generate SBOM with Syft; scan images with Trivy/Grype; fail on HIGH/CRIT.
- Support allowlist with justification for exceptional CVEs.
- Publish SBOM and scan reports as artifacts; optional push to registry only on pass.
- Document local run commands for parity.

## Validation
- CI run produces SBOM and reports; intentional vulnerable image fails.
- Allowlist applies only to documented CVEs; overall pipeline remains green on clean image.

### Artifacts
- [`github-actions.yaml`](solution/github-actions.yaml) – pipeline with SBOM + vuln scan gates.
