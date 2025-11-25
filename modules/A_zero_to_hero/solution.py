#!/usr/bin/env python3
import requests
import sys

API_URL = "https://jsonplaceholder.typicode.com/users"

def fetch_first_user():
    """Fetches users from an API and prints the first user's details."""
    try:
        response = requests.get(API_URL, timeout=10)
        response.raise_for_status()  # Raise an exception for bad status codes
        users = response.json()
        if users:
            first_user = users[0]
            print(f"Name: {first_user.get('name')}")
            print(f"Email: {first_user.get('email')}")
    except requests.exceptions.RequestException as e:
        print(f"Error fetching data: {e}", file=sys.stderr)

if __name__ == "__main__":
    fetch_first_user()