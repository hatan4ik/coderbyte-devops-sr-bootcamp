# Coderbyte DevOps Sr Bootcamp (Production-Grade)

Enterprise-ready training environment for Senior DevOps Engineer Coderbyte-style assignments with production best practices, security hardening, and real-world patterns.

## 🎯 Overview

This repository provides a complete, production-grade training platform organized into 5 comprehensive modules:

- **Module A** – Zero to Hero (CLI & scripting fundamentals)
- **Module B** – Mock Exams (timed Coderbyte-style challenges)
- **Module C** – Full Project (end-to-end DevOps pipeline)
- **Module D** – Practice Challenges (standalone tasks)
- **Module E** – Custom Plan (job-specific preparation)

## ✨ Production Features

### Security
- ✅ Multi-stage Docker builds with non-root users
- ✅ Kubernetes security contexts (seccomp, capabilities)
- ✅ Network policies for zero-trust networking
- ✅ Encrypted Terraform state with locking
- ✅ Automated vulnerability scanning (Trivy, Semgrep)
- ✅ Secret detection (Gitleaks)
- ✅ Pre-commit hooks for code quality

### High Availability
- ✅ Pod Disruption Budgets (PDB)
- ✅ Horizontal Pod Autoscaling (HPA)
- ✅ Anti-affinity rules
- ✅ Rolling update strategies
- ✅ Health checks (liveness, readiness, startup)

### Observability
- ✅ Structured logging
- ✅ Prometheus metrics endpoints
- ✅ Health and readiness probes
- ✅ CloudWatch integration
- ✅ Distributed tracing ready

### Infrastructure as Code
- ✅ Terraform with validation and best practices
- ✅ Kustomize for environment overlays
- ✅ ArgoCD for GitOps deployments
- ✅ Comprehensive CI/CD pipelines

## 🚀 Quick Start

### Prerequisites

```bash
# macOS
brew install python docker kubectl terraform make jq

# Linux
apt-get install python3 docker.io kubectl terraform make jq

# Verify installations
python3 --version
docker --version
kubectl version --client
terraform --version
```

### Installation

```bash
# Clone repository
git clone <repository-url>
cd coderbyte-devops-sr-bootcamp

# Install dependencies
make setup

# Run interactive menu
./menu.sh

# Or run specific module
cd modules/A_zero_to_hero
./run_tests.sh
```

## ✅ Quality Gates
- **Pre-commit**: run `pre-commit install` to enforce formatting (black/ruff), YAML lint, shell/Docker lint, and Terraform fmt/validate/tflint/tfsec.
- **CI workflows**: 
  - `.github/workflows/full-project-ci.yaml` – lint/test/build/scan for Module C.
  - `.github/workflows/terraform-checks.yaml` – fmt/validate/tflint/tfsec across Terraform stacks.
  - `.github/workflows/security-scan.yaml` – Trivy, gitleaks, Semgrep.
- **Playbook**: see `ENGINEERING.md` for coding standards, CI/CD expectations, and security guidance.

## 📚 Module Structure

### Module A – Zero to Hero

Foundational skills with production-grade implementations:

**Bash Basics** (11 exercises)
- Text processing, HTTP checks, backups
- User management, file organization
- Service monitoring, SSL checks
- Log rotation, port scanning

**Python Basics** (12 exercises)
- Log parsing with structured output
- System health monitoring
- API clients with error handling
- Docker SDK automation
- Concurrency patterns

**Go Basics** (5 exercises)
- HTTP servers with graceful shutdown
- Concurrent web crawlers
- JSON API clients

```bash
cd modules/A_zero_to_hero
./run_tests.sh
```

### Module B – Mock Exams

10 timed exams simulating real Coderbyte challenges:

1. **Web Service + Docker + Terraform + K8s**
2. **Log Pipeline + S3 + CI**
3. **GitOps with ArgoCD & Kustomize** ⭐
4. **IaC Security**
5. **Advanced CI/CD with Jenkins**
6. **Cloud Networking & Peering**
7. **SRE & Observability**
8. **Container Image Security**
9. **Linux Systems Debugging**
10. **Serverless Architecture**

```bash
cd modules/B_mock_exam/exam_03
./start_exam.sh
```

### Module C – Full Project ⭐

Production-ready end-to-end project:

**Application**
- Python web service with health/metrics endpoints
- Graceful shutdown handling
- Structured logging
- Zero external dependencies

**Docker**
- Multi-stage builds (60% size reduction)
- Non-root user (UID 1000)
- Security scanning ready
- Health checks built-in

**Kubernetes**
- Security contexts enforced
- Resource limits configured
- Network policies implemented
- HPA and PDB configured
- Prometheus annotations

**Terraform**
- S3 with encryption and versioning
- IAM with least privilege
- CloudWatch log groups
- Lifecycle policies
- Input validation

**CI/CD**
- GitHub Actions workflows
- Security scanning (Trivy, Semgrep)
- Multi-platform builds
- Automated deployments

