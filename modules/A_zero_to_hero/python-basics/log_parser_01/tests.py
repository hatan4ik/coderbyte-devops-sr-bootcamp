from pathlib import Path
from solution import parse_log

def write_sample_log(tmp: Path):
    data = """2024-11-03 12:27:01 ERROR login failed: user=admin ip=10.10.1.5
2024-11-03 12:27:05 INFO health ok
2024-11-03 12:28:04 ERROR login failed: user=root ip=10.10.1.5
"""
    p = tmp / "server.log"
    p.write_text(data)
    return p

def main():
    print("Running log_parser_01 tests...")
    tmp = Path(".tmp_log01")
    tmp.mkdir(exist_ok=True)
    log_file = write_sample_log(tmp)
    result = parse_log(str(log_file))
    assert result["failed_attempts"] == 2
    assert set(result["unique_users"]) == {"admin", "root"}
    print("OK")
    for child in tmp.iterdir():
        child.unlink()
    tmp.rmdir()

if __name__ == "__main__":
    main()
