# Lab Task: Manage a Cloud Storage Bucket with gsutil

## Objective

Your task is to create a Cloud Storage bucket, manage objects within it, and configure a lifecycle policy to automatically manage old object versions. This lab will make heavy use of the `gsutil` CLI tool.

## Requirements

1.  **Create a Bucket**:
    -   Create a new Cloud Storage bucket. The name must be **globally unique**. A good practice is to name it `<your-project-id>-data`.
    -   Choose the `us-central1` region and the `Standard` storage class.

2.  **Manage Objects**:
    -   Create a sample text file named `sample.txt` with some content.
    -   Upload `sample.txt` to your bucket.
    -   Create a second version of `sample.txt` with different content and upload it again to the same object name.
    -   Enable versioning on your bucket to keep both versions.
    -   List the versions of `sample.txt` in the bucket to verify that both exist.

3.  **Configure Lifecycle Management**:
    -   Create a `lifecycle.json` file.
    -   Define a lifecycle rule that does the following:
        -   The rule should apply to all objects in the bucket.
        -   The action is to `Delete` objects.
        -   The condition is that the object is non-current (i.e., it's an old version) AND it is more than 30 days old (`age` condition). A second condition should be that you only keep a maximum of 3 non-current versions (`numNewerVersions`).
    -   Apply this lifecycle configuration to your bucket.

4.  **Verification**:
    -   Provide the `gsutil` commands you used for:
        -   Creating the bucket.
        -   Enabling versioning.
        -   Uploading the file.
        -   Listing object versions.
        -   Applying the lifecycle policy.
