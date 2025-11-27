# Problem 03: Implement Pod Security Standards 🟡

**Time**: 40 min | **Difficulty**: Medium | **Points**: 100

## Scenario
Enforce restricted Pod Security Standards across namespace with admission control.

## Current State
- Pods running as root
- Privileged containers allowed
- No security policies enforced
- Containers can escalate privileges

## Requirements
1. Create namespace with PSS labels
2. Enforce restricted profile
3. Block non-compliant pods
4. Create compliant deployment
5. Test with non-compliant pod

## Deliverables
```
solution/
├── namespace.yaml
├── deployment-compliant.yaml
├── deployment-blocked.yaml
└── test.sh
```

## Success Criteria
- [ ] Restricted PSS enforced
- [ ] Compliant pods deploy
- [ ] Non-compliant pods blocked
- [ ] All security contexts set
