# Contributing Guidelines

## Code Standards

### Python
- Follow PEP 8
- Use type hints
- Add docstrings
- Handle errors gracefully
- Use structured logging

### Bash
- Use `set -euo pipefail`
- Quote variables
- Check command existence
- Provide usage messages
- Handle errors

### Terraform
- Use variables for configuration
- Add validation rules
- Include descriptions
- Tag all resources
- Use data sources

### Kubernetes
- Set resource limits
- Add security contexts
- Include health probes
- Use labels consistently
- Add documentation

## Security Requirements

- No hardcoded secrets
- Non-root containers
- Minimal base images
- Encrypted storage
- Network policies
- RBAC with least privilege

## Testing

- Unit tests for functions
- Integration tests for APIs
- Security scans before commit
- Validate manifests
- Test error paths

## Documentation

- README in each module
- Inline comments for complex logic
- Architecture diagrams
- Runbooks for operations
- Troubleshooting guides

## Pre-commit Checks

```bash
make lint
make security-scan
make test
```
