# Problem 2: Centralized Security with Security Hub

**Difficulty**: 🔴 Hard (90 minutes)  
**Category**: Multi-Account, Security, Compliance

## Problem Statement

Implement centralized security monitoring across 20+ accounts:

**Requirements**:
- Security Hub aggregation
- GuardDuty findings
- Config compliance
- Automated remediation
- Custom security standards
- Executive dashboards

**Components**:
- Security Hub (delegated admin)
- GuardDuty (multi-account)
- Config (organization-wide)
- Lambda for remediation
- EventBridge for routing
- SNS for alerts

## Architecture

```
Member Accounts → Security Hub → EventBridge → Lambda (Remediation)
                      ↓                            ↓
                  Findings                    SNS Alerts
```
