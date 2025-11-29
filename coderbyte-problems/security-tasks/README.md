# Security Tasks

Hands-on problems backed by runnable security labs.

1) **Container Security Audit (Medium)**  
- **Problem**: Scan a container image, remediate critical issues, and prove the fixes.  
- **Code reference**: `practice_examples/container-sbom/` (syft SBOM + cosign signing/verification).  
- **How to run**: `cd practice_examples/container-sbom && ./build_and_sign.sh <image>`; review generated SBOM and signature.

2) **Policy as Code (Medium)**  
- **Problem**: Enforce K8s/Terraform guardrails via OPA/Conftest.  
- **Code reference**: `practice_examples/security-policy/` (OPA/Gatekeeper/Kyverno examples plus Conftest helpers).  
- **How to run**: `cd practice_examples/security-policy && ./conftest_k8s.sh` (or the terraform variant) to evaluate policies against sample manifests.

Use these as the linked code artifacts for security tasks in the problem guides.
