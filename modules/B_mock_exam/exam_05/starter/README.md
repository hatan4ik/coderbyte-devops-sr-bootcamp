# Exam 05 - Advanced CI/CD with Jenkins

## Overview
Production Jenkins pipeline with security scanning, testing, and deployment.

## Local Development

### Run Tests
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r app/requirements.txt
pip install pytest pytest-cov

pytest tests/ -v
```

### Run Application
```bash
source venv/bin/activate
python app/app.py

# Test
curl http://localhost:8000/health
```

### Docker Build
```bash
docker build -t exam05-api:latest .
docker run -p 8000:8000 exam05-api:latest
```

## Pipeline Stages

### 1. Checkout
- Clone repository
- Capture commit ID

### 2. Install Dependencies
- Create Python virtual environment
- Install application dependencies
- Install testing tools

### 3. Lint
- Run flake8 for code quality
- Enforce style guidelines
- Fail on violations

### 4. Unit Tests
- Run pytest with coverage
- Generate JUnit XML reports
- Publish coverage reports
- Fail on test failures

### 5. Build Image
- Build Docker image
- Tag with specified version
- Use multi-stage build

### 6. Security Scan
- **Trivy**: Scan for CVEs
- **Hadolint**: Lint Dockerfile
- Fail on HIGH/CRITICAL issues

### 7. Push Image
- Authenticate to registry
- Push tagged image
- Only on main branch

### 8. Deploy
- Update Kubernetes deployment
- Wait for rollout completion
- Only on main branch

## Pipeline Parameters

- **IMAGE_TAG**: Docker image tag (default: latest)
- **REGISTRY**: Container registry URL

## Quality Gates

✅ Code must pass linting
✅ All tests must pass
✅ Coverage threshold enforced
✅ No HIGH/CRITICAL vulnerabilities
✅ Dockerfile best practices

## Local Pipeline Simulation

```bash
# Lint
flake8 app/ --max-line-length=120

# Test
pytest tests/ -v --cov=app

# Build
docker build -t exam05-api:test .

# Scan
trivy image exam05-api:test
hadolint Dockerfile
```

## Jenkins Setup

1. Install plugins: Docker, Pipeline, JUnit, Coverage
2. Configure credentials for registry
3. Create pipeline job pointing to Jenkinsfile
4. Set parameters as needed
5. Run pipeline

## Security Features

- Non-root container
- Multi-stage build
- Vulnerability scanning
- Secrets via credentials
- Image signing ready
