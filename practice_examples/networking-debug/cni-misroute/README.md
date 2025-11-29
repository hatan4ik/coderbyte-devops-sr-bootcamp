# CNI/Iptables Misroute Drill

Simulate a misroute by injecting a bad iptables rule and walk through detection and cleanup.

## Scenario
1. Run a test pod (reuse `../dns_test_pod.yaml`).
2. Inject a bogus iptables DROP for DNS traffic on the node.
3. Observe DNS failures, identify via `iptables-save`, and clean up.

## Steps
```bash
# From a node shell (CAUTION: modify as per your safety sandbox)
iptables -I OUTPUT -p udp --dport 53 -j DROP

# Test from pod
kubectl exec -it dns-debug -- nslookup kubernetes.default   # should fail

# Detect
iptables-save | grep 53

# Cleanup
iptables -D OUTPUT -p udp --dport 53 -j DROP
kubectl exec -it dns-debug -- nslookup kubernetes.default   # should succeed
```

Use only in a controlled environment (kind/k3d). Do NOT run on shared/prod clusters.
Tests: manual—confirm failure after DROP and success after cleanup.
