# 🎯 Coderbyte DevOps Assessment Mastery Guide
## Zero → Hero → Offer Letter

---

## 🏛️ Board Members & Roles

### The Quorum (Your Expert Panel)

**1. Security Architect (Sarah Chen)**
- Focus: Container security, IAM, secrets management
- Mantra: "If it's not encrypted, it's not production"
- Key Skills: Zero-trust, least privilege, vulnerability scanning

**2. Site Reliability Engineer (Marcus Rodriguez)**
- Focus: Observability, SLOs, incident response
- Mantra: "Measure everything, alert on what matters"
- Key Skills: Prometheus, Grafana, on-call excellence

**3. Platform Engineer (Aisha Patel)**
- Focus: Kubernetes, GitOps, developer experience
- Mantra: "Make the right thing the easy thing"
- Key Skills: ArgoCD, Kustomize, self-service platforms

**4. Infrastructure Architect (David Kim)**
- Focus: Terraform, cloud architecture, cost optimization
- Mantra: "Infrastructure is code, treat it like software"
- Key Skills: Multi-cloud, IaC patterns, FinOps

**5. CI/CD Specialist (Elena Volkov)**
- Focus: Pipelines, automation, quality gates
- Mantra: "Ship fast, ship safe, ship often"
- Key Skills: Jenkins, GitHub Actions, security scanning

---

## 📋 Assessment Types (What You Will Face)

### Type 1: Live Coding (60-90 minutes)
**Format**: Screen share, real-time problem solving
**Topics**:
- Write Dockerfile from scratch
- Debug broken Kubernetes manifest
- Create Terraform module
- Build CI/CD pipeline
- Parse logs with Python/Bash

**Evaluation Criteria**:
- ✅ Code quality and organization
- ✅ Security best practices
- ✅ Error handling
- ✅ Documentation
- ✅ Time management

### Type 2: Take-Home Project (2-4 hours)
**Format**: Complete project, submit via Git
**Common Tasks**:
- Deploy full-stack application
- Implement GitOps workflow
- Harden infrastructure
- Add observability
- Write runbooks

**Evaluation Criteria**:
- ✅ Production readiness
- ✅ Security controls
- ✅ Documentation quality
- ✅ Testing coverage
- ✅ Best practices adherence

### Type 3: System Design (45-60 minutes)
**Format**: Whiteboard/diagram discussion
**Topics**:
- Design CI/CD pipeline
- Plan disaster recovery
- Architect multi-region deployment
- Design monitoring strategy
- Plan migration to cloud

**Evaluation Criteria**:
- ✅ Scalability considerations
- ✅ Security architecture
- ✅ Cost awareness
- ✅ Trade-off analysis
- ✅ Communication clarity

### Type 4: Debugging Challenge (30-45 minutes)
**Format**: Fix broken system
**Scenarios**:
- Pod crash loops
- Terraform state issues
- Pipeline failures
- Performance problems
- Security vulnerabilities

**Evaluation Criteria**:
- ✅ Systematic approach
- ✅ Tool proficiency
- ✅ Root cause analysis
- ✅ Fix quality
- ✅ Prevention mindset

---

## 🚀 Zero → Hero Skill Plan

### Week 1-2: Foundations (Zero → Competent)

#### Day 1-3: Container Mastery
```bash
# Master these commands
docker build -t app:v1 .
docker run -p 8080:8080 --rm app:v1
docker exec -it container_id sh
docker logs -f container_id
docker inspect container_id
docker system prune -a

# Practice: Build 5 different Dockerfiles
# - Python Flask app
# - Node.js API
# - Go binary
# - Static site (nginx)
# - Multi-stage build
```

**Key Concepts**:
- Multi-stage builds
- Non-root users
- Layer caching
- .dockerignore
- Health checks

#### Day 4-7: Kubernetes Fundamentals
```bash
# Master these commands
kubectl get pods -A
kubectl describe pod <name>
kubectl logs -f <pod>
kubectl exec -it <pod> -- sh
kubectl apply -f manifest.yaml
kubectl delete -f manifest.yaml
kubectl port-forward svc/<name> 8080:80
kubectl get events --sort-by=.metadata.creationTimestamp

# Practice: Deploy 3 applications
# - Stateless web app
# - Stateful database
# - Background worker
```

