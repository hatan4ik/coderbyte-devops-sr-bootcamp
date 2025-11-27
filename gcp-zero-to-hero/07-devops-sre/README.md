# Module 7: GCP DevOps & SRE

This module covers tools and practices for implementing DevOps and Site Reliability Engineering (SRE) on GCP. We will focus on **Cloud Build** for CI/CD, **Artifact Registry** for storing artifacts, and the **Cloud Operations** suite (formerly Stackdriver) for monitoring and logging.

## Key Topics

### CI/CD
1.  **Cloud Build**: A fully-managed CI/CD platform that lets you build, test, and deploy from source code. We will cover `cloudbuild.yaml` configuration and triggers.
2.  **Artifact Registry**: A single place to manage container images and language packages (like Maven and npm). It is the recommended successor to Container Registry.
3.  **Deployment Strategies**: An overview of blue/green, canary, and rolling deployments in the context of GCP services.

### SRE & Operations
1.  **Cloud Monitoring**: Collecting metrics, creating dashboards, and setting up alerting policies for your GCP resources and applications.
2.  **Cloud Logging**: Centralized log management, searching, and analysis. We will cover log-based metrics.
3.  **Application Performance Management (APM)**: An overview of Cloud Trace and Cloud Profiler for debugging and performance analysis.

## Labs

- **Problem 1**: Create a CI pipeline using Cloud Build that automatically builds a container image from a source repository and pushes it to Artifact Registry.
- **Problem 2**: Create an alerting policy in Cloud Monitoring that notifies you if a GCE instance's CPU utilization exceeds a certain threshold.
