# Container Supply Chain: SBOM + Signing Demo

Build an image, generate an SBOM with `syft`, and (optionally) sign with `cosign`.

## Prereqs
- Docker
- syft (optional, for SBOM)
- cosign (optional, for signing)

## Usage
```bash
./build_and_sign.sh myrepo/demo:dev
```
- Builds image from `Dockerfile` (non-root, slim).
- Generates `sbom.json` if syft is installed.
- Signs the image if cosign is installed and `COSIGN_KEY`/`COSIGN_PASSWORD` are configured (or keyless envs set).

## Notes
- Script is idempotent and will skip steps when tools/keys are missing, with clear messages.
- Intended as a pattern; integrate into CI (GitHub Actions/GitLab/Azure) for enforcement.
