# Lab Task: Create a CI Pipeline with Cloud Build

## Objective

Your task is to create a CI pipeline using Cloud Build that automatically triggers on a push to a Cloud Source Repository, builds a Docker image, and pushes it to Artifact Registry.

## Prerequisites

-   A Git repository hosted on **Cloud Source Repositories**.
-   An **Artifact Registry** Docker repository to store the image.
-   A simple application with a `Dockerfile` (you can use the app from the Cloud Run lab).

## Requirements

1.  **`cloudbuild.yaml` Configuration**:
    -   Create a `cloudbuild.yaml` file in the root of your source code repository.
    -   The build file must contain at least two steps:
        1.  **Build the Docker image**: Use the `gcr.io/cloud-builders/docker` builder to run the `docker build` command.
        2.  **Push the Docker image**: Use the same builder to run the `docker push` command to your Artifact Registry repository.
    -   Use substitutions for variables like `_REGION`, `_REPO_NAME`, `_IMAGE_NAME`, and `_TAG` to make the build config reusable.

2.  **Cloud Build Trigger**:
    -   Create a new Cloud Build trigger.
    -   The trigger should be configured to start a build when a commit is pushed to the `main` branch of your Cloud Source Repository.
    -   The trigger should use the `cloudbuild.yaml` file from the repository as its build definition.

3.  **IAM Permissions**:
    -   Ensure the Cloud Build service account (`[PROJECT_NUMBER]@cloudbuild.gserviceaccount.com`) has the necessary IAM roles to push images to Artifact Registry. (The `Artifact Registry Writer` role is appropriate). It usually has sufficient permissions by default but it's good practice to verify.

4.  **Execution**:
    -   Push your application code, including the `Dockerfile` and `cloudbuild.yaml`, to the `main` branch of your Cloud Source Repository.
    -   Go to the Cloud Build history page in the GCP Console to monitor the build.
    -   Verify that the build completes successfully and that the new container image appears in your Artifact Registry repository.
