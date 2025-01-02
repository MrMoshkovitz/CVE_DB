#!/bin/bash

# Set the Google Cloud credentials
export GOOGLE_APPLICATION_CREDENTIALS=~/cve-db-sa.json

# Create directory structure if it doesn't exist
mkdir -p ~/Code/CVE_DB/vuln-db-backend/data/db

# Ensure correct permissions
sudo chown -R $USER:$USER ~/Code/CVE_DB/vuln-db-backend/data/db > /dev/null 2>&1

# Check if MongoDB container is running
if ! docker ps | grep -q mongodb; then
    echo "$(date): Error - MongoDB container is not running" >> ~/Code/CVE_DB/vuln-db-backend/data/db/update.log 2>/dev/null
    echo "Starting MongoDB container..."
    docker start mongodb
    sleep 10
    if ! docker ps | grep -q mongodb; then
        echo "Error - MongoDB container is not running" >> ~/Code/CVE_DB/vuln-db-backend/data/db/update.log 2>/dev/null
        docker pull mongo:latest
        docker run -d --name mongodb -v $(pwd)/data/db:/data/db -p 27017:27017 mongo:latest
        exit 1
    fi
fi

# Get and copy the latest file
LATEST_FILE=$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | head -n1)
gsutil -q cp $LATEST_FILE ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json

# Get and copy the first (oldest) file
FIRST_FILE=$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | tail -n1)
gsutil -q cp $FIRST_FILE ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-first.json


# Check if the file exists
if [ -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json ]; then
    echo "File exists"
    # Update MongoDB with the latest CVEs
    docker exec mongodb mongoimport --jsonArray --db vuln_db --collection cves --drop --file /data/db/enriched-cves-latest.json

    # Log the execution
    echo "$(date): Updated CVE files and MongoDB database" >> ~/Code/CVE_DB/vuln-db-backend/data/db/update.log 2>/dev/null 
else
    echo "File does not exist Importing example file"
    docker exec mongodb mongoimport --jsonArray --db vuln_db --collection cves --drop --file /data/db/enriched-cves-example.json
fi
