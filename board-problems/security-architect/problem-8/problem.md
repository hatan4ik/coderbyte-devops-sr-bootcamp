# Problem 8 – Zero-Trust Network Policy

**Objective**: Apply zero-trust networking to a microservice namespace.

## Requirements
- Default deny all ingress/egress NetworkPolicies.
- Explicitly allow only required service-to-service and external calls.
- Include DNS and metrics/logging egress rules as needed.
- Provide verification steps (kubectl exec/curl/netcat tests).

## Deliverables
- NetworkPolicy manifests.
- README describing allowed flows and how to validate enforcement.
