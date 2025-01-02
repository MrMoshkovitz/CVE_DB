sudo docker ps -a --filter "name=mongodb" --format "{{.Status}}"
sudo docker ps --filter "name=mongodb" --filter "status=running"



#!/bin/bash

# Set the Google Cloud credentials
export GOOGLE_APPLICATION_CREDENTIALS=~/cve-db-sa.json

# Create directory structure if it doesn't exist and set permissions
sudo mkdir -p ~/Code/CVE_DB/vuln-db-backend/data/db
sudo chown -R $USER:$USER ~/Code/CVE_DB/vuln-db-backend/data/db
sudo chmod -R 755 ~/Code/CVE_DB/vuln-db-backend/data/db




# Check if MongoDB container exists but is not running
# sudo docker ps -a --filter "name=mongodb" --filter "status=exited" | grep mongodb
# sudo docker ps -a --filter "name=mongodb" --filter "status=running" | grep mongodb

if [ -n "$(sudo docker ps -a --filter "name=mongodb" --filter "status=exited" --format '{{.Names}}')" ]; then
    echo "MongoDB container exists but is not running. Starting it..."
    sudo docker start mongodb
fi

# If its not exists, create it
if [ -z "$(sudo docker ps -a --filter "name=mongodb" --format '{{.Names}}')" ]; then
    echo "Creating new MongoDB container..."
    sudo docker pull mongo:latest
    sudo docker run -d --name mongodb \
        -v $(pwd)/data/db:/data/db \
        -p 27017:27017 \
        mongo:latest
fi

# Wait for MongoDB to start
echo "Waiting for MongoDB to start..."
sleep 10


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
    sudo docker exec mongodb mongoimport --jsonArray --db vuln_db --collection cves --drop --file /data/db/enriched-cves-latest.json
    echo "$(date): Updated CVE files and MongoDB database" >> ~/Code/CVE_DB/vuln-db-backend/data/db/update.log
else
    echo "File does not exist. Importing example file"
    sudo docker exec mongodb mongoimport --jsonArray --db vuln_db --collection cves --drop --file /data/db/enriched-cves-example.json
fi
