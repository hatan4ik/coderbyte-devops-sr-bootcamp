# Security Policy

## Supported Versions

This is a training repository. Security best practices are demonstrated but not actively maintained for production use.

## Security Best Practices Implemented

### 1. Container Security
- Non-root user execution
- Minimal base images (distroless/alpine)
- Multi-stage builds
- No secrets in images
- Security scanning with Trivy/Snyk

### 2. Kubernetes Security
- Pod Security Standards (restricted)
- Resource limits and requests
- Network policies
- RBAC with least privilege
- Secret management via external secrets
- Security contexts (runAsNonRoot, readOnlyRootFilesystem)

### 3. Infrastructure Security
- Terraform state encryption
- IAM least privilege
- Secrets in AWS Secrets Manager/HashiCorp Vault
- VPC isolation
- Security groups with minimal access

### 4. Code Security
- Dependency scanning
- SAST with Semgrep/SonarQube
- Pre-commit hooks
- No hardcoded credentials
- Input validation

### 5. CI/CD Security
- Signed commits
- Protected branches
- Secrets scanning
- SBOM generation
- Image signing with Cosign

## Reporting a Vulnerability

This is a training repository. For educational purposes only.
