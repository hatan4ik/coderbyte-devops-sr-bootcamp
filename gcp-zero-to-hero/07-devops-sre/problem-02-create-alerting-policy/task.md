# Problem 2: Create a Monitoring Alerting Policy

## Objective

Your goal is to create an alerting policy in Cloud Monitoring that notifies you if a Cloud Run service has a high rate of server errors (5xx responses).

## Prerequisites

- You should have a Cloud Run service deployed (you can use one from a previous module).
- You should generate some traffic to the service, including some errors if possible, so that the metric data is available in Cloud Monitoring. A simple way to generate 5xx errors is to deploy a faulty application.

## Requirements

1.  **Metric**: The alerting policy should monitor the `request_count` metric for Cloud Run revisions (`run.googleapis.com/request_count`).
2.  **Filter**: The filter should specifically look for responses where the `response_code_class` is `5xx` (server errors).
3.  **Condition**: The condition should trigger if the sum of 5xx errors is **above 5** for any 5-minute alignment period. The condition should be named something descriptive like "Too many server errors".
4.  **Notification Channel**: Create a new email notification channel with your own email address.
5.  **Alerting Policy**: Create a new alerting policy that uses the condition and notification channel you just created. Name the policy "Cloud Run Server Error Rate".

## Verification

1.  To test the alert, you need to generate 5xx errors from your service. You could, for example, deploy a broken version of an application to Cloud Run that always crashes.
2.  After generating errors for a few minutes, you should receive an email notification from Google Cloud that your alert has been triggered.
3.  You can also see the "incident" in the Cloud Monitoring "Alerting" section of the GCP Console.
4.  Once you stop the error generation (e.g., by deploying a working version of the app), the incident should automatically resolve after a few minutes, and you should receive a follow-up email.

## Challenge

Create a more advanced alert that triggers based on the *ratio* of 5xx errors to total requests, rather than an absolute number. For example, "trigger if more than 10% of requests in the last 10 minutes are 5xx errors". This requires using the Monitoring Query Language (MQL).