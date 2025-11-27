# Module 7: DevOps and Site Reliability Engineering (SRE)

Welcome to Module 7. In this section, we'll explore GCP tools and practices related to DevOps and SRE. This includes Continuous Integration/Continuous Deployment (CI/CD), monitoring, logging, and tracing.

## Learning Objectives

- Understand key DevOps and SRE principles.
- Create a CI/CD pipeline using Google Cloud Build.
- Understand and use Google Cloud's operations suite (formerly Stackdriver):
  - **Cloud Monitoring**: for metrics and dashboards.
  - **Cloud Logging**: for centralized log management.
  - **Cloud Trace**: for distributed tracing.
- Create alerting policies based on application metrics.

## CI/CD with Cloud Build

**Cloud Build** is a fully-managed CI/CD platform that lets you build, test, and deploy software quickly, at scale. You can write a build configuration file to define your pipeline steps.

## Cloud's Operations Suite

Google Cloud's operations suite provides integrated monitoring, logging, and trace managed services for applications and systems running on Google Cloud and beyond.

- **Cloud Monitoring** collects metrics, events, and metadata from Google Cloud services, hosted uptime probes, application instrumentation, and a variety of common application components.
- **Cloud Logging** allows you to store, search, analyze, monitor, and alert on log data and events from Google Cloud and Amazon Web Services.
- **Cloud Trace** is a distributed tracing system that collects latency data from your applications and displays it in the Google Cloud Console.

## Module Structure

- **Code Examples**: A sample `cloudbuild.yaml` for a CI pipeline and a JSON definition for a Cloud Monitoring dashboard.
- **Problem 1: Setup a CI/CD Pipeline**: A lab to build a simple CI/CD pipeline for a web application using Cloud Build.
- **Problem 2: Create an Alerting Policy**: A practical exercise to set up a monitoring alert for a Cloud Run service.