**Key Concepts**:
- Deployments vs StatefulSets
- Services (ClusterIP, NodePort, LoadBalancer)
- ConfigMaps and Secrets
- Resource limits
- Health probes

#### Day 8-10: Infrastructure as Code
```bash
# Master Terraform workflow
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
terraform destroy
terraform state list
terraform state show <resource>

# Practice: Create 3 modules
# - VPC with subnets
# - S3 bucket with policies
# - EKS cluster
```

**Key Concepts**:
- State management
- Variables and outputs
- Modules
- Remote backends
- Workspaces

#### Day 11-14: CI/CD Pipelines
```yaml
# Master pipeline patterns
# - Lint → Test → Build → Scan → Deploy
# - Parallel stages
# - Conditional execution
# - Artifact management
# - Secret handling

# Practice: Build 3 pipelines
# - GitHub Actions
# - GitLab CI
# - Jenkins
```

**Key Concepts**:
- Pipeline as code
- Security scanning
- Deployment strategies
- Rollback procedures
- Quality gates

### Week 3-4: Advanced (Competent → Proficient)

#### Advanced Kubernetes
- Custom Resource Definitions (CRDs)
- Operators and controllers
- Network policies
- Pod security policies
- Service mesh basics (Istio/Linkerd)

#### Advanced Terraform
- Dynamic blocks
- For_each and count
- Data sources
- Provisioners (when to avoid)
- Testing with Terratest

#### Observability
- Prometheus metrics
- Grafana dashboards
- Alert rules
- Log aggregation (ELK/Loki)
- Distributed tracing

#### Security
- Container scanning (Trivy)
- SAST/DAST tools
- Secret management (Vault)
- RBAC implementation
- Compliance scanning

---

## 🛠 Real-World Projects (Zero → Hero with Problem → Solution)

### 1) Containers & Supply Chain
- **Zero (Problem):** Legacy Dockerfile runs as root, huge image, no healthcheck.  
  **Solution:** Multi-stage `python:3.11-slim`, non-root user, `.dockerignore`, `HEALTHCHECK`, pinned deps, `hadolint` + `trivy` pass.
- **Hero (Problem):** Need signed artifacts and SBOM for prod image.  
  **Solution:** Build with cache, generate SBOM via `syft`, sign with `cosign`, enforce policy (Gatekeeper/Conftest), publish provenance attestation.

### 2) Kubernetes Deployment Hardening
- **Zero:** Deployment missing probes/limits; pods restart randomly.  
  **Solution:** Add liveness/readiness/startup probes, requests/limits, PDB=1, HPA min=2, anti-affinity, seccomp `RuntimeDefault`, `runAsNonRoot`, `readOnlyRootFilesystem`.
- **Hero:** Lock down traffic and releases.  
  **Solution:** NetworkPolicy default deny + ingress from ingress-controller/monitoring; Kustomize overlays per env; canary/blue-green rollout; kubeconform validation; ArgoCD sync with auto-heal/prune.

### 3) Terraform & Cloud Foundation
- **Zero:** Create S3 bucket with encryption/versioning and block public access.  
  **Solution:** Bucket + SSE + versioning + public access block + tags; fmt/validate/tflint/tfsec clean.
- **Hero:** Minimal landing zone.  
  **Solution:** VPC (public/private), IGW/NAT, SG least privilege, IAM roles with OIDC, DynamoDB/S3 remote state with locking, tfsec/Checkov clean, module + tfvars per env.

### 4) CI/CD Pipelines
- **Zero:** Build-and-test GitHub Action.  
  **Solution:** Lint (ruff/black/yamllint/shellcheck/hadolint) → pytest → docker build → trivy image scan → terraform fmt/validate/tflint/tfsec; push only if creds set.
- **Hero:** Multi-platform, gated delivery.  
  **Solution:** Matrix (amd64/arm64) with cache, SBOM + cosign signing, SARIF upload, environments with approvals, deploy step triggering ArgoCD/Helm, reusable workflows/templates.

