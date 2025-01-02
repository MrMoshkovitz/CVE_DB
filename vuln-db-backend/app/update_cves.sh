#!/bin/bash

# Set the Google Cloud credentials
export GOOGLE_APPLICATION_CREDENTIALS=~/cve-db-sa.json

# Ensure correct permissions
sudo chown -R $USER:$USER ~/code/CVE_DB/vuln-db-backend/data

# Get and copy the latest file
LATEST_FILE=$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | head -n1)
gsutil cp $LATEST_FILE ~/code/CVE_DB/vuln-db-backend/data/enriched-cves-latest.json

# Get and copy the first (oldest) file
FIRST_FILE=$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | tail -n1)
gsutil cp $FIRST_FILE ~/code/CVE_DB/vuln-db-backend/data/enriched-cves-first.json

# Log the execution
echo "$(date): Updated CVE files" >> ~/code/CVE_DB/vuln-db-backend/data/update.log 