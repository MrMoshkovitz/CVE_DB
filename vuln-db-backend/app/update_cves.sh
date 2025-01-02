# sudo docker ps -a --filter "name=mongodb" --format "{{.Status}}"
# sudo docker ps --filter "name=mongodb" --filter "status=running"



#!/bin/bash

# Set the Google Cloud credentials
export GOOGLE_APPLICATION_CREDENTIALS=~/cve-db-sa.json

# Create directory structure if it doesn't exist and set permissions
sudo mkdir -p ~/Code/CVE_DB/vuln-db-backend/data/db
sudo chown -R $USER:$USER ~/Code/CVE_DB/vuln-db-backend/data/db
sudo chmod -R 755 ~/Code/CVE_DB/vuln-db-backend/data/db


# Handle MongoDB container - if it doesn't exist, create it, if it exists but is not running, start it, if it exists and is running, do nothing
#* Check if MongoDB container exists 
echo -e "\e[1;34mChecking if MongoDB container exists...\e[0m"
if [ -n "$(sudo docker ps -a --filter "name=mongodb" --format '{{.Names}}')" ]; then
    echo -e "\e[1;32mSuccess: MongoDB container exists\e[0m"
    
    #* Check if MongoDB container is running
    echo -e "\e[1;34mChecking if MongoDB container is running...\e[0m"
    if [ -n "$(sudo docker ps --filter "name=mongodb" --filter "status=running" --format '{{.Names}}')" ]; then
        echo -e "\e[1;32mSuccess: MongoDB container is already running\e[0m"
    
    else
        #* If MongoDB container is not running, start it
        echo -e "\e[1;33mWARNING: MongoDB container is not running\e[0m"
        echo -e "\e[1;34mStarting MongoDB container...\e[0m"
        #* Start MongoDB container and exit if it fails
        if ! sudo docker start mongodb > /dev/null; then
            echo -e "\e[1;31mError: Failed to start MongoDB container\e[0m" >&2
            exit 1
        fi
        echo -e "\e[1;32mSuccess: MongoDB container started\e[0m"
    fi
else
    echo -e "\e[1;31mError: MongoDB container does not exist\e[0m"
    echo -e "\e[1;34mCreating MongoDB container...\e[0m"
    #* Pull MongoDB container and exit if it fails
    if ! sudo docker pull mongo:latest; then
        echo -e "\e[1;31mError: Failed to pull MongoDB container\e[0m" >&2
        exit 1
    fi
    echo -e "\e[1;32mSuccess: MongoDB container pulled\e[0m"
    #* Create MongoDB container
    echo -e "\e[1;34mCreating MongoDB container...\e[0m"
    sudo docker run -d --name mongodb \
        -v $(pwd)/data/db:/data/db \
        -p 27017:27017 \
        mongo:latest    
    echo -e "\e[1;34mWaiting for MongoDB to start...\e[0m"
    sleep 10
    echo -e "\e[1;32mSuccess: MongoDB container created\e[0m"    
fi

#* Get and copy the latest file
sudo chown -R $USER:$USER ~/Code/CVE_DB/vuln-db-backend/data/db && sudo chmod -R 755 ~/Code/CVE_DB/vuln-db-backend/data/db
LATEST_FILE=$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | head -n1)
echo -e "\e[1;34mGetting the latest file...\e[0m"
gsutil -q cp $LATEST_FILE ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json
echo -e "\e[1;32mSuccess: Latest file copied\e[0m"

#* Check if the file exists in the VM and use the example file if it doesn't

echo -e "\e[1;34mChecking if the file exists... in the VM\e[0m"
if [ ! -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json ]; then
    echo -e "\e[1;33mWARNING: Latest file does not exist in the VM\e[0m"
    if [ -f ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-example.json ]; then
        echo -e "\e[1;34mUsing example file...\e[0m"
        echo -e "\e[1;34mCopying example file to the container...\e[0m"
        sudo docker cp ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-example.json mongodb:/data/db/enriched-cves-example.json
        echo -e "\e[1;32mSuccess: Example file copied to the container\e[0m"
        #* Update MongoDB with the example file
        echo -e "\e[1;34mUpdating MongoDB with the example file...\e[0m"
        sudo docker exec mongodb mongoimport --jsonArray --db vuln_db --collection cves --drop --file /data/db/enriched-cves-example.json
        echo -e "\e[1;32mSuccess: MongoDB updated with the example file\e[0m"   
    else
        echo -e "\e[1;31mError: Example file does not exist\e[0m"
        exit 1
    fi
else
    echo -e "\e[1;32mSuccess: File exists\e[0m"
    echo -e "\e[1;34mCopying the file to the container...\e[0m"
    sudo docker cp ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json mongodb:/data/db/enriched-cves-latest.json
    echo -e "\e[1;32mSuccess: File copied to the container\e[0m"
    #* Update MongoDB with the latest CVEs
    echo -e "\e[1;34mUpdating MongoDB with the latest CVEs...\e[0m"
    sudo docker exec mongodb mongoimport --jsonArray --db vuln_db --collection cves --drop --file /data/db/enriched-cves-latest.json
    echo -e "\e[1;32mSuccess: MongoDB updated with the latest CVEs\e[0m"
fi