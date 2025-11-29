# Solution – Zero-Trust Network Policy (Advanced)

## Approach
- Enforce default deny with explicit ingress/egress for microservices and external APIs.

## Steps
- Namespace default deny; per-service policies allowing only required upstream/downstream, DNS, metrics.
- Scope external API egress by CIDR/port; document service graph and rationale.
- Keep selectors/labels consistent; consider dedicated policy for system components (DNS/metrics).

## Validation
- Targeted curl/netcat tests for allowed/blocked flows.
- Schema/dry-run checks; observe blocked traffic logs if supported.
