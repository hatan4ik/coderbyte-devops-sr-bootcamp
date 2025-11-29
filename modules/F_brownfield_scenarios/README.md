# Module F: Brownfield Scenarios (Archived)

> Canonical brownfield/state-refactor content now lives in `modules/F_state_refactoring/` (AWS-only, import + `terraform state mv` drills). This module remains for reference/legacy scenarios only; treat it as optional reading.

Real-world DevOps challenges: state migration, dependency conflicts, legacy refactoring.

## Scenarios

### 01 - Terraform State Migration
**Problem:** Import existing AWS resources into Terraform management  
**Skills:** `terraform import`, `terraform state mv`, state surgery  
**Time:** 45 minutes

### 02 - Dependency Conflicts
**Problem:** Resolve conflicting Python sub-dependencies  
**Skills:** Poetry, pip-tools, dependency resolution  
**Time:** 30 minutes

### 03 - Legacy Refactor
**Problem:** Incrementally refactor unmaintainable Bash to Python  
**Skills:** Strangler pattern, test-first refactoring  
**Time:** 60 minutes

## Why This Module

Senior DevOps is 80% brownfield. Teaches:
- Working with existing infrastructure
- Managing technical debt
- Incremental improvement strategies
- Trade-offs in refactoring decisions

## Prerequisites

- Module A (fundamentals)
- Module C (full project)
- Terraform and Python packaging familiarity
