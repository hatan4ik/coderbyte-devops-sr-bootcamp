# Problem 5 – Container Image Scanning Pipeline

**Objective**: Build a container supply chain scanning pipeline.

## Requirements
- Integrate Trivy/Grype for image scans and Syft for SBOM.
- Fail on HIGH/CRITICAL vulnerabilities; allow waivers with justification.
- Store scan reports as artifacts; optional registry upload on pass.
- Document local run instructions.

## Deliverables
- Pipeline definition with scanning stages.
- Sample scan report and SBOM artifact.
