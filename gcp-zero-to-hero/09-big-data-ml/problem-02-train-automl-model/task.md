# Lab Task (Conceptual): Train an AutoML Model

## Objective

This is a conceptual lab that outlines the process for training a custom image classification model using Vertex AI AutoML. Due to the time and resources required for training, you are not expected to run this live unless you choose to. The goal is to understand the workflow.

## Scenario

You are a retail company and you want to build a model that can automatically classify images of clothing into three categories: "shirts", "pants", and "shoes".

## High-Level Steps

1.  **Prepare and Upload Data**:
    -   **Collect Images**: Gather at least 10-20 images for each category (label).
    -   **Structure for Import**: Create a CSV file that lists the Cloud Storage URI of each image and its corresponding label. For example:
        ```csv
        gs://<your-bucket>/images/shirt1.jpg,shirt
        gs://<your-bucket>/images/pant1.jpg,pant
        gs://<your-bucket>/images/shoe1.jpg,shoe
        ```
    -   **Upload to Cloud Storage**: Upload your images and the CSV file to a Cloud Storage bucket.

2.  **Create a Vertex AI Dataset**:
    -   Navigate to the Vertex AI section of the GCP Console.
    -   Create a new **Dataset**.
    -   Choose "Image" as the data type and "Image Classification (Single-label)" as the objective.
    -   Import your data by pointing Vertex AI to the CSV file you created in Cloud Storage.
    -   The import process can take some time as Vertex AI processes the images.

3.  **Train the Model**:
    -   Once the dataset is ready, click "Train New Model".
    -   Choose "AutoML" as the training method.
    -   Review the labels and data splits (Train, Validation, Test). Vertex AI creates a default split.
    -   Define a compute budget. For AutoML, this is specified in "node hours". A budget of 1-2 node hours is often sufficient for simple models.
    -   Start the training job.

4.  **Evaluate and Deploy**:
    -   Training can take several hours. Once complete, Vertex AI provides an evaluation page showing the model's precision, recall, and other metrics.
    -   If you are satisfied with the model's performance, you can deploy it to an **Endpoint**.
    -   Deploying the model makes it available to serve online predictions via a REST API.

5.  **Verification**:
    -   Understand the key stages: Data Preparation, Dataset Creation, Model Training, and Deployment.
    -   Be able to describe the role of the CSV index file and why a Cloud Storage bucket is necessary.
    -   Explain what "node hours" represents in the context of an AutoML training budget.
