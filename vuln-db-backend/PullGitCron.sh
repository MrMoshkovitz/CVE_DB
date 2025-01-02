#* This file is a linux cronjob to pull git repo from github and run the script
#? MrMoshkovitz/CVE_DB

#* 1. Authenticate to github
#* 1.1 Generate a new ssh key to the ~/.ssh/MrMoshkovitz/CVE_DB
mkdir ~/.ssh/MrMoshkovitz
ssh-keygen -t ed25519 -C "gal.moshko@gmail.com" -f ~/.ssh/MrMoshkovitz/CVE_DB
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/MrMoshkovitz/CVE_DB
cat ~/.ssh/MrMoshkovitz/CVE_DB.pub

#* 1.2 Add the ssh key to the github repo


# 2. Pull the git repo from github
# 3. Run the script

# The script is a python script that will pull the latest enriched-cves-example.json file from the S3 bucket and import it into the mongodb database

# The script is located in the vuln-db-backend directory


#!/bin/bash

# Authenticate with GCP
gcloud auth activate-service-account --key-file=/path/to/service-account-key.json
gcloud config set project your-gcp-project-id

# Create a directory for the JSON file
mkdir -p /data

# Set up cron job to download the JSON file daily at midnight
(crontab -l 2>/dev/null; echo "0 0 * * * gsutil cp gs://cve-storage-bucket/enriched-cves-example.json /data/enriched-cves-example.json") | crontab -