### 5) Observability & SRE
- **Zero:** Add `/metrics` and structured logs to a Flask/Go service.  
  **Solution:** Prometheus client with request count/latency/error metrics, JSON logs with request IDs, `/health` and `/ready`, basic dashboards/alerts (error rate >5%, p95>500ms).
- **Hero:** SLOs + alert hygiene.  
  **Solution:** Define SLIs/SLOs, burn-rate alerts, exemplars/tracing headers, runbook linking, synthetic checks, P99/p50 dashboards, log sampling for noise reduction.

### 6) Security/DevSecOps
- **Zero:** Remove secrets from code; add scanning.  
  **Solution:** Env/secret manager, gitleaks, semgrep ruleset, dependency check, enforce TLS endpoints, least privilege IAM.
- **Hero:** Policy as code + supply-chain.  
  **Solution:** OPA/Conftest on K8s/Terraform, signed images + attestations, periodic CVE triage workflow, renovate/dependabot for updates, MDR for alerts.

### 7) Scripting & Data Plumbing (Bash/Python/Go)
- **Zero:** Log parser counts ERRORs.  
  **Solution:** Regex extract, JSON output, CLI args/usage, tests/fixtures, handles missing files, stable ordering.
- **Hero:** Streaming/large-file safe.  
  **Solution:** Generator/iterators, concurrency for multiple files, metrics on throughput/errors, output to S3 with retries/backoff, structured logging, unit/integration tests.

**Repo examples you can run now:**
- Bash top IPs: `practice_examples/bash-top-ips/` (`./top_ips.sh access.log [N]`, `./tests.sh`).
- Python concurrent fetcher: `practice_examples/python-concurrent-fetch/` (`python fetch.py <urls>`, `python tests.py`).
- Go HTTP service: `practice_examples/go-http-service/` (`go run ./...`, `go test ./...`).
- Container SBOM/signing demo: `practice_examples/container-sbom/` (`./build_and_sign.sh <image>`).
- K8s hardening bundle: `practice_examples/k8s-hardening/` (kustomize apply/validate).
- K8s canary demo: `practice_examples/k8s-canary/` (stable + canary Deployments, shared Service, NetPol).
- Terraform VPC starter: `practice_examples/terraform-vpc/` (fmt/validate/plan).
- CI pipeline demo (GitHub Actions): `practice_examples/ci-pipeline/` (ruff/black/pytest → docker build → trivy scan; template workflow in `github-actions.yaml`).
- Security policy demo: `practice_examples/security-policy/` (Conftest/OPA policies for k8s+Terraform, cosign verification helper).

### Week 5-6: Expert (Proficient → Hero)

#### Production Patterns
- Blue-green deployments
- Canary releases
- Feature flags
- Circuit breakers
- Rate limiting

#### Incident Response
- On-call procedures
- Runbook creation
- Post-mortem writing
- SLO/SLA management
- Error budgets

#### Architecture
- Multi-region design
- Disaster recovery
- Cost optimization
- Performance tuning
- Capacity planning

---

## 💡 Exact Techniques to Pass Coding Challenges

### Technique 1: The 5-Minute Framework

**Before Writing Code**:
```
1. Read requirements TWICE (30 seconds)
2. Ask clarifying questions (1 minute)
3. Outline approach (2 minutes)
4. Identify edge cases (1 minute)
5. Plan testing strategy (30 seconds)
```

### Technique 2: Security-First Checklist

**Every Solution Must Have**:
```yaml
Security Checklist:
  - [ ] Non-root user (UID 1000)
  - [ ] No hardcoded secrets
  - [ ] Input validation
  - [ ] Error handling
  - [ ] Least privilege access
  - [ ] Encrypted data at rest
  - [ ] TLS for data in transit
  - [ ] Audit logging
```

### Technique 3: Production-Ready Template

