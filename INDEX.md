# Complete Repository Index

## 📁 Repository Structure

```
coderbyte-devops-sr-bootcamp/
├── modules/
│   ├── A_zero_to_hero/          # Foundational skills
│   ├── B_mock_exam/             # 10 timed exams
│   ├── C_full_project/          # End-to-end project
│   ├── D_practice_challenges/   # Standalone tasks
│   └── E_custom_plan/           # Job-specific prep
├── .github/workflows/           # CI/CD pipelines
├── docs/                        # Documentation
├── practice_examples/           # Hands-on labs (containers/K8s/Terraform/CI/Security/Obs)
└── config/                      # Configuration files
```

## 📚 Quick Navigation

### Getting Started (read in order)
1. [README.md](README.md) - Main overview
2. [ARCHITECTURE.md](ARCHITECTURE.md) - System design
3. [ENGINEERING.md](ENGINEERING.md) - Standards & workflows
4. [BEST_PRACTICES.md](BEST_PRACTICES.md) - Guidelines
5. [SECURITY.md](SECURITY.md) - Security policies
6. [CODERBYTE_MASTERY_GUIDE.md](CODERBYTE_MASTERY_GUIDE.md) - Zero→Hero path
7. [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute

### Module A - Zero to Hero
**Location**: `modules/A_zero_to_hero/`

#### Bash Basics (11 exercises)
1. [text_stats_01.sh](modules/A_zero_to_hero/bash-basics/text_stats_01.sh) - File statistics
2. [http_check_02.sh](modules/A_zero_to_hero/bash-basics/http_check_02.sh) - HTTP health checks
3. [backup_script_03.sh](modules/A_zero_to_hero/bash-basics/backup_script_03.sh) - Automated backups
4. [user_management_04.sh](modules/A_zero_to_hero/bash-basics/user_management_04.sh) - User management
5. [file_organizer_05.sh](modules/A_zero_to_hero/bash-basics/file_organizer_05.sh) - File organization
6. [service_checker_06.sh](modules/A_zero_to_hero/bash-basics/service_checker_06.sh) - Service monitoring
7. [disk_cleanup_07.sh](modules/A_zero_to_hero/bash-basics/disk_cleanup_07.sh) - Disk cleanup
8. [json_parsing_jq_08.sh](modules/A_zero_to_hero/bash-basics/json_parsing_jq_08.sh) - JSON parsing
9. [ssl_cert_check_09.sh](modules/A_zero_to_hero/bash-basics/ssl_cert_check_09.sh) - SSL checks
10. [log_rotation_10.sh](modules/A_zero_to_hero/bash-basics/log_rotation_10.sh) - Log rotation
11. [port_scanner_11.sh](modules/A_zero_to_hero/bash-basics/port_scanner_11.sh) - Port scanning

#### Python Basics (12 exercises)
1. [log_parser_01.py](modules/A_zero_to_hero/python-basics/log_parser_01.py) - Log parsing
2. [json_filter_02.py](modules/A_zero_to_hero/python-basics/json_filter_02.py) - JSON filtering
3. [system_health_03.py](modules/A_zero_to_hero/python-basics/system_health_03.py) - System monitoring
4. [file_word_count_04.py](modules/A_zero_to_hero/python-basics/file_word_count_04.py) - Word counting
5. [csv_parser_05.py](modules/A_zero_to_hero/python-basics/csv_parser_05.py) - CSV parsing
6. [api_client_06.py](modules/A_zero_to_hero/python-basics/api_client_06.py) - API client
7. [process_monitor_07.py](modules/A_zero_to_hero/python-basics/process_monitor_07.py) - Process monitoring
8. [log_aggregator_08.py](modules/A_zero_to_hero/python-basics/log_aggregator_08.py) - Log aggregation
9. [web_scraper_09.py](modules/A_zero_to_hero/python-basics/web_scraper_09.py) - Web scraping
10. [concurrency_basics_10.py](modules/A_zero_to_hero/python-basics/concurrency_basics_10.py) - Concurrency
11. [docker_sdk_automation_11.py](modules/A_zero_to_hero/python-basics/docker_sdk_automation_11.py) - Docker automation
12. [config_parser_ini_12.py](modules/A_zero_to_hero/python-basics/config_parser_ini_12.py) - Config parsing

#### Go Basics (5 exercises)
1. [hello_world_01.go](modules/A_zero_to_hero/go-basics/hello_world_01.go) - Hello World
2. [file_read_02.go](modules/A_zero_to_hero/go-basics/file_read_02.go) - File operations
3. [simple_http_server_03.go](modules/A_zero_to_hero/go-basics/simple_http_server_03.go) - HTTP server
4. [json_api_client_04.go](modules/A_zero_to_hero/go-basics/json_api_client_04.go) - API client
5. [concurrent_crawler_05.go](modules/A_zero_to_hero/go-basics/concurrent_crawler_05.go) - Concurrent crawler

### Module B - Mock Exams
**Location**: `modules/B_mock_exam/`

1. **[Exam 01](modules/B_mock_exam/exam_01/)** - Web Service + Docker + Terraform + K8s
   - [instructions.md](modules/B_mock_exam/exam_01/instructions.md)
   - [SOLUTION.md](modules/B_mock_exam/exam_01/SOLUTION.md) (reference outline)

2. **[Exam 02](modules/B_mock_exam/exam_02/)** - Log Pipeline + S3 + CI
   - [instructions.md](modules/B_mock_exam/exam_02/instructions.md)
   - [log_processor.py](modules/B_mock_exam/exam_02/starter/log_processor.py)

3. **[Exam 03](modules/B_mock_exam/exam_03/)** - GitOps with ArgoCD & Kustomize ⭐
   - [instructions.md](modules/B_mock_exam/exam_03/instructions.md)
   - [README.md](modules/B_mock_exam/exam_03/starter/README.md)

4. **[Exam 04](modules/B_mock_exam/exam_04/)** - IaC Security
   - [instructions.md](modules/B_mock_exam/exam_04/instructions.md)
   - [README.md](modules/B_mock_exam/exam_04/starter/README.md)

5. **[Exam 05](modules/B_mock_exam/exam_05/)** - Advanced CI/CD with Jenkins
   - [instructions.md](modules/B_mock_exam/exam_05/instructions.md)
   - [Jenkinsfile](modules/B_mock_exam/exam_05/starter/Jenkinsfile)

6. **[Exam 06](modules/B_mock_exam/exam_06/)** - Cloud Networking & Peering
   - [instructions.md](modules/B_mock_exam/exam_06/instructions.md)

7. **[Exam 07](modules/B_mock_exam/exam_07/)** - SRE & Observability
   - [instructions.md](modules/B_mock_exam/exam_07/instructions.md)
   - [README.md](modules/B_mock_exam/exam_07/starter/README.md)

8. **[Exam 08](modules/B_mock_exam/exam_08/)** - Container Image Security
   - [instructions.md](modules/B_mock_exam/exam_08/instructions.md)
   - [README.md](modules/B_mock_exam/exam_08/starter/README.md)

9. **[Exam 09](modules/B_mock_exam/exam_09/)** - Linux Systems Debugging
   - [instructions.md](modules/B_mock_exam/exam_09/instructions.md)

10. **[Exam 10](modules/B_mock_exam/exam_10/)** - Serverless Architecture
    - [instructions.md](modules/B_mock_exam/exam_10/instructions.md)

### Module C - Full Project ⭐
**Location**: `modules/C_full_project/`

- [README.md](modules/C_full_project/README.md) - Complete documentation
- [DEPLOY.md](modules/C_full_project/DEPLOY.md) - End-to-end deploy guide
- [app/app.py](modules/C_full_project/app/app.py) - Production application
- [docker/Dockerfile](modules/C_full_project/docker/Dockerfile) - Multi-stage build
- [terraform/main.tf](modules/C_full_project/terraform/main.tf) - Infrastructure
- [k8s/](modules/C_full_project/k8s/) - Kubernetes manifests
- [Makefile](modules/C_full_project/Makefile) - Operations

### Module D - Practice Challenges
**Location**: `modules/D_practice_challenges/`

1. [log_parser/](modules/D_practice_challenges/log_parser/) - Log parsing
2. [api_client/](modules/D_practice_challenges/api_client/) - API client
3. [dockerfile_fix/](modules/D_practice_challenges/dockerfile_fix/) - Dockerfile optimization
4. [terraform_bucket/](modules/D_practice_challenges/terraform_bucket/) - Terraform S3
5. [k8s_deployment/](modules/D_practice_challenges/k8s_deployment/) - K8s deployment

### Module E - Custom Plan
**Location**: `modules/E_custom_plan/`

- [README.md](modules/E_custom_plan/README.md)
- [skills_mapping.md](modules/E_custom_plan/skills_mapping.md)
- [checklist.md](modules/E_custom_plan/checklist.md)

### Practice Labs (Zero → Hero accelerators)
**Location**: `practice_examples/`
- Scripting: `bash-top-ips`, `python-concurrent-fetch`, `go-http-service`, `log-streamer`
- Containers/Supply chain: `container-sbom`, `helm-policy`
- Kubernetes: `k8s-hardening`, `k8s-canary`, `k8s-resource-quota`
- Terraform/Cloud: `terraform-vpc`, `terraform-vpc-peering`, `aws-budget`
- CI/CD: `ci-pipeline`
- Security/Policy: `security-policy` (OPA/Gatekeeper/Kyverno), `container-sbom`
- Observability/SRE: `observability-slo`, `observability-stack`
- Networking/Resiliency: `networking-debug`, `chaos-drill`, `networking-debug/cni-misroute`
- AWS Security: `aws-security/01-iam-basics`, `02-iam-oidc-role`, `03-vpc-network-security`, `04-cloudtrail-guardduty`, `05-ec2-ssm-imdsv2`, `06-ecr-lambda-hardening`, `07-cicd-supply-chain`, `08-incident-response`, `09-cross-account-iam`, `10-abac-sso`, `11-codepipeline-supply-chain`, `12-detection-engineering`, `13-scp-guardrails`, `14-secrets-rotation`

## 🔧 Configuration Files

### Root Level
- [Makefile](Makefile) - Build and operations
- [.gitignore](.gitignore) - Git exclusions
- [.gitattributes](.gitattributes) - Git attributes
- [.editorconfig](.editorconfig) - Editor configuration
- [.dockerignore](.dockerignore) - Docker exclusions
- [.pre-commit-config.yaml](.pre-commit-config.yaml) - Pre-commit hooks
- [requirements.txt](requirements.txt) - Python dependencies

### CI/CD
- [.github/workflows/security-scan.yaml](.github/workflows/security-scan.yaml) - Security scanning

## 📖 Documentation

### Main Docs
- [README.md](README.md) - Repository overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture decisions
- [SECURITY.md](SECURITY.md) - Security policies
- [BEST_PRACTICES.md](BEST_PRACTICES.md) - Best practices guide
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) - Implementation details

