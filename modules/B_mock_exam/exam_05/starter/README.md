# Jenkins Pipeline Starter

## Local smoke test
```bash
cd starter
pip install -r app/requirements.txt pytest flake8
pytest -q tests
flake8 app
docker build -t local/jenkins-demo:dev .
```

## Jenkinsfile notes
- Parameters: `REGISTRY`, `IMAGE_TAG` build final `IMAGE` env.
- Stages: checkout -> deps -> tests -> lint -> build -> (scan placeholder) -> push -> deploy placeholder.
- Replace registry login and deploy commands with your environment specifics.
