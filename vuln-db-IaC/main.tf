resource "google_storage_bucket" "cve_bucket" {
  name     = "cve-storage-bucket"
  location = "US"
}

resource "google_storage_bucket_object" "cve_json" {
  name   = "enriched-cves-example.json"
  bucket = google_storage_bucket.cve_bucket.name
  source = "/Users/galmoshkovitz/Code/Private/CVE-DB/vuln-db-IaC/enriched-cves-example.json"
}



resource "google_compute_instance" "vm_instance" {
  name         = "cve-vm"
  machine_type = var.vm_tier
  zone         = var.gcp_zone

  boot_disk {
    initialize_params {
      image = var.os_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = <<-EOF
    
# Install curl if not already installed




    #!/bin/bash
    # Update and install necessary packages
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common

    # Install Docker
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    apt-get update
    apt-get install -y docker-ce

    # Install Google Cloud SDK
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    apt-get update
    apt-get install -y google-cloud-sdk

    # Install python3.11-venv
    apt-get install -y python3.11-venv tmux git 

    # Enable and start Docker service
    systemctl enable docker
    systemctl start docker

    # Remove nodejs and npm
    apt-get remove nodejs npm -y

    # Install nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

    # Add nvm to path (or you can just close and reopen your terminal)
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

    # Install the LTS version of Node.js
    nvm install --lts

    # Verify installation
    node --version
    npm --version

    
    # curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    # sudo apt-get install -y nodejs



    # Create directory for service account key
    mkdir -p ~/.keys

    # Move the service account key to the appropriate directory
    mv /tmp/cve-db-sa.json ~/.keys/cve-db-sa.json

    # Set environment variable for Google Application Credentials
    export GOOGLE_APPLICATION_CREDENTIALS=~/.keys/cve-db-sa.json

    # Authenticate with GCP
    gcloud auth activate-service-account --key-file=~/.keys/cve-db-sa.json
    gcloud config set project ${var.project_id}


    # Create a directory for the JSON file
    mkdir -p ~/Code/CVE_DB/vuln-db-backend/data/db && sudo chown -R $USER:$USER ~/Code/CVE_DB/vuln-db-backend/data/db
    
    # Set up cron job to download the JSON file daily at midnight (FILE NAME = enriched-cves-YYYY-MM-DD.json)
    chmod +x ~/Code/CVE_DB/vuln-db-backend/app/update_cves.sh
    
    (crontab -l 2>/dev/null; echo "0 0 * * * ~/Code/CVE_DB/vuln-db-backend/app/update_cves.sh") | crontab -
    
    # # Set up cron job to download the JSON file daily at midnight (FILE NAME = enriched-cves-YYYY-MM-DD.json - SORT AND DOWNLOAD THE LATEST FILE)
    # (crontab -l 2>/dev/null; echo "0 0 * * * LATEST_FILE=\$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | head -n1) && gsutil cp \$LATEST_FILE ~/Code/CVE_DB/vuln-db-backend/data/enriched-cves-latest.json") | crontab -
    
    # # Set up cron job to download the JSON file daily at midnight (FILE NAME = enriched-cves-YYYY-MM-DD.json - SORT AND DOWNLOAD THE LATEST FILE)
    # (crontab -l 2>/dev/null; echo "0 0 * * * FIRST_FILE=\$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | tail -n1) && gsutil cp \$FIRST_FILE ~/Code/CVE_DB/vuln-db-backend/data/enriched-cves-first.json") | crontab -
    
    # (crontab -l 2>/dev/null; echo "0 0 * * * LATEST_FILE=\$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | head -n1) && gsutil cp \$LATEST_FILE ~/Code/CVE_DB/vuln-db-backend/data/enriched-cves-latest.json") | crontab -
    
    # (crontab -l 2>/dev/null; echo "0 0 * * * FIRST_FILE=\$(gsutil ls gs://cve-storage-bucket/enriched-cves-*.json | sort -r | tail -n1) && gsutil cp \$FIRST_FILE ~/Code/CVE_DB/vuln-db-backend/data/enriched-cves-first.json") | crontab -

    # Pull the latest MongoDB Docker image
    docker pull mongo:latest

    
    # Move to vuln-db-backend directory
    cd ~/Code/CVE_DB/vuln-db-backend
  
    # Create a virtual environment
    python3.11 -m venv .venv

    # Run the backend
    tmux new-session -d -s backend
    tmux attach -t backend


    # Check all the containers for mongodb (including the one that is running and stopped), stop and remove them
    # Find the container id
    
    CONTAINER_ID=$(docker ps -a --filter "name=mongodb" -q)
    # Stop the running container
    docker stop $CONTAINER_ID
    # Remove the stopped container
    docker rm $CONTAINER_ID

    # Run the MongoDB container
    docker run -d --name mongodb -v $(pwd)/data/db:/data/db -p 27017:27017 mongo:latest    

    docker exec mongodb ls -l /data/db/enriched-cves-latest.json
  
    # Wait for MongoDB to initialize
    sleep 10

    # Import the JSON file into MongoDB
    ls -l ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json
    docker exec mongodb mongoimport --jsonArray --db vuln_db --collection cves --file /data/db/enriched-cves-latest.json
    # docker exec mongodb mongoimport --jsonArray --db vuln_db --collection cves --file ~/Code/CVE_DB/vuln-db-backend/data/db/enriched-cves-latest.json
    
    docker exec -it mongodb mongosh --eval "use vuln_db; db.cves.count();"
    # Activate the virtual environment
    source .venv/bin/activate
    
    # Upgrade pip
    pip install --upgrade pip

    # Install requirements
    pip install -r requirements.txt

    # Run the backend
    python -m app.main

    # Detach from the session
    tmux detach

    # Move to vuln-db-frontend directory
    cd ~/Code/CVE_DB/vuln-db-frontend

    # Run the frontend
    tmux new-session -d -s frontend
    tmux attach -t frontend
    
    # Install dependencies
    npm install

    # Run the frontend
    # npm run dev
    # npm run build 

    # Install server globally
    sudo npm install -g serve -y

    # Serve the frontend app on port 80
    serve -s build -p 3000

    # Detach from the session
    tmux detach

  EOF

}   

