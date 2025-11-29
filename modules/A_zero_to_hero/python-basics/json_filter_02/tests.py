from pathlib import Path
from solution import filter_active_users
import json

def main():
    print("Running json_filter_02 tests...")
    tmp = Path(".tmp_users02")
    tmp.mkdir(exist_ok=True)
    data = [
        {"name": "alice", "active": True},
        {"name": "bob", "active": False},
        {"name": "carol", "active": True},
    ]
    f = tmp / "users.json"
    f.write_text(json.dumps(data))
    res = filter_active_users(str(f))
    names = {u["name"] for u in res}
    assert names == {"alice", "carol"}
    print("OK")
    for c in tmp.iterdir():
        c.unlink()
    tmp.rmdir()

if __name__ == "__main__":
    main()
