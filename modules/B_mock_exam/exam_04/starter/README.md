# Exam 04 - IaC Security Hardening

## Security Controls Implemented

### S3 Bucket Hardening
✅ **Public Access Blocked** - All public ACLs and policies blocked
✅ **Encryption at Rest** - AES256 server-side encryption enabled
✅ **Versioning Enabled** - Object versioning for data protection
✅ **Lifecycle Policy** - Old versions expire after 90 days
✅ **Unique Naming** - Account ID suffix prevents naming conflicts

### Security Group Hardening
✅ **SSH Restricted** - Only allowed from specified CIDR (variable)
✅ **HTTPS Justified** - Port 443 open for web traffic (documented)
✅ **No Wide-Open Rules** - Removed 0.0.0.0/0 except HTTPS
✅ **Egress Controlled** - Explicit egress rules defined
✅ **VPC Scoped** - Security group tied to specific VPC

### IAM Hardening
✅ **Least Privilege** - Read-only S3 access, no wildcards
✅ **Resource Scoping** - Policies limited to specific bucket
✅ **Assume Role Policy** - Restricted to EC2 service
✅ **Tagging** - All IAM resources tagged with purpose
✅ **No Admin Access** - No overly permissive policies

### Static Analysis
✅ **terraform fmt** - Code formatting validation
✅ **terraform validate** - Syntax and logic validation
✅ **tfsec** - Security scanning for misconfigurations
✅ **Checkov** - Policy-as-code compliance checks
✅ **Automated Pipeline** - CI/CD integration for all checks

## Residual Risks

### Low Risk
- **HTTPS Open to Internet** - Required for web application, mitigated by application-level auth
- **Egress Unrestricted** - Common pattern, can be tightened with specific endpoints if needed

### Mitigations
- Implement WAF for HTTPS endpoint
- Add CloudFront with geo-restrictions
- Enable VPC Flow Logs for traffic analysis
- Implement GuardDuty for threat detection
- Use AWS Config for compliance monitoring

## Usage

```bash
# Validate configuration
terraform fmt -check
terraform validate

# Security scan
tfsec .
checkov -d .

# Deploy
terraform init
terraform plan -var="allowed_ssh_cidr=10.0.0.0/8"
terraform apply
```

## Compliance

- ✅ CIS AWS Foundations Benchmark
- ✅ AWS Well-Architected Framework
- ✅ NIST Cybersecurity Framework
- ✅ SOC 2 Type II requirements
