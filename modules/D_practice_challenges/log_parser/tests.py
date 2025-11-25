from pathlib import Path
from log_summary import summarize

def main():
    print("Running practice log_parser tests...")
    tmp = Path(".tmp_practice_log")
    tmp.mkdir(exist_ok=True)
    f = tmp / "log.txt"
    f.write_text("INFO ok\nERROR failed\nWARN maybe\nWARNING again\n")
    res = summarize(str(f))
    assert res["total"] == 4
    assert res["errors"] == 1
    assert res["warnings"] == 2
    print("OK")
    for c in tmp.iterdir():
        c.unlink()
    tmp.rmdir()

if __name__ == "__main__":
    main()