**Dockerfile Template**:
```dockerfile
# Multi-stage build
FROM python:3.11-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
RUN groupadd -r app && useradd -r -g app -u 1000 app
WORKDIR /app
COPY --from=builder /root/.local /home/app/.local
COPY --chown=app:app . .
USER app
ENV PATH=/home/app/.local/bin:$PATH \
    PYTHONUNBUFFERED=1
EXPOSE 8000
HEALTHCHECK CMD curl -f http://localhost:8000/health || exit 1
CMD ["python", "-u", "app.py"]
```

**Kubernetes Deployment Template**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  labels:
    app: app
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: app
  template:
    metadata:
      labels:
        app: app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        fsGroup: 1000
      containers:
      - name: app
        image: app:latest
        ports:
        - containerPort: 8000
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop: [ALL]
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 5
          periodSeconds: 5
        volumeMounts:
        - name: tmp
          mountPath: /tmp
      volumes:
      - name: tmp
        emptyDir: {}
```

**Terraform Module Template**:
```hcl
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "environment" {
  type        = string
  description = "Environment name"
  validation {
    condition     = contains(["dev", "stage", "prod"], var.environment)
    error_message = "Must be dev, stage, or prod"
  }
}

resource "aws_s3_bucket" "main" {
  bucket = "app-${var.environment}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}

output "bucket_name" {
  value = aws_s3_bucket.main.id
}
```

### Technique 4: Time Management Matrix

**90-Minute Assessment Breakdown**:
```
0-5 min:   Read requirements, ask questions
5-15 min:  Plan architecture, outline solution
15-60 min: Implement core functionality
60-75 min: Add security, error handling
75-85 min: Test, document, cleanup
85-90 min: Final review, submit
```

### Technique 5: Communication Protocol

**What to Say During Live Coding**:
```
✅ "Let me start by understanding the requirements..."
✅ "I'll use a multi-stage build for security and size..."
✅ "I'm adding error handling here because..."
✅ "For production, I'd also add..."
✅ "Let me test this edge case..."

❌ "Umm... I'm not sure..."
❌ Long silences
❌ "I usually Google this..."
❌ "This should work..." (without testing)
```

---

## 🎯 DevOps-Specific Tasks Coderbyte Uses

### Category 1: Container Tasks (30% of assessments)

**Task 1.1: Optimize Dockerfile**
```
Given: Bloated Dockerfile (1.5GB image)
Goal: Reduce to <200MB, add security
Time: 20 minutes

Key Points:
- Multi-stage build
- Alpine/slim base
- Non-root user
- No secrets
- Health check
```

**Task 1.2: Debug Container**
```
Given: Crashing container
Goal: Fix and explain root cause
Time: 15 minutes

Common Issues:
- Missing dependencies
- Wrong user permissions
- Port conflicts
- Resource limits
- Health check failures
```

### Category 2: Kubernetes Tasks (35% of assessments)

**Task 2.1: Fix Broken Deployment**
```yaml
# Common issues to spot:
- Missing resource limits
- No health probes
- Wrong image pull policy
- Incorrect selectors
- Missing security contexts
- Wrong service type
```

**Task 2.2: Implement GitOps**
```
Given: Manual deployment process
Goal: Implement ArgoCD + Kustomize
Time: 60 minutes

Deliverables:
- Base manifests
- Dev/prod overlays
- ArgoCD application
- Documentation
```

### Category 3: Terraform Tasks (20% of assessments)

**Task 3.1: Secure Infrastructure**
```
Given: Insecure Terraform code
Goal: Add security controls
Time: 30 minutes

Must Fix:
- Public S3 buckets
- Wide-open security groups
- No encryption
- Wildcard IAM policies
- No versioning
```

**Task 3.2: Create Reusable Module**
```
Given: Monolithic main.tf
Goal: Extract to module
Time: 25 minutes

Requirements:
- Variables with validation
- Outputs
- README
- Examples
```

### Category 4: CI/CD Tasks (15% of assessments)

**Task 4.1: Build Pipeline**
```yaml
# Required stages:
1. Lint (code quality)
2. Test (unit + integration)
3. Build (Docker image)
4. Scan (security)
5. Deploy (K8s)

# Must include:
- Parallel execution
- Caching
- Secrets handling
- Failure notifications
```

**Task 4.2: Add Security Scanning**
```
Given: Basic pipeline
Goal: Add comprehensive security
Time: 20 minutes

Add:
- Trivy (container scan)
- Semgrep (SAST)
- Gitleaks (secrets)
- tfsec (IaC)
```

---

## 📝 Mock Questions + Perfect Answers

### Question 1: "Deploy a Python Flask app to Kubernetes"

**Perfect Answer Structure**:

```bash
# 1. Show understanding (30 seconds)
"I'll create a production-ready deployment with:
- Multi-stage Docker build
- Security contexts
- Health probes
- Resource limits
- Horizontal scaling"

# 2. Create Dockerfile (5 minutes)
cat > Dockerfile << 'EOF'
FROM python:3.11-slim AS builder
WORKDIR /build
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

FROM python:3.11-slim
RUN groupadd -r app && useradd -r -g app -u 1000 app
WORKDIR /app
COPY --from=builder /root/.local /home/app/.local
COPY --chown=app:app app.py .
USER app
ENV PATH=/home/app/.local/bin:$PATH PYTHONUNBUFFERED=1
EXPOSE 8000
HEALTHCHECK CMD curl -f http://localhost:8000/health || exit 1
CMD ["python", "-u", "app.py"]
EOF

# 3. Create K8s manifests (10 minutes)
cat > deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: flask-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: flask-app
  template:
    metadata:
      labels:
        app: flask-app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
      containers:
      - name: flask
        image: flask-app:latest
        ports:
        - containerPort: 8000
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 500m
            memory: 512Mi
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          capabilities:
            drop: [ALL]
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
        readinessProbe:
          httpGet:
            path: /health
            port: 8000
        volumeMounts:
        - name: tmp
          mountPath: /tmp
      volumes:
      - name: tmp
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: flask-app
spec:
  selector:
    app: flask-app
  ports:
  - port: 80
    targetPort: 8000
EOF

# 4. Deploy and verify (3 minutes)
docker build -t flask-app:latest .
kubectl apply -f deployment.yaml
kubectl rollout status deployment/flask-app
kubectl get pods -l app=flask-app

# 5. Explain production additions (2 minutes)
"For production, I'd add:
- HPA for auto-scaling
- PDB for high availability
- Network policies for security
- Prometheus metrics
- Ingress with TLS"
```

### Question 2: "Debug why pods are crash looping"

**Perfect Answer (Systematic Approach)**:

```bash
# 1. Check pod status
kubectl get pods
# Output: flask-app-xxx  0/1  CrashLoopBackOff

# 2. Describe pod for events
kubectl describe pod flask-app-xxx
# Look for: Image pull errors, OOMKilled, Liveness probe failures

# 3. Check logs
kubectl logs flask-app-xxx
kubectl logs flask-app-xxx --previous  # Previous container

# 4. Common fixes:

# Fix 1: Image pull error
kubectl get pod flask-app-xxx -o yaml | grep image:
# Solution: Fix image name or add imagePullSecrets

# Fix 2: Application crash
kubectl logs flask-app-xxx
# Solution: Fix application code or dependencies

# Fix 3: Liveness probe too aggressive
kubectl get pod flask-app-xxx -o yaml | grep -A 5 livenessProbe
# Solution: Increase initialDelaySeconds

# Fix 4: Resource limits too low
kubectl top pod flask-app-xxx
# Solution: Increase memory/CPU limits

# Fix 5: Missing volume mounts
kubectl exec -it flask-app-xxx -- ls /app
# Solution: Add required volumes

# 5. Verify fix
kubectl delete pod flask-app-xxx  # Force restart
kubectl get pods -w  # Watch status
```

### Question 3: "Secure this Terraform code"

**Given Code (Insecure)**:
```hcl
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket"
}

