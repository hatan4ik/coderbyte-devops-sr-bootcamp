# Problem 1: Build Complete CI/CD Pipeline 🔴

**Difficulty**: Hard | **Time**: 60 min | **Points**: 200

## Scenario
Create production-ready pipeline with security scanning and deployment.

## Requirements

### Pipeline Stages
1. **Lint** - Code quality checks
2. **Test** - Unit and integration tests
3. **Build** - Docker image
4. **Scan** - Security vulnerabilities
5. **Push** - Container registry
6. **Deploy** - Kubernetes (dev/prod)

### Must Include
- Parallel execution where possible
- Caching for speed
- Security scanning (Trivy, Semgrep)
- Quality gates (fail on HIGH/CRITICAL)
- Secrets management
- Deployment strategies
- Rollback capability

### Bonus Points
- Multi-platform builds
- SBOM generation
- Slack notifications
- Deployment approval gates

## Deliverables
- GitHub Actions workflow
- Dockerfile
- K8s manifests
- Documentation

## Success Criteria
- [ ] All stages pass
- [ ] Security scans clean
- [ ] Deploys successfully
- [ ] Rollback works
- [ ] <10 min total time
