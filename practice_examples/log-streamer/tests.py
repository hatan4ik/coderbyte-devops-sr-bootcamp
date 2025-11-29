#!/usr/bin/env python3
import json
from pathlib import Path

from stream import run


def test_run_counts(tmp_path: Path):
    f1 = tmp_path / "a.log"
    f2 = tmp_path / "b.log"
    f1.write_text("INFO ok\nERROR bad\nerror worse\n")
    f2.write_text("WARN meh\nINFO\n")

    result = run([str(f1), str(f2)])

    assert result["total_lines"] == 5
    assert result["total_errors"] == 2
    assert result["files"][str(f1)]["errors"] == 2
    assert result["files"][str(f2)]["errors"] == 0


if __name__ == "__main__":
    test_run_counts(Path("."))
    print(json.dumps({"status": "ok"}, indent=2))
