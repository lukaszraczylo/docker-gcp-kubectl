#!/bin/sh
PATH="$PATH:/srv/google-cloud-sdk/bin"
gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS --project $GCP_PROJECT
gcloud config set project $GCP_PROJECT
gcloud container clusters get-credentials $GCP_CLUSTER --region $GCP_REGION
"$@"