# Lab Task: Create a Monitoring Alerting Policy

## Objective

Your task is to create an alerting policy in Google Cloud Monitoring that will notify a user if the CPU utilization of a Compute Engine VM exceeds a specified threshold for a sustained period.

## Prerequisites

-   A running GCE virtual machine. You can use one from a previous lab or create a new one.

## Requirements

1.  **Alerting Policy Configuration**:
    -   Create a new alerting policy using the GCP Console or the `gcloud` CLI.
    -   **Condition**: The policy should trigger based on a metric.
        -   **Metric**: `CPU utilization` (`compute.googleapis.com/instance/cpu/utilization`).
        -   **Target**: The policy should apply to a specific GCE VM instance.
        -   **Configuration**:
            -   The condition should trigger if `any time series violates` the threshold.
            -   **Threshold**: `80%` (or `0.8` as a decimal).
            -   **Duration**: `5 minutes`. The CPU utilization must be above the threshold for 5 minutes before the alert fires.

2.  **Notification Channel**:
    -   Create a notification channel to receive the alert.
    -   For this lab, an `Email` channel is sufficient. Add your own email address as a recipient.

3.  **Documentation**:
    -   Add a documentation message to the alert.
    -   The message should provide clear instructions for a first responder, for example:
        ```
        CPU utilization on instance ${metric.label.instance_name} has exceeded 80% for 5 minutes.

        **Next Steps:**
        1. SSH into the instance to investigate the running processes.
        2. Check the application logs for errors.
        3. Consider restarting the application process if it is unresponsive.
        ```

4.  **Verification**:
    -   (Optional but Recommended) To test the alert, you can install a stress testing tool on your VM (like `stress-ng`) and run a command to intentionally spike the CPU (e.g., `stress-ng --cpu 1 --timeout 10m`).
    -   Wait for the alert to fire and verify that you receive an email notification.
    -   Provide the `gcloud` command to list your alerting policies to verify its creation.
