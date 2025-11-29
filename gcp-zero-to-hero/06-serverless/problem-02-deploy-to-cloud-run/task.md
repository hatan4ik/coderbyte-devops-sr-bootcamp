# Problem 2: Deploy a Container to Cloud Run

## Objective

Your task is to deploy a pre-built container image to Google Cloud Run and make it publicly accessible.

## Requirements

1.  **Service Name**: `my-first-cloud-run-app`
2.  **Container Image**: Use the public sample image `gcr.io/google-samples/hello-app:1.0`. This is a simple web server that says "Hello, world!".
3.  **Region**: Deploy the service to a region of your choice (e.g., `us-east1`).
4.  **Authentication**: Allow unauthenticated (public) access to the service.
5.  **Deployment Method**: Use the `gcloud` command-line tool.

## Verification

1.  Use the `gcloud run deploy` command to deploy your service.
2.  After the command completes, it will print the URL for your new service.
3.  Open this URL in your web browser. You should see the "Hello, world!" message from the application.
4.  You can also check the status of your service in the GCP Console under "Cloud Run".

## Challenge

Deploy a different version of the application, `gcr.io/google-samples/hello-app:2.0`. Notice that Cloud Run creates a new "revision" for this deployment. Explore the "Revisions" tab in the Cloud Run UI and try splitting traffic between the two revisions. For example, send 90% of traffic to the new revision and 10% to the old one.
