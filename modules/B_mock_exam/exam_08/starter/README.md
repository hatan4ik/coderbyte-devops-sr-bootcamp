# Exam 08 - Container Image Security

## Security Hardening Applied

### Dockerfile Improvements
✅ **Multi-stage build** - Separates build and runtime
✅ **Non-root user** - UID 1000, no root access
✅ **Minimal base** - python:3.11-slim (reduced attack surface)
✅ **Pinned versions** - Reproducible builds
✅ **No build tools** - Removed from final image
✅ **Layer optimization** - Minimal layers, efficient caching

### Supply Chain Security
✅ **Vulnerability scanning** - Trivy for CVE detection
✅ **SBOM generation** - Syft for software bill of materials
✅ **Dockerfile linting** - Hadolint for best practices
✅ **Dependency scanning** - Grype for package vulnerabilities
✅ **Image signing** - Cosign ready (optional)

## Local Scanning

### Prerequisites
```bash
# Install tools
brew install trivy hadolint syft grype

# Or use Docker
docker pull aquasec/trivy:latest
docker pull hadolint/hadolint:latest
```

### Run Security Scan
```bash
# Build image
docker build -t secure-app:latest .

# Run comprehensive scan
./scan.sh secure-app:latest

# Individual scans
trivy image secure-app:latest
hadolint Dockerfile
syft secure-app:latest
grype secure-app:latest
```

## Kubernetes Runtime Security

### PodSecurityContext
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault
```

### Container SecurityContext
```yaml
securityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  runAsNonRoot: true
  runAsUser: 1000
  capabilities:
    drop:
      - ALL
      - NET_RAW
      - SYS_ADMIN
```

### Network Policy
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: secure-app
spec:
  podSelector:
    matchLabels:
      app: secure-app
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              role: frontend
      ports:
        - protocol: TCP
          port: 8000
  egress:
    - to:
        - podSelector:
            matchLabels:
              role: database
      ports:
        - protocol: TCP
          port: 5432
```

## CI/CD Integration

### GitHub Actions
```yaml
- name: Build image
  run: docker build -t $IMAGE .

- name: Scan with Trivy
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: $IMAGE
    exit-code: 1
    severity: 'CRITICAL,HIGH'

- name: Generate SBOM
  run: syft $IMAGE -o spdx-json > sbom.json

- name: Upload SBOM
  uses: actions/upload-artifact@v3
  with:
    name: sbom
    path: sbom.json
```

## Security Checklist

### Build Time
- [x] Multi-stage build
- [x] Non-root user
- [x] Minimal base image
- [x] Pinned dependencies
- [x] No secrets in image
- [x] Vulnerability scanning
- [x] SBOM generation

### Runtime
- [x] Read-only root filesystem
- [x] Dropped capabilities
- [x] Seccomp profile
- [x] Network policies
- [x] Resource limits
- [x] Pod security standards
- [x] Service mesh ready

### Supply Chain
- [x] Image signing
- [x] Registry scanning
- [x] Admission control
- [x] Policy enforcement
- [x] Audit logging

## Vulnerability Management

### Severity Levels
- **CRITICAL**: Immediate patching required
- **HIGH**: Patch within 7 days
- **MEDIUM**: Patch within 30 days
- **LOW**: Patch in next release

### Response Process
1. **Detect**: Automated scanning in CI/CD
2. **Assess**: Review CVE details and exploitability
3. **Patch**: Update dependencies or base image
4. **Test**: Verify fix doesn't break functionality
5. **Deploy**: Roll out patched image
6. **Verify**: Rescan to confirm remediation

## Best Practices

### Image Tagging
- Use semantic versioning
- Never use `latest` in production
- Include git commit SHA
- Tag with build date

### Registry Security
- Enable vulnerability scanning
- Implement image signing
- Use private registries
- Enable audit logging
- Implement retention policies

### Runtime Protection
- Use AppArmor/SELinux
- Enable seccomp profiles
- Implement admission controllers
- Use runtime security tools (Falco)
- Monitor for anomalies
