# Board Member Expertise Problems

Problems organized by Board Member expertise areas from the Coderbyte Mastery Guide.

## 🏛️ Board Members

### 1. [Security Architect - Sarah Chen](security-architect/README.md)
**Focus**: Container security, IAM, secrets management, zero-trust  
**Mantra**: "If it's not encrypted, it's not production"  
**Available Problems**: 8 (Problems 1–8)

### 2. [SRE Engineer - Marcus Rodriguez](sre-engineer/README.md)
**Focus**: Observability, SLOs, incident response, on-call  
**Mantra**: "Measure everything, alert on what matters"  
**Available Problems**: 4 (Problems 1–4)

### 3. [Platform Engineer - Aisha Patel](platform-engineer/README.md)
**Focus**: Kubernetes, GitOps, developer experience  
**Mantra**: "Make the right thing the easy thing"  
**Available Problems**: 4 (Problems 1–4)

### 4. [Infrastructure Architect - David Kim](infrastructure-architect/README.md)
**Focus**: Terraform, cloud architecture, cost optimization  
**Mantra**: "Infrastructure is code, treat it like software"  
**Available Problems**: 4 (Problems 1–4)

### 5. [CI/CD Specialist - Elena Volkov](cicd-specialist/README.md)
**Focus**: Pipelines, automation, quality gates  
**Mantra**: "Ship fast, ship safe, ship often"  
**Available Problems**: 4 (Problems 1–4)

## 📊 Problem Distribution (Currently Available)

| Board Member | Listed Problems |
|--------------|-----------------|
| Security Architect | 8 |
| SRE Engineer | 4 |
| Platform Engineer | 4 |
| Infrastructure Architect | 4 |
| CI/CD Specialist | 4 |
| **Total** | **24** |

## 🧪 Validation Quick Checks
- Security: run policy/schema checks (`kubeconform` on manifests, `terraform validate` for IAM examples, CI pipelines via dry-run/`act`).
- SRE: import dashboards, apply PrometheusRule with kube-prometheus, dry-run log pipeline configs.
- Platform: `kubeconform` for manifests; ArgoCD ApplicationSets with `argocd app create --from-spec` dry-run; ensure PSA/NetworkPolicies apply in a test cluster.
- Infrastructure: `terraform fmt && terraform validate && tflint/tfsec` in solution directories.
- CI/CD: use `act` or repository CI to dry-run the provided GitHub Actions workflows.

## 🎯 How to Use

1. **Choose your focus area** based on job requirements
2. **Start with Easy problems** to build confidence
3. **Progress to Medium** for production patterns
4. **Master Hard problems** for complex scenarios
5. **Cross-train** across all board members for well-rounded skills

## 🚀 Recommended Learning Path

### Week 1: Security Foundation
- Security Architect problems 1-4
- Focus on container security and IAM

### Week 2: Observability & Reliability
- SRE Engineer problems 1-4
- Learn metrics, logging, alerting

### Week 3: Platform & Kubernetes
- Platform Engineer problems 1-4
- Master K8s and GitOps

### Week 4: Infrastructure & IaC
- Infrastructure Architect problems 1-4
- Terraform and cloud patterns

### Week 5: CI/CD & Automation
- CI/CD Specialist problems 1-4
- Pipeline building and automation

### Week 6: Advanced & Integration
- Complete all Hard problems
- Cross-functional scenarios
- Full-stack challenges

## 💡 Pro Tips

- **Security First**: Always apply security principles regardless of problem type
- **Production Mindset**: Every solution should be production-ready
- **Documentation**: Write clear explanations for your decisions
- **Time Management**: Practice under time constraints
- **Cross-Training**: Learn from all board members

## 🏆 Mastery Goals

- [ ] Complete all 40 problems
- [ ] 90%+ accuracy on Easy problems
- [ ] 85%+ accuracy on Medium problems
- [ ] 75%+ accuracy on Hard problems
- [ ] Can explain every decision
- [ ] Solutions pass all security scans
- [ ] Code is production-ready
