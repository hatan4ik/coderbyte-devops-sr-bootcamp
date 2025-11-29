# Solution: Legacy Refactor

## Step 1: Extract Pure Function

Identify a pure function in `legacy-deploy.sh`:

```bash
# Original Bash
validate_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Config missing"
        exit 1
    fi
}
```

## Step 2: Rewrite in Python

```python
# deploy_wrapper.py
from pathlib import Path
from typing import Result

def validate_config(config_path: str) -> Result[bool, str]:
    if not Path(config_path).exists():
        return Err(f"Config missing: {config_path}")
    return Ok(True)
```

## Step 3: Add Tests

```python
# test_deploy.py
def test_validate_config_exists(tmp_path):
    config = tmp_path / "config.yml"
    config.write_text("key: value")
    assert validate_config(str(config)).is_ok()

def test_validate_config_missing():
    result = validate_config("/nonexistent")
    assert result.is_err()
```

## Step 4: Call from Bash

```bash
# legacy-deploy.sh
if python3 deploy_wrapper.py validate "$CONFIG_FILE"; then
    echo "Config valid"
else
    exit 1
fi
```

## Key Learnings

- Start with pure functions (no side effects)
- Add tests before refactoring
- Maintain backward compatibility
- Incremental migration reduces risk
- Use subprocess to bridge Bash/Python
