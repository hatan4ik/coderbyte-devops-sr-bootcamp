# Problem 1: Hybrid Cloud with Direct Connect and Outposts

**Difficulty**: 🔴 Hard (120 minutes)  
**Category**: Hybrid Cloud, Networking, Edge Computing

## Problem Statement

Design hybrid cloud architecture connecting on-premises datacenter to AWS:

**Components**:
- On-premises datacenter (VMware)
- AWS Direct Connect (10 Gbps)
- AWS Outposts rack
- VPN backup connection
- Hybrid DNS (Route 53 Resolver)
- Hybrid storage (Storage Gateway)
- Hybrid identity (AD Connector)

**Requirements**:
- < 5ms latency for critical apps
- 99.99% availability
- Seamless failover
- Unified monitoring
- Compliance (data residency)
- Cost optimization

## Architecture

```
On-Premises DC
    ├── VMware vSphere
    ├── Active Directory
    ├── File Servers
    └── Applications
         │
         ├─── Direct Connect (Primary) ───┐
         │                                 │
         └─── VPN (Backup) ───────────────┤
                                           │
                                      ┌────▼────┐
                                      │   AWS   │
                                      │  Region │
                                      └────┬────┘
                                           │
                                      ┌────▼────┐
                                      │ Outposts│
                                      │  Rack   │
                                      └─────────┘
```

## Expected Deliverables

1. Direct Connect setup guide
2. VPN backup configuration
3. Outposts deployment
4. Hybrid DNS setup
5. Storage Gateway config
6. Monitoring dashboard
7. DR runbook
