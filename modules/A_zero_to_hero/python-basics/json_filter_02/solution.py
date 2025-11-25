#!/usr/bin/env python3
import json
from pathlib import Path
from typing import List, Dict, Any

def filter_active_users(path: str) -> List[Dict[str, Any]]:
    p = Path(path)
    if not p.exists():
        raise FileNotFoundError(path)
    data = json.loads(p.read_text())
    if not isinstance(data, list):
        raise ValueError("Expected a list of users")
    return [u for u in data if isinstance(u, dict) and u.get("active") is True]

if __name__ == "__main__":
    users = filter_active_users("users.json")
    print(json.dumps(users, indent=2))
