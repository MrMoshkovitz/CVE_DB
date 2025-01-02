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

    # Enable and start Docker service
    systemctl enable docker
    systemctl start docker

    # Install Node.js and npm using NodeSource
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs



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
    mkdir -p ~/data

    # Set up cron job to download the JSON file daily at midnight (FILE NAME = enriched-cves-example-YYYY-MM-DD.json - SORT AND DOWNLOAD THE LATEST FILE)
    (crontab -l 2>/dev/null; echo "0 0 * * * LATEST_FILE=\$(gsutil ls gs://cve-storage-bucket/enriched-cves-example-*.json | sort -r | head -n1) && gsutil cp \$LATEST_FILE ~/data/enriched-cves-example.json") | crontab -
    # Pull the latest MongoDB Docker image
    docker pull mongo:latest

    # Run the MongoDB container
    docker run -d \
      --name mongodb \
      -v /data:/data \
      -p 27017:27017 \
      mongo:latest

    # Wait for MongoDB to initialize
    sleep 10

    # Import the JSON file into MongoDB
    docker exec mongodb mongoimport --jsonArray --db vuln_db --collection cves --file ~/data/enriched-cves-example.json
  EOF

}   


