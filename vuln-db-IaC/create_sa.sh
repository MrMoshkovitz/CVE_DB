#!/bin/bash

source .env
# Create the service account
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME \
  --description="Service account for CVE DB access" \
  --display-name="CVE DB Service Account" \
  --project=$PROJECT_ID

# Assign the Storage Admin role to the service account
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Create a directory for the key file
mkdir -p $(dirname $KEY_FILE_PATH)

# Generate and download the service account key file
gcloud iam service-accounts keys create $KEY_FILE_PATH \
  --iam-account="${SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Service account created and key file downloaded to $KEY_FILE_PATH"


gcloud compute scp /Users/galmoshkovitz/.keys/cve-db-sa.json cve-vm:/home/gal_moshko/cve-db-sa.json --zone=us-central1-a
