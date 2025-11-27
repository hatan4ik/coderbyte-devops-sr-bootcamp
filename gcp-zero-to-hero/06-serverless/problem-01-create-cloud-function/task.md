# Problem 1: Create an HTTP Cloud Function

## Objective

Your task is to create, deploy, and test a simple HTTP-triggered Cloud Function.

## Requirements

1.  **Function Name**: `my-first-function`
2.  **Runtime**: Use Python 3.9.
3.  **Trigger**: The function must be triggered by an HTTP request.
4.  **Authentication**: Allow unauthenticated invocations for easy testing.
5.  **Function Logic**: The function should accept a JSON payload with a `name` key (e.g., `{"name": "Gemini"}`) and return the string "Hello, [name]!". If no name is provided, it should default to "Hello, World!".
6.  **Deployment Method**: Use the `gcloud` command-line tool to deploy your function from your local machine.

## Steps

1.  Create a local directory for your function (e.g., `my-function`).
2.  Inside this directory, create a `main.py` file with your function code.
3.  Create a `requirements.txt` file (it can be empty for this simple case).
4.  From inside your function directory, run the `gcloud functions deploy` command. You will need to specify the function name, runtime, trigger type, and other options. Use `gcloud functions deploy --help` to see the available flags.

## Verification

1.  After deployment is complete, the `gcloud` command will output the HTTPS trigger URL.
2.  Visit the URL in your browser. You should see "Hello, World!".
3.  Use a tool like `curl` to test the JSON payload functionality:
    ```bash
    curl -X POST -H "Content-Type: application/json" -d '{"name": "GCP"}' <YOUR_TRIGGER_URL>
    ```
    This should return "Hello, GCP!".

## Challenge

Modify your function to also accept the `name` as a URL query parameter (e.g., `<YOUR_TRIGGER_URL>?name=Cloud`).
