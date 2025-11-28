# Solution: Pod CrashLoopBackOff (Missing Config)

## Root Cause
- The container command `cat ${CONFIG_PATH}` failed because `/config/settings.yaml` did not exist.
- The `config` volume was an `emptyDir`, so the file was never provided.
- The container exited with non-zero status → Kubernetes marked it `CrashLoopBackOff`.

## Fix Applied
- Added a ConfigMap (`api-debug-config`) providing `settings.yaml`.
- Mounted the ConfigMap read-only at `/config` and kept the container running after startup.
- Hardened the pod: non-root UID/GID, dropped capabilities, read-only root filesystem, seccomp `RuntimeDefault`.
- Added resource requests/limits and liveness/readiness probes that validate the config file is present.
- Switched to an explicit image tag (`busybox:1.36`) with `IfNotPresent` pull policy.

## How to Test
```bash
kubectl apply -f solution/deployment.yaml
kubectl rollout status deployment/api-debug
kubectl get pods -l app=api-debug
kubectl logs deployment/api-debug
```
- Probes: `kubectl describe pod <pod> | grep -A3 -e Liveness -e Readiness`
- Validate config: `kubectl exec -it <pod> -- cat /config/settings.yaml`

## Runbook (if it crash-loops again)
1. `kubectl get pods -l app=api-debug` (check restarts climb).  
2. `kubectl describe pod <pod>` (events for probe failures or mounts).  
3. `kubectl logs <pod> --previous` (last crash reason).  
4. `kubectl exec -it <pod> -- ls -l /config && cat /config/settings.yaml` (confirm file).  
5. If config missing, ensure ConfigMap exists and mount name/path match; reapply manifest.
