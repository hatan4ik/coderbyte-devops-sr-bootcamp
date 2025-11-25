# Mock Exam #5 – Advanced CI/CD with Jenkins

## Scenario
You need a Jenkins pipeline that builds, tests, scans, and ships a small API. Use declarative Jenkinsfile and make the pipeline parameterized.

## Requirements
1. **Pipeline** (in `starter/Jenkinsfile`)
   - Parameters: `IMAGE_TAG` (default `latest`), `REGISTRY` (e.g., ghcr.io/org/app).
   - Stages: checkout -> deps -> unit tests -> lint -> build image -> security scan (e.g., Trivy) -> push -> deploy (can be a placeholder script).
   - Archive test results and fail fast on quality gates.
2. **App** (in `starter/app`)
   - Python/Flask app exposing `/health` returning `{ "status": "ok" }`.
   - Add a simple unit test under `starter/tests` to validate the endpoint.
3. **Dockerfile**
   - Production-friendly (non-root user, slim base, pinned dependencies).
4. **Docs**
   - `starter/README.md` describing how to run tests locally and how the pipeline stages map to commands.

### Deliverables
- Working Jenkinsfile with minimal placeholder deploy logic.
- App, tests, and Dockerfile wired so the pipeline can run end-to-end locally with Docker.