resource "aws_security_group" "web" {
  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_policy" "app" {
  policy = jsonencode({
    Statement = [{
      Effect   = "Allow"
      Action   = "*"
      Resource = "*"
    }]
  })
}
```

**Perfect Answer**:
```hcl
# 1. Secure S3 bucket
resource "aws_s3_bucket" "data" {
  bucket = "my-data-bucket-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 2. Secure security group
variable "allowed_cidr" {
  type        = string
  description = "Allowed CIDR for access"
  default     = "10.0.0.0/8"
}

resource "aws_security_group" "web" {
  name        = "web-sg"
  description = "Web server security group"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.web.id
  description       = "HTTPS from allowed CIDR"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.allowed_cidr
}

# 3. Secure IAM policy
resource "aws_iam_policy" "app" {
  name        = "app-policy"
  description = "Least privilege policy for app"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = "${aws_s3_bucket.data.arn}/*"
    }]
  })
}

data "aws_caller_identity" "current" {}

# Explanation:
# - S3: Added encryption, versioning, public access block
# - SG: Restricted to specific CIDR, only HTTPS
# - IAM: Scoped to specific actions and resources
```

### Question 4: "Implement observability for this service"

**Perfect Answer**:

```python
# 1. Add Prometheus metrics to app
from flask import Flask
from prometheus_client import Counter, Histogram, generate_latest

