# Problem 1: Multi-Region Transit Gateway with Hub-Spoke

**Difficulty**: 🔴 Hard (90 minutes)  
**Category**: Networking, Multi-Region, High Availability

## Problem Statement

Design and implement a multi-region hub-spoke network architecture using Transit Gateway for a global enterprise with:
- 3 regions (us-east-1, eu-west-1, ap-southeast-1)
- 20 VPCs per region (dev, staging, prod environments)
- Centralized egress through inspection VPC
- Cross-region connectivity with encryption
- Route propagation and isolation

**Requirements**:
1. Transit Gateway in each region with peering
2. Hub-spoke topology with centralized inspection
3. Environment isolation (dev cannot reach prod)
4. Centralized egress for internet traffic
5. VPN connectivity to on-premises
6. Flow logs for all traffic
7. Cost optimization with resource sharing

**Constraints**:
- Latency < 50ms for intra-region
- Bandwidth > 10 Gbps per VPC
- BGP for dynamic routing
- Encryption in transit

## Architecture

```
                    ┌─────────────────┐
                    │   On-Premises   │
                    └────────┬────────┘
                             │ VPN
                    ┌────────▼────────┐
                    │  TGW us-east-1  │◄──────┐
                    └────────┬────────┘       │
                             │                │ Peering
        ┌────────────────────┼────────────────┼────────┐
        │                    │                │        │
   ┌────▼────┐         ┌────▼────┐     ┌────▼────┐   │
   │ Prod VPC│         │ Dev VPC │     │Insp VPC │   │
   └─────────┘         └─────────┘     └────┬────┘   │
                                             │        │
                                        NAT Gateway    │
                                             │        │
                                         Internet     │
                                                      │
                    ┌─────────────────────────────────┘
                    │
           ┌────────▼────────┐
           │  TGW eu-west-1  │
           └────────┬────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
   ┌────▼────┐            ┌────▼────┐
   │ Prod VPC│            │ Dev VPC │
   └─────────┘            └─────────┘
```

## Expected Deliverables

1. Terraform modules for TGW, VPCs, peering
2. Route tables with proper isolation
3. VPN configuration for on-premises
4. Flow logs and monitoring
5. Cost analysis and optimization
6. Disaster recovery plan

## Success Criteria

- All VPCs can communicate within environment
- Dev/Prod isolation enforced
- Internet traffic routes through inspection VPC
- Cross-region latency < 100ms
- VPN connectivity operational
- Flow logs capturing all traffic
