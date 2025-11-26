#!/usr/bin/env python3
"""Tiny app with a health function."""

def health() -> dict:
    return {"status": "ok"}

if __name__ == "__main__":
    import json
    print(json.dumps(health()))
