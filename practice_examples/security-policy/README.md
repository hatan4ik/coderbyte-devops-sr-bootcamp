# Supply Chain & Policy-as-Code Demo

Minimal example showing how to enforce signed images and scan IaC using Conftest + OPA, plus a cosign verification snippet.

## Contents
- `policy/k8s.rego` — OPA policy denying unsigned images (expects `cosign.sigstore.dev/signature` annotation or trusted registry).
- `policy/terraform.rego` — OPA policy requiring S3 encryption + versioning and blocking public ACLs.
- `conftest.sh` — Run Conftest on sample manifests and Terraform plan JSON.
- `samples/` — Sample Kubernetes Deployment and Terraform plan output for testing.
- `verify_cosign.sh` — Verify image signatures with cosign if configured.
- `gatekeeper/` — Gatekeeper ConstraintTemplate + Constraint to require trusted/signed images.

## Usage
```bash
cd practice_examples/security-policy
./conftest.sh
# If you have cosign and a signed image:
COSIGN_EXPERIMENTAL=1 ./verify_cosign.sh ghcr.io/your-org/your-image:tag
```

Adjust policies to match your org (trusted registries, annotation keys, etc.).
