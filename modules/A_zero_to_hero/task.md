# API Client 06 – Public API Fetcher

Write a Python script that fetches user data from the JSONPlaceholder public API and prints the name and email of the first user.

The script must:
1.  Make an HTTP GET request to `https://jsonplaceholder.typicode.com/users`.
2.  Parse the JSON response.
3.  Extract and print the `name` and `email` of the first user in the list.
4.  Use the `requests` library.

Expected output:
```
Name: Leanne Graham
Email: Sincere@april.biz
```