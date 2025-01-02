#!/bin/bash

# Set the Google Cloud credentials
export GOOGLE_APPLICATION_CREDENTIALS=~/cve-db-sa.json

# Ensure correct permissions
sudo chown -R $USER:$USER ~/code/CVE_DB/vuln-db-backend/data > /dev/null 2>&1

# Get and copy the latest file
LATEST_FILE=$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | head -n1)
gsutil -q cp $LATEST_FILE ~/code/CVE_DB/vuln-db-backend/data/enriched-cves-latest.json

# Get and copy the first (oldest) file
FIRST_FILE=$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | tail -n1)
gsutil -q cp $FIRST_FILE ~/code/CVE_DB/vuln-db-backend/data/enriched-cves-first.json

# Log the execution (only if you want to keep track of when it runs)
echo "$(date): Updated CVE files" >> ~/code/CVE_DB/vuln-db-backend/data/update.log 2>/dev/null 