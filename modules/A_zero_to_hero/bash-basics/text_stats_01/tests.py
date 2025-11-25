import subprocess
from pathlib import Path

def main():
    print("Running text_stats_01 tests...")
    tmp = Path(".tmp_txt01")
    tmp.mkdir(exist_ok=True)
    f = tmp / "sample.txt"
    f.write_text("hello world\nthis is a test\n")
    result = subprocess.check_output(
        ["bash", "text_stats_01/text_stats.sh", str(f)],
        cwd=str(Path(__file__).parent),
        text=True,
    )
    lines = dict(line.strip().split("=", 1) for line in result.strip().splitlines())
    assert lines["lines"] == "2"
    assert lines["words"] == "6"
    print("OK")
    for c in tmp.iterdir():
        c.unlink()
    tmp.rmdir()

if __name__ == "__main__":
    main()
