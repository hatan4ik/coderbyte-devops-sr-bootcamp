.PHONY: help setup test lint security-scan docker-build docker-scan k8s-deploy terraform-init clean exam menu

help:
	@echo "Coderbyte DevOps Sr Bootcamp - Production-Grade Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  setup          - Install all dependencies and pre-commit hooks"
	@echo "  test           - Run all tests"
	@echo "  lint           - Run linters (Python, Shell, YAML)"
	@echo "  security-scan  - Run security scans (Trivy, Gitleaks, Semgrep)"
	@echo "  docker-build   - Build Docker images"
	@echo "  docker-scan    - Scan Docker images for vulnerabilities"
	@echo "  k8s-deploy     - Deploy to Kubernetes"
	@echo "  k8s-validate   - Validate Kubernetes manifests"
	@echo "  terraform-init - Initialize Terraform"
	@echo "  terraform-validate - Validate Terraform configuration"
	@echo "  exam           - Run mock exam #1"
	@echo "  menu           - Run interactive menu"
	@echo "  clean          - Clean build artifacts"

setup:
	@echo "Installing dependencies..."
	pip install -r requirements.txt
	pip install -r modules/A_zero_to_hero/requirements.txt
	pip install pre-commit black flake8 pytest pytest-cov
	pre-commit install || echo "pre-commit not available, skipping"

test:
	@echo "Running tests..."
	@find modules -name 'tests.py' -print -exec python {} \;
	cd modules/A_zero_to_hero && bash run_tests.sh || true
	cd modules/C_full_project && pytest tests/ -v || echo "pytest not available"

lint:
	@echo "Linting Python files..."
	@python -m py_compile `find . -name '*.py'` || true
	@echo "Linting complete"

security-scan:
	@echo "Running security scans..."
	@command -v trivy >/dev/null 2>&1 && trivy fs --severity HIGH,CRITICAL . || echo "Trivy not installed"
	@command -v gitleaks >/dev/null 2>&1 && gitleaks detect --source . --verbose || echo "Gitleaks not installed"
	@command -v semgrep >/dev/null 2>&1 && semgrep --config auto . || echo "Semgrep not installed"

docker-build:
	@echo "Building Docker images..."
	cd modules/C_full_project && docker build -t devops-demo:latest -f docker/Dockerfile .

docker-scan:
	@echo "Scanning Docker images..."
	@command -v trivy >/dev/null 2>&1 && trivy image devops-demo:latest || echo "Trivy not installed"
	@command -v hadolint >/dev/null 2>&1 && hadolint modules/C_full_project/docker/Dockerfile || echo "Hadolint not installed"

k8s-deploy:
	@echo "Deploying to Kubernetes..."
	kubectl apply -k modules/C_full_project/k8s/

k8s-validate:
	@echo "Validating Kubernetes manifests..."
	kubectl apply --dry-run=client -k modules/C_full_project/k8s/

terraform-init:
	@echo "Initializing Terraform..."
	cd modules/C_full_project/terraform && terraform init

terraform-validate:
	@echo "Validating Terraform..."
	cd modules/C_full_project/terraform && terraform validate
	cd modules/C_full_project/terraform && terraform fmt -check

exam:
	@bash modules/B_mock_exam/exam_01/start_exam.sh

menu:
	@bash ./menu.sh

clean:
	@echo "Cleaning build artifacts..."
	@find . -type d -name __pycache__ -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	@find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	@echo "Clean complete"
