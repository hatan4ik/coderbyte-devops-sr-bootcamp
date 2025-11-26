# Problem 1: Fix Broken Kubernetes Deployment 🟡

**Difficulty**: Medium | **Time**: 25 min | **Points**: 100

## Scenario
Pods are crash looping. Fix all issues to make it production-ready.

## Given Manifest
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web
        image: nginx:latest
        ports:
        - containerPort: 80
```

## Issues to Find & Fix
1. Selector mismatch
2. No resource limits
3. No health probes
4. No security context
5. Using :latest tag
6. Single replica (no HA)
7. Missing service

## Requirements
- Fix all issues
- Add production best practices
- Create matching Service
- Add HPA (optional bonus)

## Success Criteria
- [ ] Pods running
- [ ] Health checks passing
- [ ] Security contexts set
- [ ] Resource limits defined
- [ ] Service accessible
