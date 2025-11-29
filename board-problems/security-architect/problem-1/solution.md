# Solution – Non-Root Container

## Approach
- Harden the Dockerfile to run as a non-root user with least privilege and minimal surface.

## Steps
- Use multi-stage build and a slim base; pin versions.
- Create dedicated user/group; set `USER` and `WORKDIR`.
- Drop all capabilities; set seccomp to default; set `readOnlyRootFilesystem`; avoid sudo/shell.
- Copy artifacts with correct ownership; add healthcheck; use explicit `ENTRYPOINT/CMD`.

## Validation
- `docker run` then `id` to confirm non-root.
- `trivy`/`hadolint` clean; app still serves requests.
- Container honors read-only FS; no unexpected privileges.