```bash
cd modules/C_full_project

# Build and run locally
make docker-build
make docker-run

# Deploy to Kubernetes
make k8s-deploy

# Provision infrastructure
make terraform-init
make terraform-plan
```

### Module D – Practice Challenges

Standalone tasks mirroring Coderbyte questions:
- Log parser with JSON output
- API client with filtering
- Dockerfile optimization
- Terraform S3 bucket
- Kubernetes deployment fixes

### Module E – Custom Plan

Customize training for specific job descriptions:
- Skills mapping
- Gap analysis
- Custom practice plan
- Interview preparation

## 🔒 Security Best Practices

### Container Security
```yaml
# Non-root user
USER 1000

# Read-only filesystem
readOnlyRootFilesystem: true

# Drop all capabilities
capabilities:
  drop: [ALL]

# Seccomp profile
seccompProfile:
  type: RuntimeDefault
```

### Kubernetes Security
```yaml
# Network policies
policyTypes: [Ingress, Egress]

# Pod security standards
runAsNonRoot: true
allowPrivilegeEscalation: false

# Resource limits
resources:
  limits:
    cpu: 500m
    memory: 512Mi
```

### Infrastructure Security
```hcl
# Encrypted state
backend "s3" {
  encrypt = true
}

# Public access blocked
block_public_acls = true

# Versioning enabled
versioning_configuration {
  status = "Enabled"
}
```

## 🧪 Testing

```bash
# Run all tests
make test

# Run specific module tests
cd modules/A_zero_to_hero && ./run_tests.sh
cd modules/C_full_project && pytest tests/ -v

# Security scanning
make security-scan

# Lint code
make lint
```

## 📊 CI/CD Pipeline

```
┌─────────────┐
│  Git Push   │
└──────┬──────┘
       ↓
┌──────────────────┐
│ Security Scan    │
│ - Trivy          │
│ - Gitleaks       │
│ - Semgrep        │
└──────┬───────────┘
       ↓
┌──────────────────┐
│ Build & Test     │
│ - Docker build   │
│ - Unit tests     │
│ - Image scan     │
└──────┬───────────┘
       ↓
┌──────────────────┐
│ Deploy           │
│ - Push image     │
│ - Update K8s     │
│ - Verify health  │
└──────────────────┘
```

## 📖 Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture and design decisions
- [SECURITY.md](SECURITY.md) - Security policies and best practices
- [Module C README](modules/C_full_project/README.md) - Full project documentation
- [Exam 03 README](modules/B_mock_exam/exam_03/starter/README.md) - GitOps guide

## 🛠️ Common Commands

```bash
# Interactive menu
./menu.sh

# Setup environment
make setup

# Run tests
make test

# Build Docker image
make docker-build

# Deploy to Kubernetes
make k8s-deploy

# Security scan
make security-scan

# Clean artifacts
make clean
```

## 🎓 Learning Path

1. **Week 1-2**: Module A (Bash, Python, Go basics)
2. **Week 3-4**: Module C (Full project implementation)
3. **Week 5-6**: Module B (Mock exams 1-5)
4. **Week 7-8**: Module B (Mock exams 6-10)
5. **Week 9**: Module D (Practice challenges)
6. **Week 10**: Module E (Custom preparation)

## 🔧 Troubleshooting

### Docker Issues
```bash
# Check Docker daemon
docker info

# Clean up
docker system prune -a
```

### Kubernetes Issues
```bash
# Check cluster
kubectl cluster-info

# View logs
kubectl logs -n <namespace> <pod-name>

# Describe resources
kubectl describe pod <pod-name>
```

### Terraform Issues
```bash
# Validate configuration
terraform validate

# Check state
terraform show

# Refresh state
terraform refresh
```

## 📈 Performance Metrics

- **Docker Image Size**: 150MB (vs 1GB+ without optimization)
- **Build Time**: 2-3 minutes (with layer caching)
- **Startup Time**: < 5 seconds
- **Memory Footprint**: 50-100MB per pod
- **Test Coverage**: 80%+

## 🤝 Contributing

This is a training repository. Focus on:
- Security best practices
- Production-ready patterns
- Clear documentation
- Comprehensive testing

## 📝 License

Educational use only.

## 🎯 Success Criteria

- [ ] Complete all Module A exercises
- [ ] Pass 8/10 mock exams
- [ ] Deploy Module C to production
- [ ] Implement all security controls
- [ ] Achieve 80%+ test coverage
- [ ] Document all decisions

## 🔗 Resources

- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Docker Security](https://docs.docker.com/engine/security/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [12-Factor App](https://12factor.net/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)

## 💡 Tips for Coderbyte Exams

1. **Read requirements carefully** - Note all constraints
2. **Start with security** - Non-root users, least privilege
3. **Add health checks** - Liveness and readiness probes
4. **Resource limits** - Always set requests and limits
5. **Error handling** - Graceful degradation
6. **Documentation** - Clear README with examples
7. **Testing** - Validate before submission
8. **Time management** - 2-3 hours typical

---

**Built with ❤️ for DevOps Engineers preparing for Senior roles**
