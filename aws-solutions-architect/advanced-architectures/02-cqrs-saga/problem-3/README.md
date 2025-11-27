# Problem 3: Inventory Management with CQRS

**Difficulty**: 🟡 Medium (60 minutes)  
**Category**: CQRS, Inventory, Real-Time

## Problem Statement

Build inventory system with real-time stock updates:

**Commands**:
- AddProduct
- AdjustStock
- ReserveStock
- ReleaseStock
- RecordSale

**Queries**:
- GetStockLevel
- GetLowStockAlerts
- GetStockHistory
- GetWarehouseInventory

**Requirements**:
- Real-time stock updates
- Prevent overselling
- Multi-warehouse support
- Stock alerts
- Audit trail

## Architecture

```
Commands → Event Store → Stream → Projector → Stock View
                                      ↓
                                  Alerts (SNS)
```
