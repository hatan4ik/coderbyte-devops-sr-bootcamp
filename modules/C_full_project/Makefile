.PHONY: help build test run clean docker-build docker-run k8s-deploy terraform-init terraform-plan terraform-apply

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

build:
	pip install -r app/requirements.txt

test:
	python -m pytest tests/ -v

run:
	python app/app.py

docker-build:
	docker build -t devops-demo:latest -f docker/Dockerfile .

docker-run:
	docker run -p 8000:8000 --rm devops-demo:latest

docker-scan:
	trivy image devops-demo:latest

k8s-deploy:
	kubectl apply -f k8s/

k8s-delete:
	kubectl delete -f k8s/

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