## 🚀 Quick Commands

```bash
# Setup
make setup

# Run tests
make test

# Security scan
make security-scan

# Build Docker
make docker-build

# Deploy K8s
make k8s-deploy

# Interactive menu
./menu.sh
```

## 🎯 Learning Paths
Follow the zero→hero sequence in `CODERBYTE_MASTERY_GUIDE.md` (Foundations → Containers → K8s → Terraform/Cloud → CI/CD → Security → Observability → Resiliency → Mock Exams/Full Project).

## 📊 Progress Tracking

### Completion Checklist
- [ ] Module A - All exercises
- [ ] Module B - 8/10 exams passed
- [ ] Module C - Deployed to production
- [ ] Module D - All challenges
- [ ] Module E - Custom plan created

### Skills Assessment
- [ ] Container security
- [ ] Kubernetes production
- [ ] Infrastructure as code
- [ ] CI/CD pipelines
- [ ] Observability
- [ ] Security scanning

## 🔗 External Resources

### Tools
- [Docker](https://docs.docker.com/)
- [Kubernetes](https://kubernetes.io/docs/)
- [Terraform](https://www.terraform.io/docs)
- [Prometheus](https://prometheus.io/docs/)
- [ArgoCD](https://argo-cd.readthedocs.io/)

### Standards
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [NIST Framework](https://www.nist.gov/cyberframework)
- [12-Factor App](https://12factor.net/)

## 💡 Tips

1. **Start with Module A** - Build foundations
2. **Practice exams** - Time yourself
3. **Read documentation** - Understand patterns
4. **Implement security** - Always
5. **Test everything** - Before submission

---

**Last Updated**: 2024
**Status**: Production Ready ✅
**Maintained By**: DevOps Community
