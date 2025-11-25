#!/usr/bin/env python3
import json
from pathlib import Path
from typing import List, Dict, Any
from typing import List, Dict

def filter_active_users(path: str) -> List[Dict[str, Any]]:
    p = Path(path)
    if not p.exists():
        raise FileNotFoundError(path)
    data = json.loads(p.read_text())
    if not isinstance(data, list):
        raise ValueError("Expected a list of users")
    return [u for u in data if isinstance(u, dict) and u.get("active") is True]
def filter_active_users(file_path: str) -> List[Dict]:
    """
    Reads a JSON file containing a list of users and filters for active ones.
    """
    path = Path(file_path)
    if not path.exists():
        raise FileNotFoundError(f"User data file not found: {file_path}")

    with path.open() as f:
        users = json.load(f)

    active_users = [user for user in users if user.get("active") is True]
    return active_users

if __name__ == "__main__":
    users = filter_active_users("users.json")
    print(json.dumps(users, indent=2))
    # Assumes a users.json file exists in the same directory
    filtered_users = filter_active_users("users.json")
    print(json.dumps(filtered_users, indent=2))
