# Problem 03: Advanced Pipeline with Gates 🔴

**Time**: 75 min | **Difficulty**: Hard | **Points**: 150

## Scenario
Build production pipeline with quality gates, approvals, and rollback.

## Requirements
1. Multi-stage pipeline (lint, test, build, scan, deploy)
2. Quality gates (coverage, security, performance)
3. Manual approval for prod
4. Automated rollback on failure
5. Slack notifications
6. Deployment strategies (canary/blue-green)

## Pipeline Stages
```
Lint → Test → Build → Scan → Stage Deploy → Approval → Prod Deploy → Verify
  ↓      ↓       ↓       ↓         ↓            ↓          ↓           ↓
fail  fail    fail    fail      fail        timeout    fail      rollback
```

## Quality Gates
- Code coverage > 80%
- No HIGH/CRITICAL vulnerabilities
- Performance tests pass
- Manual approval required
- Smoke tests pass

## Deliverables
```
solution/
├── .github/workflows/pipeline.yaml
├── scripts/
│   ├── quality-gate.sh
│   ├── deploy-canary.sh
│   └── rollback.sh
└── README.md
```

## Success Criteria
- [ ] All gates enforced
- [ ] Approval works
- [ ] Rollback tested
- [ ] Notifications sent
- [ ] Zero downtime