app = Flask(__name__)

REQUEST_COUNT = Counter('http_requests_total', 'Total requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('http_request_duration_seconds', 'Request latency', ['method', 'endpoint'])

@app.before_request
def before_request():
    request.start_time = time.time()

@app.after_request
def after_request(response):
    latency = time.time() - request.start_time
    REQUEST_LATENCY.labels(method=request.method, endpoint=request.path).observe(latency)
    REQUEST_COUNT.labels(method=request.method, endpoint=request.path, status=response.status_code).inc()
    return response

@app.route('/metrics')
def metrics():
    return generate_latest()

@app.route('/health')
def health():
    return {"status": "healthy"}
```

```yaml
# 2. Add Prometheus scrape config
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
    scrape_configs:
      - job_name: 'flask-app'
        kubernetes_sd_configs:
          - role: pod
        relabel_configs:
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
```

```yaml
# 3. Add alert rules
groups:
  - name: flask_alerts
    rules:
      - alert: HighErrorRate
        expr: |
          sum(rate(http_requests_total{status=~"5.."}[5m])) 
          / 
          sum(rate(http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
      
      - alert: HighLatency
        expr: |
          histogram_quantile(0.95, 
            sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
          ) > 1.0
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "High latency detected"
```

```
# 4. Grafana dashboard queries
# Panel 1: Request Rate
sum(rate(http_requests_total[5m])) by (endpoint)

# Panel 2: Error Rate
sum(rate(http_requests_total{status=~"5.."}[5m])) 
/ 
sum(rate(http_requests_total[5m]))

# Panel 3: P95 Latency
histogram_quantile(0.95, 
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le)
)

# Panel 4: Status Codes
sum(rate(http_requests_total[5m])) by (status)
```

---

## 🗺️ Full Training Roadmap

### Phase 1: Foundation (Weeks 1-2)
**Goal**: Build core competencies

**Daily Schedule**:
- Morning (2 hours): Theory + Documentation
- Afternoon (3 hours): Hands-on practice
- Evening (1 hour): Review + Mock questions

**Week 1 Focus**:
- Day 1-2: Docker mastery
- Day 3-4: Kubernetes basics
- Day 5-6: Terraform fundamentals
- Day 7: Review + Mini assessment

**Week 2 Focus**:
- Day 8-9: CI/CD pipelines
- Day 10-11: Security basics
- Day 12-13: Observability
- Day 14: Review + Mock exam

### Phase 2: Advanced (Weeks 3-4)
**Goal**: Master production patterns

**Week 3 Focus**:
- Advanced Kubernetes (CRDs, Operators)
- Complex Terraform (modules, workspaces)
- Security hardening
- Performance optimization

**Week 4 Focus**:
- GitOps workflows
- Multi-cloud patterns
- Disaster recovery
- Cost optimization

### Phase 3: Mastery (Weeks 5-6)
**Goal**: Achieve expert level

**Week 5 Focus**:
- Mock assessments (daily)
- Code review practice
- System design exercises
- Interview simulations

**Week 6 Focus**:
- Final mock exams
- Weak area reinforcement
- Speed optimization
- Confidence building

### Daily Practice Routine

**Morning (7-9 AM)**:
```
1. Review one concept (30 min)
2. Read documentation (30 min)
3. Watch expert video (30 min)
4. Take notes (30 min)
```

**Afternoon (1-4 PM)**:
```
1. Hands-on lab (90 min)
2. Build mini-project (60 min)
3. Debug challenge (30 min)
```

**Evening (7-8 PM)**:
```
1. Mock question (20 min)
2. Review solution (20 min)
3. Document learnings (20 min)
```

### Assessment Simulation Schedule

**Week 3**: 2 mock assessments
**Week 4**: 3 mock assessments
**Week 5**: 5 mock assessments
**Week 6**: Daily mock assessments

### Success Metrics

**Week 2 Checkpoint**:
- [ ] Can write Dockerfile in <10 minutes
- [ ] Can deploy to K8s in <15 minutes
- [ ] Can create Terraform module in <20 minutes
- [ ] Can build CI/CD pipeline in <30 minutes

**Week 4 Checkpoint**:
- [ ] Pass 70% of mock assessments
- [ ] Complete tasks in allocated time
- [ ] Implement all security controls
- [ ] Write production-quality code

**Week 6 Checkpoint**:
- [ ] Pass 90% of mock assessments
- [ ] Complete tasks 20% faster
- [ ] Zero security issues
- [ ] Clear communication

---

## 🎓 Final Tips for Success

### The Night Before
1. Review templates (Dockerfile, K8s, Terraform)
2. Practice typing common commands
3. Get 8 hours of sleep
4. Prepare environment (IDE, tools)

### During Assessment
1. **Read twice, code once**
2. **Ask clarifying questions**
3. **Start with security**
4. **Test as you go**
5. **Document your decisions**
6. **Leave time for review**

### Red Flags to Avoid
❌ Hardcoded secrets
❌ Running as root
❌ No error handling
❌ Missing documentation
❌ Skipping tests
❌ No security controls
❌ Poor time management

### Green Flags to Show
✅ Security-first mindset
✅ Production-ready code
✅ Clear communication
✅ Systematic debugging
✅ Best practices adherence
✅ Documentation quality
✅ Time management

---

## 🏆 Offer Letter Checklist

Before you're ready:
- [ ] Complete all 10 mock exams
- [ ] Pass 90%+ of practice assessments
- [ ] Can explain every decision
- [ ] Know templates by heart
- [ ] Comfortable with live coding
- [ ] Strong system design skills
- [ ] Excellent communication
- [ ] Confident under pressure

**You're ready when**: You can complete any assessment with time to spare and explain every line of code you write.

---

**Remember**: Coderbyte assessments test both technical skills AND production mindset. Show them you think like a senior engineer who ships to production daily.

**Good luck! 🚀**

---

## 🧩 Domain Practice Problems (Problem → Solution → Tests)

### Bash/Linux
- **Problem:** Parse log and emit top 5 IPs with counts.  
  **Solution:** `awk '{print $1}' | sort | uniq -c | sort -nr | head -5`; add arg validation and usage.  
  **Test:** Fixture log; assert lines count; handle missing file (exit 1).
- **Problem:** Service check with retry/backoff.  
  **Solution:** loop with `curl -fsS`, exponential backoff, timeout; exit non-zero on failure.  
  **Test:** Mock HTTP server returning 500 then 200; assert exit code.

### Python
- **Problem:** Filter JSON array by predicate, support stdin/file.  
  **Solution:** `argparse`, load JSON, filter with lambda, print pretty JSON; handle decode errors.  
  **Test:** Parametrized pytest for stdin/file; invalid JSON raises SystemExit.
- **Problem:** Concurrent URL fetch with timeout & metrics.  
  **Solution:** `asyncio` + `aiohttp` with semaphore, gather results; record timings; retry once.  
  **Test:** Spin up httpbin; assert successes/failures counted; timeout respected.

### Go
- **Problem:** Tail file and count ERROR per minute (streaming).  
  **Solution:** Use bufio.Scanner, time-bucket map, channel + goroutine; handle file rotation.  
  **Test:** Write temp file with timestamps; append errors; assert counts update.
- **Problem:** HTTP server with `/health`, `/metrics`, graceful shutdown.  
  **Solution:** `net/http`, context cancel on SIGTERM, Prometheus client.  
  **Test:** hit endpoints; send SIGTERM; ensure server stops within timeout.

### Containers/K8s
- **Problem:** Fix Dockerfile (size/run as root/no healthcheck).  
  **Solution:** Multi-stage slim base, non-root, `.dockerignore`, `HEALTHCHECK`, pinned deps.  
  **Test:** `docker build`, `hadolint`, `trivy` with no HIGH/CRIT; run container and curl `/health`.
- **Problem:** Harden Deployment and restrict traffic.  
  **Solution:** Add probes, limits, securityContext (non-root, read-only), PDB, HPA, anti-affinity, NetworkPolicy default-deny + allow ingress controller/monitoring.  
  **Test:** `kubeconform` validate; `kubectl auth can-i` checks; curl from allowed/blocked pods.

### Terraform/Cloud
- **Problem:** S3 bucket with least-privilege IAM and state hygiene.  
  **Solution:** bucket + versioning + SSE + block public, lifecycle; IAM policy Get/Put/List only; remote state config.  
  **Test:** `terraform fmt/validate`, tflint, tfsec; check outputs names are tagged.
- **Problem:** VPC with private/public subnets + peering.  
  **Solution:** VPC, IGW/NAT, route tables, SG least privilege, VPC peering routes both ways.  
  **Test:** `terraform plan` clean; tfsec; expected CIDRs present.

### CI/CD
- **Problem:** Build pipeline with gates.  
  **Solution:** Jobs: pre-commit (ruff/black/yamllint/shellcheck/hadolint) → pytest → docker build → trivy scan → terraform fmt/validate/tflint/tfsec; push on main with creds.  
  **Test:** Pipeline passes locally with `act`/runner; secrets absent → push skipped gracefully.
- **Problem:** Reusable workflow calling module tests.  
  **Solution:** Composite/reusable Actions with matrix across modules; SARIF uploads; environment protections.  
  **Test:** Called workflow returns success/fail per matrix; required checks enforced.

### Security/DevSecOps
- **Problem:** Remove plaintext secrets; add scanning.  
  **Solution:** Move to env/secret manager; add gitleaks, semgrep, dep scan; enforce HTTPS.  
  **Test:** gitleaks/semgrep pass; app reads secret from env; no secret in repo.
- **Problem:** Supply-chain guardrails.  
  **Solution:** SBOM (syft), sign images (cosign), policy check (Conftest/Gatekeeper), CVE triage workflow.  
  **Test:** Verify signature; policy denies unsigned; trivy report clean.

### Observability/SRE
- **Problem:** Add golden-signal metrics to API.  
  **Solution:** Expose request count/latency/error metrics, `/health` `/ready`, structured logs.  
  **Test:** scrape metrics; unit test counts increment; readiness toggles on dependency check.
- **Problem:** Alert fatigue cleanup.  
  **Solution:** SLOs + burn-rate alerts, dedup labels, runbooks linked.  
  **Test:** Simulate traffic/error to trigger alert; ensure only one page fires; runbook link present.

### Networking/Linux
- **Problem:** Diagnose high CPU process.  
  **Solution:** `ps/top/htop`, `strace -p`, `lsof`, perf sample; identify tight loop or I/O wait.  
  **Test:** Create CPU-hog script; ensure checklist identifies it within minutes.
- **Problem:** Intermittent DNS failures in cluster.  
  **Solution:** `dig/nslookup` against kube-dns, check iptables/CNI, inspect CoreDNS logs, add probe.  
  **Test:** Inject bad ConfigMap; ensure detection and rollback steps clear the issue.

### GitOps
- **Problem:** Drift and orphaned resources.  
  **Solution:** ArgoCD app with auto-prune/auto-heal; Kustomize overlays; appproject RBAC.  
  **Test:** Delete live resource; Argo reconciles; unauthorized app path is denied.
