# Problem 1: Set up a CI/CD Pipeline with Cloud Build

## Objective

Your task is to create a simple CI/CD pipeline using Cloud Build that automatically builds a Docker image and pushes it to Google Container Registry (GCR) whenever you push a change to a Cloud Source Repository.

## Requirements

1.  **Source Code**: Create a new Cloud Source Repository named `my-ci-app`.
2.  **Application**: In this repository, create a simple `app.py` (a basic Flask app) and a `Dockerfile`.
    -   `app.py`:
        ```python
        from flask import Flask
        import os

        app = Flask(__name__)

        @app.route('/')
        def hello():
            return "Hello from my CI/CD pipeline!"

        if __name__ == "__main__":
            app.run(debug=True, host='0.0.0.0', port=int(os.environ.get('PORT', 8080)))
        ```
    -   `Dockerfile`:
        ```dockerfile
        FROM python:3.9-slim
        WORKDIR /app
        COPY . .
        RUN pip install Flask
        CMD ["python", "app.py"]
        ```
3.  **Cloud Build Trigger**: Create a Cloud Build trigger that starts a build when you push to the `main` branch of your `my-ci-app` repository.
4.  **Build Configuration**: The build should use a `cloudbuild.yaml` file in your repository. This file should contain two steps:
    -   Build the Docker image.
    -   Push the Docker image to GCR with a tag that includes the short commit SHA (e.g., `gcr.io/your-project-id/my-ci-app:$SHORT_SHA`).

## Verification

1.  Push your `app.py`, `Dockerfile`, and `cloudbuild.yaml` to the `main` branch of your Cloud Source Repository.
2.  Go to the Cloud Build history in the GCP Console to see your build trigger and execute.
3.  Verify that the build completes successfully.
4.  Go to the Container Registry in the GCP Console and verify that your new image has been pushed with the correct tag.

## Challenge

Add a third step to your `cloudbuild.yaml` that deploys the new image to a Cloud Run service. You will need to grant the Cloud Build service account the necessary permissions to deploy to Cloud Run.
