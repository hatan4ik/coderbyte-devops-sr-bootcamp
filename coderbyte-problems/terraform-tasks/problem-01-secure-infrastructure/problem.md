# Problem 1: Secure Insecure Terraform 🔴

**Difficulty**: Hard | **Time**: 45 min | **Points**: 150

## Scenario
Security audit found critical issues. Fix all vulnerabilities.

## Given Code
```hcl
resource "aws_s3_bucket" "data" {
  bucket = "my-data"
}

resource "aws_security_group" "web" {
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_policy" "app" {
  policy = jsonencode({
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}
```

## Critical Issues
1. Public S3 bucket
2. No encryption
3. Wide-open security group
4. Wildcard IAM permissions
5. No versioning
6. No tagging
7. No validation

## Requirements
- Fix all security issues
- Add encryption
- Implement least privilege
- Add lifecycle policies
- Include validation
- Add comprehensive tags

## Success Criteria
- [ ] No public access
- [ ] Encryption enabled
- [ ] Restricted security group
- [ ] Scoped IAM policies
- [ ] Versioning enabled
- [ ] Passes tfsec scan
