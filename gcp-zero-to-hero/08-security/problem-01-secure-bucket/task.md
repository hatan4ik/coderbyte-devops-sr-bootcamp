# Problem 1: Secure a Cloud Storage Bucket

## Objective

Your task is to create a Cloud Storage bucket and configure its permissions according to the principle of least privilege.

## Scenario

You have a team with two members:
1.  A data analyst who needs to read files from the bucket.
2.  An application service account that needs to write files to the bucket.

Public access should be completely disabled.

## Requirements

1.  **Create a Bucket**: Create a new Cloud Storage bucket with a unique name.
2.  **Block Public Access**: Ensure that "Public access prevention" is enabled for this bucket. This is the default for new buckets, but you should verify it.
3.  **Create a Service Account**: Create a new service account for your application (e.g., `my-storage-writer-sa`).
4.  **Configure Permissions**:
    -   Grant your personal user account (the one you are logged in with) the `Storage Object Viewer` role (`roles/storage.objectViewer`) on the bucket. This allows you to view/read objects.
    -   Grant the new service account the `Storage Object Creator` role (`roles/storage.objectCreator`) on the bucket. This allows it to write new objects but not view or delete existing ones.

## Verification

1.  Upload a file to the bucket using the GCP Console or `gsutil cp`.
2.  As your user, verify that you can view the object's contents.
3.  Try to delete the object as your user. This should fail (unless you are a project owner/editor).
4.  (Challenge) Write a small script that uses the service account's credentials to try and upload a file to the bucket. This should succeed. Then, try to list the bucket's contents using the same credentials. This should fail.

## Using gsutil to set permissions

You can use the `gsutil iam ch` command to apply IAM policies to buckets.

-   Granting viewer access to a user:
    ```bash
    gsutil iam ch user:your-email@example.com:objectViewer gs://your-bucket-name
    ```
-   Granting creator access to a service account:
    ```bash
    gsutil iam ch serviceAccount:your-sa-email@your-project.iam.gserviceaccount.com:objectCreator gs://your-bucket-name
    ```
