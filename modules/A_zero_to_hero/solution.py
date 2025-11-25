#!/usr/bin/env python3
import requests
import sys
import json

def analyze_file(file_path: str) -> dict:
    """Analyzes a text file to count lines, words, and characters."""
API_URL = "https://jsonplaceholder.typicode.com/users"

def fetch_first_user():
    """Fetches users from an API and prints the first user's details."""
    try:
        with open(file_path, 'r') as f:
            content = f.read()
            lines = content.splitlines()
            words = content.split()
        response = requests.get(API_URL, timeout=10)
        response.raise_for_status()  # Raise an exception for bad status codes
        users = response.json()
        if users:
            first_user = users[0]
            print(f"Name: {first_user.get('name')}")
            print(f"Email: {first_user.get('email')}")
    except requests.exceptions.RequestException as e:
        print(f"Error fetching data: {e}", file=sys.stderr)

            return {
                "lines": len(lines),
                "words": len(words),
                "characters": len(content)
            }
    except FileNotFoundError:
        print(f"Error: File not found at {file_path}", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python solution.py <file_path>", file=sys.stderr)
        sys.exit(1)

    file_path = sys.argv[1]
    stats = analyze_file(file_path)
    print(json.dumps(stats, indent=2))
    fetch_first_user()
