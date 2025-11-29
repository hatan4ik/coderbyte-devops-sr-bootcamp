# Problem 1: Automated Cost Optimization with Compute Optimizer

**Difficulty**: 🟡 Medium (60 minutes)  
**Category**: Cost Optimization, FinOps, Automation

## Problem Statement

Build an automated cost optimization system that:
- Analyzes EC2, RDS, Lambda usage
- Recommends rightsizing opportunities
- Implements changes automatically (with approval)
- Tracks savings over time
- Generates monthly reports

**Current State**:
- 500 EC2 instances (mix of sizes)
- 50 RDS databases
- 200 Lambda functions
- Monthly cost: $150,000
- Target: 30% reduction ($45,000 savings)

**Requirements**:
1. Use AWS Compute Optimizer for recommendations
2. Cost Explorer API for historical data
3. Lambda for automation
4. SNS for approval workflow
5. DynamoDB for tracking
6. CloudWatch for monitoring
7. S3 for reports

**Optimization Strategies**:
- Rightsize over-provisioned instances
- Convert to Graviton2 (ARM)
- Use Spot for fault-tolerant workloads
- Reserved Instances for steady-state
- Savings Plans for flexible commitment
- Lambda memory optimization
- RDS instance class optimization

## Architecture

```
┌──────────────┐
│   Compute    │
│  Optimizer   │
└──────┬───────┘
       │ Recommendations
       ▼
┌──────────────┐      ┌──────────────┐
│   Lambda     │─────▶│  DynamoDB    │
│ Analyzer     │      │  (Tracking)  │
└──────┬───────┘      └──────────────┘
       │
       │ High Impact
       ▼
┌──────────────┐
│     SNS      │
│  (Approval)  │
└──────┬───────┘
       │ Approved
       ▼
┌──────────────┐
│   Lambda     │
│ Executor     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   EC2/RDS    │
│  (Modified)  │
└──────────────┘
```

## Expected Deliverables

1. Lambda function to fetch recommendations
2. Approval workflow with SNS
3. Automated execution Lambda
4. Tracking database schema
5. Monthly report generator
6. Terraform infrastructure
7. Cost savings dashboard

## Success Criteria

- Identify $45K+ in savings opportunities
- Automate low-risk changes (< $100/month)
- Approval workflow for high-risk changes
- Zero downtime during modifications
- Track actual vs projected savings
- Monthly executive report
