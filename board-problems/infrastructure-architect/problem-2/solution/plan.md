# Cost Optimization Plan (Template)

## Scope
- Workload: describe app/infra
- Region(s): list
- Assumptions: traffic patterns, growth, SLAs

## Recommendations
- **Compute rightsizing**: instance families, autoscaling settings; projected savings.
- **RIs/Savings Plans**: term, coverage %, upfront choice; estimated savings.
- **Storage lifecycle**: S3 lifecycle to IA/Glacier; EBS snapshot policies; projected savings.
- **Data transfer**: VPC endpoints, CDN/cache, peering choices.
- **Guardrails**: Budgets/alerts, anomaly detection, tagging for cost allocation.

## Enforcement
- Terraform snippets for lifecycle/budgets where applicable.
- Monitoring dashboards/alerts for spend and usage.

## Next Steps
- Pilot in lower env; measure impact; adjust.
- Roll out to prod with rollback criteria.
