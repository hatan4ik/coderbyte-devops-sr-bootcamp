# Complete Repository Index

Single-page navigation for the bootcamp. Keep this open alongside `CODERBYTE_MASTERY_GUIDE.md` while you work.

## How to Use This Index
- Jump directly to modules, exams, and labs using the links below.
- Use `rg --files modules` to locate tasks quickly when adding new exercises.
- Pair with module-level READMEs for detailed instructions and scoring criteria.

## Primary References
- [README.md](README.md) – entry point and quick commands
- [CODERBYTE_MASTERY_GUIDE.md](CODERBYTE_MASTERY_GUIDE.md) – zero-to-hero sequence
- [ARCHITECTURE.md](ARCHITECTURE.md) – system design decisions
- [ENGINEERING.md](ENGINEERING.md) – coding and delivery standards
- [BEST_PRACTICES.md](BEST_PRACTICES.md) – condensed guardrails
- [SECURITY.md](SECURITY.md) – security controls and policies
- [CONTRIBUTING.md](CONTRIBUTING.md) – collaboration guidance
- [IMPLEMENTATION_SUMMARY.md](IMPLEMENTATION_SUMMARY.md) – implementation notes

## Repository Layout
```
coderbyte-devops-sr-bootcamp/
├── modules/
│   ├── A_zero_to_hero/        # Foundational skills
│   ├── B_mock_exam/           # 10 timed exams
│   ├── C_full_project/        # End-to-end project
│   ├── D_practice_challenges/ # Standalone tasks
│   └── E_custom_plan/         # Job-specific prep
├── practice_examples/         # Hands-on labs (containers/K8s/Terraform/CI/Security/Obs)
├── .github/workflows/         # CI/CD pipelines
├── docs/                      # Additional documentation
└── config/                    # Configuration files
```

## Modules
### Module A – Zero to Hero (`modules/A_zero_to_hero/`)
- Bash basics (11): text stats, HTTP checks, backups, user management, file organization, service checks, disk cleanup, JSON parsing, SSL checks, log rotation, port scanning.
- Python basics (12): log/JSON parsing, health checks, word/CSV parsing, API client, process monitor, log aggregation, scraper, concurrency, Docker SDK automation, config parsing.
- Go basics (5): hello world, file IO, HTTP server with graceful shutdown, JSON API client, concurrent crawler.
- Run tests: `cd modules/A_zero_to_hero && ./run_tests.sh`

### Module B – Mock Exams (`modules/B_mock_exam/`)
1. [Exam 01](modules/B_mock_exam/exam_01/) – Web Service + Docker + Terraform + K8s (`instructions.md`, `SOLUTION.md`)
2. [Exam 02](modules/B_mock_exam/exam_02/) – Log Pipeline + S3 + CI (`instructions.md`, starter `log_processor.py`)
3. [Exam 03](modules/B_mock_exam/exam_03/) – GitOps with ArgoCD & Kustomize (`instructions.md`, starter `README.md`)
4. [Exam 04](modules/B_mock_exam/exam_04/) – IaC Security (`instructions.md`, starter `README.md`)
5. [Exam 05](modules/B_mock_exam/exam_05/) – Advanced CI/CD with Jenkins (`instructions.md`, starter `Jenkinsfile`)
6. [Exam 06](modules/B_mock_exam/exam_06/) – Cloud Networking & Peering (`instructions.md`)
7. [Exam 07](modules/B_mock_exam/exam_07/) – SRE & Observability (`instructions.md`, starter `README.md`)
8. [Exam 08](modules/B_mock_exam/exam_08/) – Container Image Security (`instructions.md`, starter `README.md`)
9. [Exam 09](modules/B_mock_exam/exam_09/) – Linux Systems Debugging (`instructions.md`)
10. [Exam 10](modules/B_mock_exam/exam_10/) – Serverless Architecture (`instructions.md`)

### Module C – Full Project (`modules/C_full_project/`)
- [README.md](modules/C_full_project/README.md) – full documentation
- [DEPLOY.md](modules/C_full_project/DEPLOY.md) – end-to-end deploy guide
- [app/app.py](modules/C_full_project/app/app.py) – production application
- [docker/Dockerfile](modules/C_full_project/docker/Dockerfile) – multi-stage, non-root build
- [terraform/main.tf](modules/C_full_project/terraform/main.tf) – infrastructure stack
- [k8s/](modules/C_full_project/k8s/) – Kubernetes manifests and overlays
- [Makefile](modules/C_full_project/Makefile) – operational targets

### Module D – Practice Challenges (`modules/D_practice_challenges/`)
- [log_parser/](modules/D_practice_challenges/log_parser/) – log parsing
- [api_client/](modules/D_practice_challenges/api_client/) – API client
- [dockerfile_fix/](modules/D_practice_challenges/dockerfile_fix/) – Dockerfile optimization
- [terraform_bucket/](modules/D_practice_challenges/terraform_bucket/) – Terraform S3
- [k8s_deployment/](modules/D_practice_challenges/k8s_deployment/) – Kubernetes deployment

### Module E – Custom Plan (`modules/E_custom_plan/`)
- [README.md](modules/E_custom_plan/README.md)
- [skills_mapping.md](modules/E_custom_plan/skills_mapping.md)
- [checklist.md](modules/E_custom_plan/checklist.md)

### Practice Labs (`practice_examples/`)
- Scripting: `bash-top-ips`, `python-concurrent-fetch`, `go-http-service`, `log-streamer`
- Containers and supply chain: `container-sbom`, `helm-policy`
- Kubernetes: `k8s-hardening`, `k8s-canary`, `k8s-resource-quota`
- Terraform/Cloud: `terraform-vpc`, `terraform-vpc-peering`, `aws-budget`
- CI/CD: `ci-pipeline`
- Security and policy: `security-policy` (OPA/Gatekeeper/Kyverno), `container-sbom`
- Observability/SRE: `observability-slo`, `observability-stack`
- Networking/Resiliency: `networking-debug`, `chaos-drill`, `networking-debug/cni-misroute`
- AWS Security: `aws-security/01-iam-basics` through `aws-security/16-securityhub-macie`

## Configuration and CI/CD
- [Makefile](Makefile) – build and operations
- [.gitignore](.gitignore), [.gitattributes](.gitattributes), [.editorconfig](.editorconfig)
- [.dockerignore](.dockerignore)
- [.pre-commit-config.yaml](.pre-commit-config.yaml)
- [requirements.txt](requirements.txt)
- [CI workflows](.github/workflows/) – security scans, terraform checks, and full-project CI

## Quick Commands
```bash
make setup            # bootstrap tooling
make test             # run all tests
make security-scan    # security scanners
make docker-build     # build image
make k8s-deploy       # deploy to Kubernetes
./menu.sh             # interactive navigation
```

## Progress and Skills Tracking
- [ ] Module A – all exercises
- [ ] Module B – 8/10 exams passed
- [ ] Module C – deployed to production
- [ ] Module D – all challenges
- [ ] Module E – custom plan created
- [ ] Container security | Kubernetes production | IaC | CI/CD | Observability | Security scanning

## External Resources
- Tools: [Docker](https://docs.docker.com/), [Kubernetes](https://kubernetes.io/docs/), [Terraform](https://www.terraform.io/docs), [Prometheus](https://prometheus.io/docs/), [ArgoCD](https://argo-cd.readthedocs.io/)
- Standards: [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/), [NIST Framework](https://www.nist.gov/cyberframework), [12-Factor App](https://12factor.net/)

**Last Updated**: 2024  
**Status**: Production Ready  
**Maintained By**: DevOps Community
