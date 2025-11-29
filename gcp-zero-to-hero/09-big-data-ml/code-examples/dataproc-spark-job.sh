#!/bin/bash

PROJECT_ID="your-gcp-project-id"
REGION="us-central1"
CLUSTER_NAME="my-dataproc-cluster"

# Create a Dataproc cluster (this can take a few minutes)
gcloud dataproc clusters create $CLUSTER_NAME \
    --region=$REGION \
    --project=$PROJECT_ID

# Submit a sample Spark job
gcloud dataproc jobs submit spark \
    --cluster=$CLUSTER_NAME \
    --region=$REGION \
    --project=$PROJECT_ID \
    --class=org.apache.spark.examples.SparkPi \
    --jars=file:///usr/lib/spark/examples/jars/spark-examples.jar \
    -- 1000

# Delete the cluster after the job is done
gcloud dataproc clusters delete $CLUSTER_NAME \
    --region=$REGION \
    --project=$PROJECT_ID \
    --quiet
