# Container Security Starter

This Dockerfile is intentionally loose. Harden it by moving to a multi-stage build, pinning a slim base, dropping root, and enabling runtime protections (read-only FS, drop capabilities, seccomp/apparmor).

## Local scan
```bash
cd app
../scan.sh ghcr.io/example/container-security:dev
```

## Recommended PodSecurityContext
- `runAsNonRoot: true`, `runAsUser`/`runAsGroup` set
- `readOnlyRootFilesystem: true`
- Drop `NET_RAW`, add only needed caps
- Add seccomp/apparmor profiles
