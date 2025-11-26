# CI Pipeline Example (GitHub Actions)

Demo pipeline that lints, tests, builds, and scans a tiny Python app + Docker image. The workflow is provided as a template you can drop into `.github/workflows/`.

## Files
- `app.py` — trivial app with a health function.
- `tests/test_app.py` — pytest for the app.
- `Dockerfile` — slim, non-root, healthcheck.
- `github-actions.yaml` — sample CI: lint/test → docker build → trivy scan → (conditional) push.
- `requirements.txt` — minimal dependencies.

## Run locally
```bash
cd practice_examples/ci-pipeline
python -m pip install --upgrade pip
python -m pip install -r requirements.txt pytest ruff black
ruff check .
black --check .
pytest -q

docker build -t local/ci-demo:dev .
```

## Workflow (copy to `.github/workflows/ci-demo.yaml`)
- Checkout
- Setup Python 3.11
- Install deps, run ruff + black + pytest
- Build Docker image
- Trivy scan (fails on HIGH/CRIT)
- Conditional push if registry creds are set
