# Solution – IAM Least Privilege

## Approach
- Replace broad IAM policies with scoped actions/resources and conditions; enforce MFA where applicable.

## Steps
- Audit existing policy; replace `*` with ARNs; separate roles per use case.
- Add conditions (`aws:MultiFactorAuthPresent`, principal tags, source IP/region where appropriate).
- Enable Access Analyzer; rotate access keys; document assumptions.

## Validation
- IAM policy simulator/Access Analyzer show no excessive permissions.
- Attempt forbidden actions to confirm deny.
- `terraform validate`/`cfn-lint` clean; MFA enforced for console paths as needed.
