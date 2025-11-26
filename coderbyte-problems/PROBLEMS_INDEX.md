# Complete Problems Index

## 🐳 Container Tasks

### Problem 1: Optimize Bloated Dockerfile 🟡
**Time**: 30 min | **Difficulty**: Medium  
**Skills**: Multi-stage builds, security, optimization  
**Path**: `container-tasks/problem-01-optimize-dockerfile/`

**What You'll Learn**:
- Multi-stage Docker builds
- Image size optimization (1.8GB → 180MB)
- Non-root user implementation
- Health check configuration
- Layer caching strategies

**Key Concepts**:
```dockerfile
# Before: 1.8GB, root user, 10min build
FROM ubuntu:latest
RUN apt-get install -y python3 python3-pip git curl wget vim

# After: 180MB, non-root, 2min build
FROM python:3.11-slim AS builder
...
USER app
```

---

### Problem 2: Debug Crashing Container 🟢
**Time**: 20 min | **Difficulty**: Easy  
**Skills**: Debugging, logs analysis, troubleshooting  
**Path**: `container-tasks/problem-02-debug-container/`

**Scenario**: Container exits immediately after start

**Common Issues**:
- Missing dependencies
- Wrong entrypoint
- Permission errors
- Port conflicts
- Resource limits

---

## ☸️ Kubernetes Tasks

### Problem 1: Fix Broken Deployment 🟡
**Time**: 25 min | **Difficulty**: Medium  
**Skills**: K8s debugging, manifest fixing, best practices  
**Path**: `kubernetes-tasks/problem-01-fix-deployment/`

**Issues to Fix**:
```yaml
# 7 Critical Issues:
1. Selector mismatch (app: web vs app: web-app)
2. No resource limits
3. No health probes
4. No security context
5. Using :latest tag
6. Single replica
7. Missing service
```

**Solution Highlights**:
- Security contexts (runAsNonRoot, readOnlyRootFilesystem)
- Resource limits (requests/limits)
- Health probes (liveness/readiness)
- Rolling update strategy
- Proper labeling

---

### Problem 2: Implement GitOps Workflow 🔴
**Time**: 60 min | **Difficulty**: Hard  
**Skills**: ArgoCD, Kustomize, GitOps patterns  
**Path**: `kubernetes-tasks/problem-02-implement-gitops/`

**Requirements**:
- Base manifests
- Dev/Prod overlays with Kustomize
- ArgoCD application
- Auto-sync configuration
- Documentation

---

## 🏗️ Terraform Tasks

### Problem 1: Secure Insecure Infrastructure 🔴
**Time**: 45 min | **Difficulty**: Hard  
**Skills**: IaC security, AWS best practices, compliance  
**Path**: `terraform-tasks/problem-01-secure-infrastructure/`

**Security Fixes**:
```hcl
# Before: Public, unencrypted, wildcard permissions
resource "aws_s3_bucket" "data" {
  bucket = "my-data"
}

# After: Private, encrypted, least privilege
resource "aws_s3_bucket" "data" {
  bucket = "my-data-${var.env}-${account_id}"
}
+ versioning
+ encryption
+ public access block
+ lifecycle policies
```

**Passes**: tfsec, Checkov, AWS Config

---

### Problem 2: Create Reusable Module 🟡
**Time**: 35 min | **Difficulty**: Medium  
**Skills**: Terraform modules, DRY principles  
**Path**: `terraform-tasks/problem-02-create-module/`

---

## 🔄 CI/CD Tasks

### Problem 1: Build Complete Pipeline 🔴
**Time**: 60 min | **Difficulty**: Hard  
**Skills**: GitHub Actions, security scanning, deployment  
**Path**: `cicd-tasks/problem-01-build-pipeline/`

**Pipeline Stages**:
```
Lint → Test → Build → Scan → Push → Deploy
  ↓      ↓       ↓       ↓      ↓       ↓
flake8  pytest  docker  trivy  ghcr   kubectl
```

**Features**:
- Parallel execution
- Caching (pip, docker layers)
- Security gates (Trivy, Semgrep)
- Multi-platform builds
- Environment-based deployment
- Rollback capability

---

### Problem 2: Add Security Scanning 🟡
**Time**: 30 min | **Difficulty**: Medium  
**Skills**: Security tools integration  
**Path**: `cicd-tasks/problem-02-security-scanning/`

---

## 🐛 Debugging Tasks

### Problem 1: Pod CrashLoopBackOff 🟢
**Time**: 15 min | **Difficulty**: Easy  
**Skills**: K8s debugging, systematic troubleshooting  
**Path**: `debugging-tasks/problem-01-crashloop/`

**Debugging Steps**:
```bash
1. kubectl get pods
2. kubectl describe pod <name>
3. kubectl logs <name>
4. kubectl logs <name> --previous
5. kubectl exec -it <name> -- sh
```

**Common Causes**:
- Application crash
- Liveness probe too aggressive
- OOMKilled
- Image pull error
- Missing dependencies

---

