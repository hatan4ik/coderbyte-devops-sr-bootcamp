# This script demonstrates how to create a Vertex AI Dataset using the Python SDK.
# It corresponds to Step 2 in the conceptual lab.

from google.cloud import aiplatform

# --- Configuration ---
PROJECT_ID = "gcp-hero-lab-01"  # Change to your project ID
REGION = "us-central1"
DATASET_DISPLAY_NAME = "clothing-images-dataset"
# The GCS URI of the CSV file that maps images to labels.
# Example: "gs://your-bucket-name/data.csv"
GCS_SOURCE_URI = "gs://your-bucket-for-training-data/image-labels.csv"

def create_image_dataset(
    project: str,
    location: str,
    display_name: str,
    gcs_source: str
):
    """
    Creates a new image dataset in Vertex AI.
    """
    # Initialize the Vertex AI SDK
    aiplatform.init(project=project, location=location)

    # Create the dataset
    # This is an asynchronous operation.
    dataset = aiplatform.ImageDataset.create(
        display_name=display_name,
        gcs_source=gcs_source,
        import_schema_uri=aiplatform.schema.dataset.ioformat.image.single_label_classification,
        sync=False # Make it an async call
    )

    print(f"Dataset creation initiated for: {dataset.resource_name}")
    print("This may take several minutes.")

    # You can wait for the dataset to be created
    # dataset.wait()

    print(f"Dataset display name: {dataset.display_name}")
    print(f"Dataset resource name: {dataset.resource_name}")
    return dataset

if __name__ == "__main__":
    print("This script demonstrates creating a Vertex AI dataset.")
    print(f"Make sure to replace the GCS_SOURCE_URI ('{GCS_SOURCE_URI}') with the actual path to your CSV file.")

    # Example of how to call the function
    # create_image_dataset(
    #     project=PROJECT_ID,
    #     location=REGION,
    #     display_name=DATASET_DISPLAY_NAME,
    #     gcs_source=GCS_SOURCE_URI,
    # )
