# Problem: Terraform State Migration

## Scenario

Your team manually created AWS resources 6 months ago. Bring them under Terraform without recreating.

## Existing Resources

- S3 bucket: `legacy-app-data-prod`
- IAM role: `legacy-app-role`
- CloudWatch log group: `/aws/legacy-app`

## Requirements

1. Import all 3 resources into Terraform state
2. Write matching Terraform configuration
3. Verify `terraform plan` shows no changes
4. Add encryption to S3 bucket (state surgery required)

## Success Criteria

- [ ] All resources imported
- [ ] `terraform plan` output: "No changes"
- [ ] S3 encryption enabled without recreation
- [ ] State file has correct addresses

## Time: 45 minutes

## Hints

- Use `terraform import` for each resource
- Check AWS console for exact attributes
- Use `terraform state show` to inspect
- Consider `terraform state mv` for reorganization
