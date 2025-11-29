# Problem: Dependency Conflicts

## Scenario

Your Python app requires:
- `requests==2.28.0` (API client)
- `boto3==1.26.0` (AWS SDK)

But `boto3` depends on `urllib3<1.27`, while `requests` needs `urllib3>=1.26,<2.0`.

`pip install` fails with conflict.

## Requirements

1. Resolve the dependency conflict
2. Use Poetry or pip-tools (not manual pinning)
3. Document the resolution strategy
4. Ensure both packages work

## Files

- `requirements-broken.txt` - Conflicting requirements
- `test_app.py` - Tests requiring both packages

## Success Criteria

- [ ] All dependencies install without conflicts
- [ ] Tests pass
- [ ] Modern dependency management used
- [ ] Documentation explains conflict

## Time: 30 minutes

## Hints

- Poetry's resolver is more sophisticated than pip
- Check `poetry show --tree` for dependency graph
- Use version ranges instead of exact pins
- Test with fresh virtual environment
