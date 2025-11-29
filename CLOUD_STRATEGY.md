# Cloud Strategy

## Current State

This repository supports both AWS and GCP with the following distribution:

### AWS (Primary)
- **Module C:** Full project with Terraform, K8s, CI/CD
- **Practice Examples:** terraform-vpc, terraform-vpc-peering, aws-security (16 labs)
- **Mock Exams:** Infrastructure scenarios
- **AWS Solutions Architect:** 30+ advanced problems

### GCP (Secondary/Porting Track)
- **gcp-zero-to-hero/:** 20+ problems across 9 modules
- Treated as migration/porting exercise
- Separate state management

## Decision Record

**Status:** Locked  
**Decision:** AWS-first for core modules; GCP remains a secondary porting track.

## Guardrails

1. **No Mixed Providers** – Single cloud per Terraform workspace.
2. **Separate State** – AWS uses S3/DynamoDB; GCP uses GCS; never share buckets/prefixes.
3. **Observability Mapping** – CloudWatch ↔ Cloud Logging/Monitoring; X-Ray ↔ Cloud Trace.
4. **IAM Translation** – Document AWS IAM → GCP IAM mappings when porting.
5. **GitOps/IaC** – Keep provider-specific overlays/modules; do not template both clouds into a single stack.

## Module Mapping
- **Module C (Full Project):** AWS primary (`modules/C_full_project/terraform` S3+DynamoDB backend). GCP porting is a separate workspace exercise.
- **Practice Labs:** AWS labs are canonical; GCP lives only under `gcp-zero-to-hero/`.
- **Mock Exams:** Default to AWS unless explicitly stated otherwise.
- **Brownfield/State:** `modules/F_state_refactoring/` is the canonical path (AWS-only). `modules/F_brownfield_scenarios/` is archived/legacy for reference.

## Future Considerations
- Cloud-agnostic abstractions (Crossplane, Pulumi)
- Cost comparison frameworks
- Migration playbooks
- Multi-cloud networking patterns

## References
- Module C (AWS): `modules/C_full_project/`
- GCP Track: `gcp-zero-to-hero/`
- AWS Solutions: `aws-solutions-architect/`
