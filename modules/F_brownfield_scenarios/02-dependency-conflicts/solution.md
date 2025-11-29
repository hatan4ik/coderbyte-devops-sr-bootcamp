# Solution: Dependency Conflicts

## Option 1: Poetry (Recommended)

```bash
poetry init
poetry add requests boto3
poetry install
```

Poetry automatically resolves to compatible versions:
- `requests==2.31.0`
- `boto3==1.34.0`
- `urllib3==2.0.7` (compatible with both)

## Option 2: pip-tools

```bash
# requirements.in
requests>=2.28
boto3>=1.26

# Compile
pip-compile requirements.in
pip install -r requirements.txt
```

## Why It Works

Poetry uses a SAT solver that finds compatible version ranges. It upgrades `requests` to a version compatible with newer `urllib3`.

## Verification

```bash
poetry run python -c "import requests, boto3; print('OK')"
poetry show --tree  # View dependency graph
```

## Key Learnings

- Exact version pins cause conflicts
- Use version ranges for flexibility
- Modern tools (Poetry) have better resolvers than pip
- Always check dependency tree with `poetry show --tree`
