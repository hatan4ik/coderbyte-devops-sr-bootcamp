# Solution – Basic CI Pipeline

## Approach
- Minimal lint/test/build pipeline with PR status checks.

## Steps
- Trigger on PR and main; steps for lint + unit tests; build artifact.
- Fail on errors; cache dependencies; surface statuses in PR.
- Document local equivalents.

## Validation
- Clean code passes; intentional lint/test failure blocks PR; artifact available.
