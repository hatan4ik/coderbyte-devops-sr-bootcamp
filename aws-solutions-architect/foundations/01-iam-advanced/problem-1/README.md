# Problem 1: ABAC for Project-Based Access

**Difficulty**: 🔴 Hard (60 minutes)  
**Category**: IAM, Security, Multi-Account

## Problem Statement

Your organization has 500 developers working on 50 different projects across 3 environments (dev, staging, prod). Currently, you have 25,000+ IAM policies creating management overhead and security risks.

**Requirements**:
1. Implement ABAC using tags for dynamic access control
2. Developers can only access resources tagged with their project
3. Environment-based restrictions (devs can't access prod)
4. No policy updates needed when adding new projects
5. Audit trail for all access decisions

**Constraints**:
- Use IAM roles, not users
- Implement least privilege
- Support cross-account access
- Enable CloudTrail logging

## Solution Architecture

```
Developer → AssumeRole (with tags) → IAM Role (ABAC policy) → Resources (tagged)
                                            ↓
                                      CloudTrail Audit
```

## Expected Deliverables

1. IAM role with ABAC policy
2. Terraform code for role and policy
3. Example resource tagging strategy
4. Test script to validate access
5. CloudTrail query for audit

## Success Criteria

- Developer with `Project=Alpha` can access only Alpha resources
- Developer with `Environment=dev` cannot access prod resources
- Adding new project requires zero policy changes
- All access logged to CloudTrail
