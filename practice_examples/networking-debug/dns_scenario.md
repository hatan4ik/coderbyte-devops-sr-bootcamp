# DNS/CoreDNS Debug Scenario

## Setup
1) Deploy test pod:
```bash
kubectl apply -f dns_test_pod.yaml
kubectl exec -it dns-debug -- nslookup kubernetes.default
```

2) Simulate CoreDNS misconfig (e.g., bad upstream):
```bash
kubectl -n kube-system get cm coredns -o yaml > /tmp/coredns.yaml
# Edit /tmp/coredns.yaml and set an invalid forwarder, e.g., 203.0.113.1
kubectl -n kube-system apply -f /tmp/coredns.yaml
kubectl -n kube-system rollout restart deploy coredns
```

## Detect
- `kubectl -n kube-system logs deploy/coredns` (look for SERVFAIL/refused)
- `kubectl get events --sort-by=.metadata.creationTimestamp`
- From dns-debug pod: `nslookup kubernetes.default`, `nslookup google.com` (failures expected)
- Check kubelet/cni logs if needed.

## Debug Checklist
- Verify CoreDNS ConfigMap forwarders are reachable.
- Ensure NetworkPolicy isn't blocking DNS (TCP/UDP 53).
- Check pod resolv.conf inside workload pods.
- Confirm coredns pods are Ready and endpoints exist.

## Rollback/Fix
- Restore previous ConfigMap (or set known-good upstreams: `8.8.8.8`, `1.1.1.1`).
- `kubectl -n kube-system apply -f /tmp/coredns.yaml`
- `kubectl -n kube-system rollout restart deploy coredns`
- Re-test: `kubectl exec -it dns-debug -- nslookup kubernetes.default`

## Cleanup
```bash
kubectl delete -f dns_test_pod.yaml
```
