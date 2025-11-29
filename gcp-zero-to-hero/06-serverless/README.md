# Module 6: Serverless Computing

Welcome to Module 6. This section focuses on GCP's serverless offerings, allowing you to run code without provisioning or managing servers. We will explore Cloud Functions for event-driven code and Cloud Run for serving containerized applications.

## Learning Objectives

- Understand the principles of serverless computing.
- Create and deploy event-driven functions using Google Cloud Functions.
- Deploy and manage stateless containers with Google Cloud Run.
- Differentiate between Cloud Functions, Cloud Run, and App Engine.
- Configure triggers for Cloud Functions.

## What is Serverless?

Serverless computing is a cloud execution model where the cloud provider dynamically manages the allocation and provisioning of servers. You write the code, and the cloud provider handles the rest. This model is great for microservices, event-driven architectures, and mobile backends.

## Google Cloud Functions

**Google Cloud Functions** is a lightweight, event-based, asynchronous compute solution that allows you to create small, single-purpose functions that respond to cloud events without the need to manage a server or a runtime environment.

## Google Cloud Run

**Google Cloud Run** is a managed compute platform that enables you to run stateless containers that are invocable via web requests or Pub/Sub events. Cloud Run is serverless: it abstracts away all infrastructure management, so you can focus on what matters most — building great applications.

## Module Structure

- **Code Examples**: Examples of a Python Cloud Function, a Terraform-managed function, and a deployment script for Cloud Run.
- **Problem 1: Create a Cloud Function**: A hands-on lab to create a simple HTTP-triggered Cloud Function.
- **Problem 2: Deploy a Service to Cloud Run**: A practical exercise to deploy a containerized application to Cloud Run.