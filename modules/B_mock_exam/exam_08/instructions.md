# Mock Exam #8 – Container Image Security

## Scenario
You are handed an insecure container build. Harden it and add supply chain checks.

## Requirements
1. **Dockerfile hardening** (in `starter/app`)
   - Convert to a multi-stage build.
   - Run as non-root, minimize layers, pin versions.
   - Remove build tools and secrets from the final image.
2. **Scanning**
   - Add a script or pipeline snippet to run `trivy` (or similar) on the built image and fail on critical findings.
3. **SBOM**
   - Generate an SBOM (e.g., `syft`) as part of the build/pipeline and store as an artifact.
4. **Runtime**
   - Document recommended Kubernetes PodSecurityContext settings (readOnlyRootFilesystem, drop NET_RAW, etc.).
5. **Docs**
   - Capture the changes and how to run the scan locally in `starter/README.md`.

### Deliverables
- Hardened Dockerfile and app code in `starter/app`.
- Scan/SBOM helper script.
- Documentation of runtime security settings.
