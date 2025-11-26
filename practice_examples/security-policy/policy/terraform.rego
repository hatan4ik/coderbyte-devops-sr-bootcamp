package terraform.deny

deny[msg] {
  input.resource_changes[_].type == "aws_s3_bucket"
  not input.resource_changes[_].change.after.bucket
  msg := "S3 bucket name must be set"
}

deny[msg] {
  input.resource_changes[_].type == "aws_s3_bucket"
  enabled := input.resource_changes[_].change.after_server_side_encryption_configuration.rule.apply_server_side_encryption_by_default.sse_algorithm
  enabled == ""
  msg := "S3 bucket must enable SSE"
}

deny[msg] {
  input.resource_changes[_].type == "aws_s3_bucket"
  versioning := input.resource_changes[_].change.after_versioning_configuration.status
  versioning != "Enabled"
  msg := "S3 bucket must enable versioning"
}

deny[msg] {
  input.resource_changes[_].type == "aws_s3_bucket"
  blocks := input.resource_changes[_].change.after_public_access_block
  not blocks.block_public_acls
  msg := "S3 bucket must block public ACLs"
}