### Problem 2: Terraform State Lock 🟡
**Time**: 20 min | **Difficulty**: Medium  
**Path**: `debugging-tasks/problem-02-state-lock/`

---

## 🔒 Security Tasks

### Problem 1: Container Security Audit 🟡
**Time**: 30 min | **Difficulty**: Medium  
**Skills**: Security scanning, vulnerability remediation  
**Path**: `security-tasks/problem-01-container-audit/`

**Tools Used**:
- Trivy (CVE scanning)
- Hadolint (Dockerfile linting)
- Syft (SBOM generation)
- Grype (vulnerability scanning)

---

### Problem 2: Implement RBAC 🔴
**Time**: 45 min | **Difficulty**: Hard  
**Path**: `security-tasks/problem-02-implement-rbac/`

---

## 📊 Observability Tasks

### Problem 1: Add Prometheus Metrics 🟡
**Time**: 35 min | **Difficulty**: Medium  
**Skills**: Instrumentation, metrics, alerting  
**Path**: `observability-tasks/problem-01-prometheus-metrics/`

**Implementation**:
```python
from prometheus_client import Counter, Histogram

REQUEST_COUNT = Counter('http_requests_total', 
                        'Total requests', 
                        ['method', 'endpoint', 'status'])

REQUEST_LATENCY = Histogram('http_request_duration_seconds',
                            'Request latency',
                            ['method', 'endpoint'])
```

**Deliverables**:
- Instrumented application
- Prometheus scrape config
- Alert rules (error rate, latency)
- Grafana dashboard queries

---

### Problem 2: Implement Distributed Tracing 🔴
**Time**: 50 min | **Difficulty**: Hard  
**Path**: `observability-tasks/problem-02-distributed-tracing/`

---

## 📝 Scripting Tasks

### Problem 1: Log Parser with Error Detection 🟢
**Time**: 20 min | **Difficulty**: Easy  
**Skills**: Python/Bash, regex, JSON output  
**Path**: `scripting-tasks/problem-01-log-parser/`

**Requirements**:
```python
# Input: access.log
# Output: JSON with error counts, patterns, timestamps

{
  "total_lines": 10000,
  "errors": 45,
  "warnings": 123,
  "error_patterns": {
    "500": 30,
    "503": 15
  }
}
```

---

### Problem 2: Automated Backup Script 🟡
**Time**: 25 min | **Difficulty**: Medium  
**Path**: `scripting-tasks/problem-02-backup-script/`

---

## 📈 Difficulty Distribution

| Level | Count | Time Range | Success Rate Target |
|-------|-------|------------|---------------------|
| 🟢 Easy | 6 | 15-20 min | 95%+ |
| 🟡 Medium | 10 | 25-35 min | 85%+ |
| 🔴 Hard | 6 | 45-60 min | 75%+ |

## 🎯 Practice Strategy

### Week 1-2: Easy Problems
- Complete all 🟢 Easy problems
- Focus on fundamentals
- Build muscle memory
- Target: 100% completion

### Week 3-4: Medium Problems
- Tackle 🟡 Medium problems
- Learn production patterns
- Optimize for speed
- Target: 90% completion

### Week 5-6: Hard Problems
- Master 🔴 Hard problems
- Complex scenarios
- Time pressure simulation
- Target: 80% completion

## 🏆 Mastery Checklist

### Container Mastery
- [ ] Can optimize any Dockerfile in <20 min
- [ ] Debug container issues systematically
- [ ] Implement all security best practices
- [ ] Multi-stage builds by default

### Kubernetes Mastery
- [ ] Fix broken deployments in <15 min
- [ ] Implement GitOps workflow in <60 min
- [ ] Debug pod issues in <10 min
- [ ] Write production-ready manifests

### Terraform Mastery
- [ ] Secure infrastructure in <30 min
- [ ] Create reusable modules
- [ ] Pass all security scans
- [ ] Handle state management

### CI/CD Mastery
- [ ] Build complete pipeline in <60 min
- [ ] Integrate security scanning
- [ ] Implement deployment strategies
- [ ] Handle rollbacks

### Security Mastery
- [ ] Audit and fix vulnerabilities
- [ ] Implement RBAC correctly
- [ ] Use security tools effectively
- [ ] Follow zero-trust principles

### Observability Mastery
- [ ] Add metrics to any app
- [ ] Create alert rules
- [ ] Build Grafana dashboards
- [ ] Implement distributed tracing

## 💡 Pro Tips

1. **Time Management**: Spend 20% planning, 60% implementing, 20% testing
2. **Security First**: Always start with security considerations
3. **Documentation**: Write as you code, not after
4. **Testing**: Test each component before moving on
5. **Templates**: Memorize production-ready templates
6. **Communication**: Explain your decisions clearly

## 🚀 Next Steps

1. Start with Easy problems to build confidence
2. Time yourself on every problem
3. Review solutions even if you succeed
4. Practice variations of each problem
5. Simulate real assessment conditions
6. Track your progress and weak areas

**Goal**: Complete all problems with 90%+ accuracy within time limits before taking real assessments.
