# Incident Response Runbook (App Service)

## Triggers
- Paged alerts: HighErrorBudgetBurn, HighLatencyP99, Elevated5xx.
- Ticket alerts: Slow burn or warning-level SLO drift.

## Contacts
- Primary on-call: @sre-oncall
- Escalation: @sre-lead after 15m
- Channels: #alerts-app, PagerDuty schedule: SRE-App

## Diagnostics (0-5 minutes)
1. Acknowledge page; post in #alerts-app.
2. Check dashboards: latency/error panels, burn rate.
3. Pull recent deploys: `git log -1`, CI status.
4. Inspect logs for spikes/errors; check dependency status pages.

## Mitigation (5-15 minutes)
1. Roll back last deploy if correlated.
2. Scale up if saturation; ensure HPA healthy.
3. Disable noncritical features/traffic splitting if available.

## Communication
- Initial note: Incident start time, symptoms, suspected cause, actions.
- Update every 15 minutes; note decisions and rollbacks.

## Recovery
- Verify metrics back to normal; error budget burn acceptable.
- Re-enable disabled features; confirm deploy state.

## Post-incident
- Open ticket with timeline and root cause.
- Schedule retro within 48h; create follow-up action items.
