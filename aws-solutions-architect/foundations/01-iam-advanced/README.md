# IAM Advanced: ABAC, Permission Boundaries, Federation

Production-grade IAM patterns for enterprise environments.

## 🎯 Topics

### 1. Attribute-Based Access Control (ABAC)
Tag-based permissions for dynamic access control without policy updates.

### 2. Permission Boundaries
Delegate permission management safely with maximum permission limits.

### 3. IAM Federation
SAML 2.0 and OIDC integration for SSO with external identity providers.

### 4. Service Control Policies (SCPs)
Organization-wide guardrails for multi-account environments.

### 5. IAM Access Analyzer
Automated policy validation and external access detection.

## 📚 Problems

- **Problem 1**: 🔴 Implement ABAC for project-based access (60 min)
- **Problem 2**: 🟡 Create permission boundary for developers (45 min)
- **Problem 3**: 🟡 Setup OIDC federation with GitHub Actions (45 min)
- **Problem 4**: 🔴 Design SCP strategy for organization (60 min)
- **Problem 5**: 🟢 Implement least privilege with Access Analyzer (30 min)

## 🏢 Real-World Scenario

**Challenge**: 500+ developers across 50 projects need dynamic access without creating individual policies for each combination.

**Solution**: ABAC with project and environment tags.

**Impact**: Reduced IAM policies from 25,000+ to 5 base policies.
