# Problem 2: Train a No-Code Image Classification Model with AutoML

## Objective

Your goal is to use Vertex AI AutoML to train a machine learning model that can classify images of clouds, without writing any code.

## Scenario

You are a meteorologist who wants to automatically classify photos of clouds as either "cumulus," "cumulonimbus," or "cirrus."

## Requirements

1.  **Dataset**:
    -   Google provides a public dataset of cloud images perfect for this task. The dataset is located at `gs://cloud-samples-data/ai-platform/hosted/image/clouds/`.
    -   Create a new **Dataset** in the Vertex AI section of the GCP Console.
    -   Choose "Image" as the data type and "Image classification (Single-label)" as the objective.
    -   When prompted for the data source, choose "Import from Google Cloud Storage" and point it to the path above.

2.  **Training**:
    -   After the dataset has been imported (this may take a few minutes), you will see the images and their labels.
    -   Click "Train New Model".
    -   Choose "AutoML" as the training method.
    -   Give your model a name, like `cloud_classifier`.
    -   For this exercise, you can use the default training budget (e.g., 8 node hours).

3.  **Evaluation**:
    -   Training will take some time (potentially an hour or more). You can leave the page and come back.
    -   Once training is complete, explore the "Evaluate" tab for your model. Look at the confusion matrix, precision, and recall scores. This tells you how well your model performs.

4.  **Deployment**:
    -   To use the model, you need to deploy it to an **Endpoint**.
    -   Go to the "Deploy & Test" tab and click "Deploy to endpoint".
    -   Create a new endpoint, give it a name, and accept the default settings.
    -   Deployment will also take several minutes.

## Verification

1.  Once the model is deployed to an endpoint, you can test it directly in the UI.
2.  Find an image of a cloud on the internet (e.g., search for "cumulus cloud").
3.  In the "Deploy & Test" tab, upload the image.
4.  Your model will predict the cloud type and give you a confidence score. Verify that the prediction is correct.

## Challenge

The sample dataset is quite small. Can you find more images of different cloud types and add them to your dataset? You can upload them from your local computer. Retrain the model with your new data and see if the performance improves.