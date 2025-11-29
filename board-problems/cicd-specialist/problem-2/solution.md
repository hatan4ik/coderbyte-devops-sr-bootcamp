# Solution – Supply Chain Scanning

## Approach
- Add secrets/SAST/SBOM scanning gates to CI.

## Steps
- Run Gitleaks (fail on HIGH/CRIT); Semgrep/CodeQL for SAST.
- Generate SBOM with Syft/Trivy; publish reports; allowlist only with justification.
- Document local run commands.

## Validation
- Known secret/CVE triggers fail; SBOM artifact produced; reports downloadable; clean pipeline passes.
