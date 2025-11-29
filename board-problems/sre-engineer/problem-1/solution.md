# Solution – Implement SLOs and Alerts

## Approach
- Define SLIs/SLOs and align alerts to error budget burn rates.

## Steps
- Select SLIs (latency, availability, error rate); set SLO targets.
- Implement multi-window burn-rate alerts (fast + slow) with runbook links.
- Tag alerts with ownership/severity; document error budgets and review cadence.

## Validation
- Simulate load/failures to trigger alerts; verify routing.
- Dashboards show SLOs and burn-down; noise level acceptable.
