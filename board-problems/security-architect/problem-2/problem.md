# Problem 02: Network Policy Zero-Trust 🟡

**Time**: 35 min | **Points**: 100

## Scenario
Implement zero-trust network policies for microservices.

## Given Architecture
- Frontend (port 3000)
- Backend API (port 8080)
- Database (port 5432)
- Currently: All pods can talk to all pods

## Requirements
1. Default deny all traffic
2. Frontend → Backend only
3. Backend → Database only
4. Allow DNS (port 53)
5. Block all other traffic

## Deliverables
- [ ] NetworkPolicy manifests
- [ ] Test commands
- [ ] Verification script

## Success
- [ ] Default deny works
- [ ] Allowed traffic passes
- [ ] Blocked traffic fails
- [ ] DNS works
