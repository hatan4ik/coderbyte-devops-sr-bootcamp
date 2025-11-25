# Mock Exam #9 – Linux Systems Debugging

## Scenario
A small service keeps restarting on a Linux host. Use the provided logs and script to identify and fix the issue, and suggest guardrails to prevent regression.

## Requirements
1. **Debug**
   - Review `starter/logs/app.log` and `starter/broken_service.sh` to find why the service exits.
   - Produce a fixed version (`starter/fixed_service.sh`) with a short comment explaining the root cause.
2. **Hardening**
   - Add basic health checks (e.g., verify dependency binaries exist) and sane defaults for environment variables.
   - Write a `systemd` unit file (`starter/sample.service`) that restarts on failure with jittered delays.
3. **Verification**
   - Add a short `starter/README.md` describing how you validated the fix (e.g., run in a loop for 30s) and which logs/commands you inspected.

### Deliverables
- Fixed script + unit file.
- Notes in README summarizing the root cause and validation steps.
