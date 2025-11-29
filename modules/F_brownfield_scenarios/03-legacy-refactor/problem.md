# Problem: Legacy Script Refactor

## Scenario

You inherited a 500-line Bash deployment script with:
- No error handling
- Hardcoded credentials
- No tests
- Global state mutations

Critical to production. Can't rewrite all at once.

## Requirements

1. Refactor incrementally using Strangler pattern
2. Add tests before changing behavior
3. Extract one function to Python
4. Maintain backward compatibility

## Files

- `legacy-deploy.sh` - Unmaintainable script
- `deploy-wrapper.py` - Starter for new implementation

## Success Criteria

- [ ] At least one function extracted to Python
- [ ] Tests cover extracted function
- [ ] Original script still works
- [ ] New code follows FAANG standards (Result monad, types)

## Time: 60 minutes

## Hints

- Start with pure functions (no side effects)
- Use subprocess to call remaining Bash
- Add type hints and error handling to Python
- Test both old and new paths
