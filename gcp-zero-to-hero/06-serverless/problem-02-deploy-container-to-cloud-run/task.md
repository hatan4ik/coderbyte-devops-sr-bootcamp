# Lab Task: Deploy a Container to Cloud Run

## Objective

Your task is to containerize a simple web application using Docker, push the image to Google Artifact Registry, and deploy it as a serverless service on Cloud Run.

## Requirements

1.  **Application Code**:
    -   Create a directory for your application.
    -   Write a simple Python web application using Flask.
    -   The application should have one route (`/`) that returns "Hello from Cloud Run!".
    -   The application must listen on the host and port specified by the `HOST` and `PORT` environment variables, which are injected by Cloud Run. It should default to `0.0.0.0` and `8080` if they are not set.

2.  **Containerization**:
    -   Create a `Dockerfile` for your application.
    -   The Dockerfile should:
        -   Start from a slim Python base image (e.g., `python:3.9-slim`).
        -   Set a working directory.
        -   Copy the application code and `requirements.txt` into the image.
        -   Install the Python dependencies.
        -   Specify the command to run the application (e.g., using `gunicorn` or `python`).

3.  **Build and Push the Image**:
    -   First, create an Artifact Registry repository to store your image.
    -   Configure Docker to authenticate with Artifact Registry.
    -   Build your Docker image. Tag it with the full Artifact Registry path (e.g., `<region>-docker.pkg.dev/<project-id>/<repo-name>/<image-name>:<tag>`).
    -   Push the image to Artifact Registry.

4.  **Deploy to Cloud Run**:
    -   Deploy the image to Cloud Run using the `gcloud run deploy` command.
    -   **Service Name**: `hello-cloud-run`
    -   **Region**: `us-central1`
    -   Allow unauthenticated invocations.

5.  **Verification**:
    -   `gcloud` will provide a URL for your service.
    -   Verify you can access the URL and see the "Hello from Cloud Run!" message.
