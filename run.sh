#!/bin/sh
/srv/google-cloud-sdk/bin/gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS --project $GCP_PROJECT
/srv/google-cloud-sdk/bin/gcloud config set project $GCP_PROJECT
/srv/google-cloud-sdk/bin/gcloud container clusters get-credentials $GCP_CLUSTER --region $GCP_REGION
kubectl "$@"