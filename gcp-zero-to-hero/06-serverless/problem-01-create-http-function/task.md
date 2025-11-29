# Lab Task: Create an HTTP-Triggered Cloud Function

## Objective

Your task is to write and deploy a simple Cloud Function that responds to HTTP requests. The function will parse a name from the request's query string or body and return a greeting.

## Requirements

1.  **Function Code**:
    -   Create a directory for your function.
    -   Inside, create a `main.py` file to hold your Python code.
    -   The function should be able to parse a JSON request body for a `name` key, or a URL query parameter for a `name` parameter.
    -   If a name is provided, it should return the string "Hello, [Name]!".
    -   If no name is provided, it should return "Hello, World!".
    -   The function should be named `hello_http`.

2.  **Dependencies**:
    -   Create a `requirements.txt` file.
    -   Add the `functions-framework` library, which is required for local testing, and any other libraries you use (e.g., Flask, though it's often included in the runtime). For this simple case, `functions-framework` is sufficient for local development, and the cloud runtime provides the rest.

3.  **Deployment**:
    -   Deploy the function using the `gcloud functions deploy` command.
    -   **Name**: `my-http-function`
    -   **Runtime**: `python39` (or a later supported version)
    -   **Trigger**: `http`
    -   **Entry Point**: `hello_http`
    -   **Region**: `us-central1`
    -   Allow unauthenticated invocations for easy testing.

4.  **Verification**:
    -   Once deployed, `gcloud` will provide you with an HTTPS trigger URL.
    -   Test the function using `curl` or your browser:
        -   Access the URL directly to see "Hello, World!".
        -   Access the URL with a query parameter like `?name=YourName` to see "Hello, YourName!".
        -   Use `curl` to send a POST request with a JSON payload like `{"name": "YourName"}` to verify it can parse the body.
