# Problem 1: Multi-Account Landing Zone with Control Tower

**Difficulty**: 🔴 Hard (120 minutes)  
**Category**: Multi-Account, Governance, Security

## Problem Statement

Design and implement a multi-account AWS environment using Control Tower:

**Account Structure**:
- Management Account (root)
- Security Account (CloudTrail, Config, GuardDuty)
- Log Archive Account (centralized logging)
- Shared Services Account (networking, DNS)
- Dev Account
- Staging Account
- Prod Account

**Requirements**:
- Control Tower setup with Account Factory
- Service Control Policies (SCPs)
- Transit Gateway hub-spoke networking
- Centralized CloudTrail and Config
- Security Hub aggregation
- Cross-account IAM roles
- Cost allocation tags
- Automated account vending

## Architecture

```
Management Account
    ├── Organizations
    ├── Control Tower
    └── SCPs
         ↓
    ┌────┴────┬────────┬──────────┬─────────┐
    │         │        │          │         │
Security  LogArchive Shared   Workload  Workload
Account   Account    Services  (Dev)     (Prod)
    │         │        │          │         │
GuardDuty CloudTrail TGW Hub   Apps      Apps
SecHub    Config     Route53
```

## Expected Deliverables

1. Control Tower setup guide
2. SCP policies
3. Account Factory automation
4. Transit Gateway Terraform
5. Cross-account roles
6. Centralized logging
7. Compliance dashboard
