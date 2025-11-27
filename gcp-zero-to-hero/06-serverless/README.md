# Module 6: GCP Serverless

This module introduces GCP's powerful serverless computing platforms, which allow you to run code and containers without managing the underlying servers. We will focus on **Cloud Functions** for event-driven code and **Cloud Run** for serverless containers.

## Key Topics

### Cloud Functions
1.  **Event-Driven Computing**: Understanding the concept of functions as a service (FaaS).
2.  **Triggers**: Creating functions that respond to various event sources, such as HTTP requests, Pub/Sub messages, or Cloud Storage object changes.
3.  **Runtimes**: Writing functions in various supported languages like Python, Node.js, and Go.
4.  **Security**: Securing functions using IAM and invocation policies.

### Cloud Run
1.  **Serverless Containers**: Deploying and scaling containerized applications automatically.
2.  **Container Workflow**: The process of building a container image, pushing it to Artifact Registry, and deploying it to Cloud Run.
3.  **Revisions**: Managing different versions of your service and splitting traffic between them.
4.  **Autoscaling**: How Cloud Run scales from zero to N instances based on incoming requests.

## Labs

- **Problem 1**: Write and deploy a simple HTTP-triggered Cloud Function using Python.
- **Problem 2**: Build a container image for a simple web application, push it to Artifact Registry, and deploy it as a public service on Cloud Run.
