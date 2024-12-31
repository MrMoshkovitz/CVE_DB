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
    #!/bin/bash
    # Update and install necessary packages
    sudo apt update -y
    sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

    # Install Docker
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
    sudo apt update
    sudo apt install -y docker-ce

    # Install Google Cloud SDK
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    sudo apt update 
    sudo apt install -y google-cloud-sdk

    # Install MongoDB
    sudo apt install -y mongodb

    # Add Docker to Docker group
    sudo usermod -aG docker $USER

    # Enable and start Docker service
    sudo systemctl enable docker
    sudo systemctl start docker
  EOF
}   
