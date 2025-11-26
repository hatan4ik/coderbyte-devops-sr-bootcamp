SHELL := /bin/bash

IMAGE_NAME ?= devops-demo
IMAGE_TAG  ?= latest
REGISTRY   ?=
IMAGE      := $(if $(REGISTRY),$(REGISTRY)/,)$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: help build test run clean docker-build docker-run docker-scan k8s-deploy k8s-delete terraform-init terraform-plan terraform-apply terraform-destroy lint fmt

help:
	@echo "Available targets:"
	@echo "  build          - Build the application"
	@echo "  test           - Run tests"
	@echo "  run            - Run application locally"
	@echo "  docker-build   - Build Docker image"
	@echo "  docker-run     - Run Docker container"
	@echo "  k8s-deploy     - Deploy to Kubernetes"
	@echo "  terraform-init - Initialize Terraform"
	@echo "  terraform-plan - Plan Terraform changes"
	@echo "  terraform-apply- Apply Terraform changes"
	@echo "  terraform-destroy- Destroy Terraform stack"
	@echo "  lint           - Run code linting (ruff if available)"
	@echo "  fmt            - Format code (black if available)"

build:
	python -m pip install --upgrade pip
	python -m pip install -r app/requirements.txt

test:
	python -m pytest tests/ -v

run:
	python app/app.py

docker-build:
	docker build -t $(IMAGE) -f docker/Dockerfile .

docker-run:
	docker run -p 8000:8000 --rm $(IMAGE)

docker-scan:
	@if command -v trivy >/dev/null 2>&1; then trivy image $(IMAGE); else echo "trivy not installed; skipping"; fi

k8s-deploy:
	kubectl apply -k k8s/

k8s-delete:
	kubectl delete -k k8s/

terraform-init:
	cd terraform && terraform init

terraform-plan:
	cd terraform && terraform plan

terraform-apply:
	cd terraform && terraform apply

terraform-destroy:
	cd terraform && terraform destroy

clean:
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
	rm -rf .pytest_cache

lint:
	@if command -v ruff >/dev/null 2>&1; then ruff check app; else echo "ruff not installed; skipping"; fi

fmt:
	@if command -v black >/dev/null 2>&1; then black app; else echo "black not installed; skipping"; fi
