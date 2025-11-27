# Problem 03: Multi-Region Terraform Module 🔴

**Time**: 60 min | **Difficulty**: Hard | **Points**: 150

## Scenario
Create reusable Terraform module for multi-region deployment with DR.

## Requirements
1. VPC module (reusable across regions)
2. Multi-region deployment (primary + DR)
3. Cross-region replication
4. Failover configuration
5. Cost optimization
6. Complete documentation

## Architecture
```
Primary Region (us-east-1)
├── VPC + Subnets
├── EKS Cluster
├── RDS Primary
└── S3 with replication

DR Region (us-west-2)
├── VPC + Subnets
├── EKS Cluster (standby)
├── RDS Replica
└── S3 replica bucket
```

## Deliverables
```
solution/
├── modules/
│   ├── vpc/
│   ├── eks/
│   └── rds/
├── environments/
│   ├── primary/
│   └── dr/
└── README.md
```

## Success Criteria
- [ ] Module reusable
- [ ] Multi-region works
- [ ] Failover tested
- [ ] Cost optimized
- [ ] Passes validation
