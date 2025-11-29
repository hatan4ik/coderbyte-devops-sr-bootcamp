# Lab Task: Provision a Cloud SQL Instance with Terraform

## Objective

Provision a managed PostgreSQL database instance using Terraform. This lab demonstrates how to manage stateful infrastructure with IaC.

## Requirements

1.  **Terraform Configuration (`main.tf`)**:
    -   Configure the Google Provider.
    -   Define a `google_sql_database_instance` resource.
    -   Define a `google_sql_database` resource to create a database within the instance.
    -   Define a `google_sql_user` resource to create a user.

2.  **Cloud SQL Instance Configuration**:
    -   **Name**: `postgres-main-instance`
    -   **Database Version**: `POSTGRES_13`
    -   **Region**: `us-central1`
    -   **Tier**: `db-g1-small` (a small, cost-effective instance type).
    -   **Deletion Protection**: Set to `false` for this lab so you can easily destroy it. In production, this should be `true`.

3.  **Database and User Configuration**:
    -   Create a database named `app-db`.
    -   Create a user named `app-user`.
    -   Generate a random password for the user using the `random_password` resource from the `random` provider. **Do not hardcode the password.**

4.  **Outputs**:
    -   Output the instance's `connection_name`. This is needed for connecting with the Cloud SQL Auth Proxy.
    -   Output the generated password for the database user. Mark this output as `sensitive`.

5.  **Execution**:
    -   Run `terraform init`, `plan`, and `apply`.
    -   Verify the instance is created in the GCP Console.
    -   (Optional) Try to connect to the database using the `psql` client and the Cloud SQL Auth Proxy.
    -   Run `terraform destroy` to clean up all resources.
