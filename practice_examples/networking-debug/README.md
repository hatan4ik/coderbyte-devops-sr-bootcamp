# Networking/Linux Debug Scenarios

Two lightweight scenarios: a CPU hog diagnosis checklist and a CoreDNS/DNS failure drill with reproducible samples.

## Files
- `cpu_hog.sh` — Simple CPU hog to reproduce high CPU; includes a diagnostic checklist.
- `dns_scenario.md` — Steps to simulate and debug CoreDNS misconfig (bad ConfigMap), commands to verify and fix.
- `dns_test_pod.yaml` — Busybox test pod to run `nslookup/dig` inside cluster.
- `cni-misroute/` — Optional drill to inject/fix DNS DROP iptables rule (sandbox only).

## Usage
```bash
# CPU hog
./cpu_hog.sh &   # in one terminal
# In another, run the checklist commands (ps/top/htop/strace/lsof)

# DNS test pod
kubectl apply -f dns_test_pod.yaml
kubectl exec -it dns-debug -- nslookup kubernetes.default
```

Use `dns_scenario.md` to introduce a broken CoreDNS ConfigMap and then walk through detection/rollback.
Tests: manual—observe CPU spike and identify with tools; for DNS drills, confirm failure then recovery after fix.
