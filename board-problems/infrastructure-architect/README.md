# Infrastructure Architect Problems - David Kim

**Focus**: Terraform architecture, multi-region design, cost optimization  
**Mantra**: "Infrastructure is code—design it to scale."

## Available Problems
- [Problem 1: Secure S3 Baseline](problem-1/problem.md) — Block public access, encryption, logging, IAM policy ([solution](problem-1/solution.md), [code](problem-1/solution))
- [Problem 2: Cost Optimization Plan](problem-2/problem.md) — Rightsizing, RIs/SPs, lifecycle policies, budgets ([solution](problem-2/solution.md), [code](problem-2/solution))
- [Problem 3: Multi-Region Terraform Module](problem-3/problem.md) — reusable VPC/EKS/RDS modules with replication, failover, and DR runbooks ([solution](problem-3/solution.md), [code](problem-3/solution))
- [Problem 4: Multi-Account Guardrails](problem-4/problem.md) — OU/SCP design, centralized logging, cross-account IAM ([solution](problem-4/solution.md), [code](problem-4/solution))

## How to Use
- Use the problem as a template for modular Terraform with clear inputs/outputs.
- Validate with `terraform fmt`, `validate`, `tflint`, and `tfsec` before declaring done.
- Document assumptions (regions, account layout, budgets) alongside your code.
