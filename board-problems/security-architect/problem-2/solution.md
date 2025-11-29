# Solution – Network Policy Zero-Trust

## Approach
- Default deny all traffic; allow only required frontend→backend and backend→database flows, plus DNS.

## Steps
- Apply namespace-level default deny ingress/egress.
- Frontend egress: backend on TCP 8080; allow DNS egress on UDP 53.
- Backend ingress: from frontend on TCP 8080; backend egress: database on TCP 5432 and DNS on UDP 53.
- Database ingress: from backend on TCP 5432.
- Keep labels/selectors consistent; include test commands (`curl`/`nc`) and verification script.

## Validation
- Allowed flows succeed; others fail.
- DNS resolution works.
- `kubectl apply --dry-run=client -f solution/networkpolicy.yaml` passes; functional tests via `kubectl exec` confirm enforcement.
