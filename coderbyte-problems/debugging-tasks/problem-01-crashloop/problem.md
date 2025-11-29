# Problem 1: Pod CrashLoopBackOff 🟢

**Difficulty**: Easy | **Time**: 15–20 min | **Points**: 80  
**Scenario**: A simple workload is crash-looping immediately after start. You need to identify the root cause and ship a production-safe fix.

## What You’re Given
- `starter/broken-deployment.yaml` — a single Deployment that consistently lands in `CrashLoopBackOff`.
- No extra services or ingress; you can apply directly to any namespace.

## Reproduce
```bash
kubectl apply -f starter/broken-deployment.yaml
kubectl get pods
kubectl describe pod <name>
kubectl logs <name>
```

## Expected Debug Flow (model answer)
1) Confirm status/events: `kubectl get pods -w`, `kubectl describe pod <name>`.  
2) Inspect container logs (current/previous): `kubectl logs <name> --previous`.  
3) If needed, exec or debug container: `kubectl exec -it <name> -- sh`.  
4) Identify failing command/probe and missing dependencies or files.  
5) Patch manifest; reapply and verify pod readiness.  

## Tasks
- Find the crash root cause (hint: missing runtime dependency).
- Fix the manifest so the pod runs and stays Ready.
- Apply production basics: non-root, resource requests/limits, probes, and remove any `:latest`-style images.
- Provide your fixed manifest (or kustomize overlay) in `solution/`.

## Success Criteria
- [ ] Pods reach `Running` + `Ready` consistently (no restarts climbing).
- [ ] Root cause documented in your `solution/README.md`.
- [ ] Security contexts set (non-root, drop caps, read-only root FS).
- [ ] Resource requests/limits defined.
- [ ] Liveness/readiness probes passing.

## Scoring Notes
- 🟢 Must have: root cause identified, pod stable, security context + limits.
- 🟡 Nice to have: HPA or PDB for availability, ConfigMap separation, and brief runbook steps.
- 🔴 Avoid: masking failures (e.g., `|| true`) without fixing the underlying issue.
