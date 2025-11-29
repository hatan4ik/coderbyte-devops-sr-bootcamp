# Solution – Observability Dashboard

## Approach
- Build a Grafana dashboard for golden signals with burn-down visibility.

## Steps
- Panels for latency (p90/p99), traffic, errors, saturation; include SLIs/SLO targets.
- Add error budget burn-down and links to traces/logs.
- Configure alert rules with sensible thresholds and runbook links.

## Validation
- Import dashboard JSON; queries return expected data.
- Alert tests fire at thresholds; burn-down matches SLO math.
