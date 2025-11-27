# Lab Task: Create a Least-Privilege Service Account

## Objective

Your task is to create a service account that has been granted the absolute minimum permissions required to perform its job. In this case, the job is to read objects from a specific Cloud Storage bucket.

## Requirements

1.  **Create a Target Bucket**:
    -   Create a new Cloud Storage bucket that the service account will need to access.

2.  **Create a Custom IAM Role**:
    -   Do not use primitive roles (`owner`, `editor`, `viewer`) or broad predefined roles (`storage.admin`).
    -   Instead, create a **custom IAM role** named `storageObjectReader`.
    -   This role should contain *only* the permissions required to list objects in a bucket and get (read) the objects themselves. These permissions are:
        -   `storage.objects.get`
        -   `storage.objects.list`
    -   Define this role at the project level.

3.  **Create the Service Account**:
    -   Create a new service account named `storage-reader-sa`.

4.  **Bind the Role to the Service Account on the Bucket**:
    -   Do not grant the role at the project level. Instead, apply the principle of least privilege by granting the role only on the specific resource it needs to access (the bucket).
    -   Create an IAM policy binding on the **bucket** that grants your new custom role (`storageObjectReader`) to your new service account (`storage-reader-sa`).

5.  **Verification**:
    -   Create a GCE instance and attach the `storage-reader-sa` service account to it.
    -   SSH into the instance. The `gcloud` and `gsutil` tools will automatically use the attached service account's permissions.
    -   From the instance, run `gsutil ls gs://<your-bucket-name>`. This should succeed.
    -   Try to run `gsutil rm gs://<your-bucket-name>/some-object`. This command should **fail** with a `403 AccessDeniedException`, proving that the service account does not have delete permissions.
    -   Provide the `gcloud` and `gsutil` commands used to create the role, the service account, and the IAM binding.
