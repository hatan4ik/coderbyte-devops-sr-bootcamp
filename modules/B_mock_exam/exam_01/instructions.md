# Mock Exam #1 – Web Service, Docker, Terraform, K8s

## Scenario

You are given a simple Python web service. Your tasks:

1. **App (Python)**
   - Implement an HTTP endpoint `/health` returning JSON `{"status": "ok"}`.
   - Add basic logging on each request.

2. **Docker**
   - Write a production-friendly Dockerfile:
     - Use a slim base image.
     - Install dependencies from `requirements.txt`.
     - Expose port 8000.
     - Bonus: run as non-root user.

3. **Terraform**
   - Write a minimal Terraform configuration that:
     - Defines a variable `environment` (e.g. "dev").
     - Defines a resource for a storage bucket (e.g., `aws_s3_bucket` or mock).
     - Enables versioning.

4. **Kubernetes**
   - Write a Deployment manifest that:
     - Uses your built Docker image.
     - Runs 2 replicas.
     - Exposes container port 8000.
     - Adds liveness and readiness probes on `/health`.

Aim to keep everything clear and commented, as if you hand this to another Sr. DevOps engineer.
