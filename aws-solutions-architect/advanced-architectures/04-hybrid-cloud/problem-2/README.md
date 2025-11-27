# Problem 2: VMware Cloud on AWS Integration

**Difficulty**: 🔴 Hard (90 minutes)  
**Category**: Hybrid Cloud, VMware, Migration

## Problem Statement

Integrate on-premises VMware with AWS:

**Requirements**:
- VMware Cloud on AWS (SDDC)
- Hybrid networking (ENI)
- VM migration (HCX)
- Disaster recovery
- Unified management
- Cost optimization

**Components**:
- VMware Cloud on AWS
- Elastic Network Interface
- HCX for migration
- Site Recovery Manager
- vCenter integration
- CloudWatch monitoring

## Architecture

```
On-Prem vSphere → HCX → VMware Cloud on AWS → Native AWS Services
                           ↓
                      ENI → VPC → S3/RDS/Lambda
```
