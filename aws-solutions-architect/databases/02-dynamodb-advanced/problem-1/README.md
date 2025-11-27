# Problem 1: DynamoDB Single-Table Design for Multi-Tenant SaaS

**Difficulty**: 🔴 Hard (90 minutes)  
**Category**: Database, NoSQL, Architecture

## Problem Statement

Design a single-table DynamoDB schema for a multi-tenant SaaS application with:
- 10,000+ tenants (organizations)
- 1M+ users across all tenants
- 100M+ records (orders, products, invoices)
- Complex access patterns
- Strong consistency for financial data
- Global secondary indexes for queries
- DynamoDB Streams for event processing

**Access Patterns**:
1. Get user by email
2. Get all users in organization
3. Get user's orders (sorted by date)
4. Get organization's revenue (aggregated)
5. Get product inventory across all warehouses
6. Get invoice by ID
7. List all invoices for organization (paginated)
8. Get top customers by spend

**Requirements**:
- Single table design (no joins)
- Partition key design for even distribution
- GSIs for alternate access patterns
- TTL for temporary data
- Point-in-time recovery
- Encryption at rest
- Auto-scaling for capacity
- Cost < $500/month for 1M requests/day

## Schema Design

```
PK                          SK                      GSI1PK              GSI1SK
ORG#<orgId>                 METADATA                -                   -
ORG#<orgId>                 USER#<userId>           USER#<email>        ORG#<orgId>
ORG#<orgId>                 ORDER#<orderId>         USER#<userId>       ORDER#<timestamp>
ORG#<orgId>                 PRODUCT#<productId>     CATEGORY#<cat>      PRODUCT#<name>
ORG#<orgId>                 INVOICE#<invoiceId>     STATUS#<status>     INVOICE#<date>
```

## Expected Deliverables

1. Terraform for DynamoDB table with GSIs
2. Python data access layer with all patterns
3. Load testing script (1M requests)
4. Cost analysis and optimization
5. Backup and restore strategy
6. Monitoring and alerting

## Success Criteria

- All 8 access patterns < 10ms p99
- Even partition distribution (no hot keys)
- Cost under budget
- Zero data loss with PITR
- Auto-scaling working correctly
