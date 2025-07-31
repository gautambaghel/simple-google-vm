# Configure the Google Cloud Provider
terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }
}

# Configure the Google Provider
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Configure the Google Beta Provider
provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# Create a VPC network using the standard google provider
resource "google_compute_network" "vpc_network" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
  description             = "VPC network for simple VM"
}

# Create a subnet using the standard google provider
resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name_prefix}-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  description   = "Subnet for simple VM"
}

# Create a firewall rule using google-beta provider (to demonstrate beta usage)
resource "google_compute_firewall" "allow_ssh" {
  provider = google-beta

  name    = "${var.name_prefix}-allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-allowed"]

  description = "Allow SSH access to VM instances"
}

# Create a firewall rule for HTTP using standard google provider
resource "google_compute_firewall" "allow_http" {
  name    = "${var.name_prefix}-allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]

  description = "Allow HTTP and HTTPS access"
}

# Create a VM instance using the standard google provider
resource "google_compute_instance" "vm_instance" {
  name         = "${var.name_prefix}-vm"
  machine_type = var.machine_type
  zone         = var.zone

  tags = ["ssh-allowed", "http-server"]

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size
      type  = "pd-standard"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = var.ssh_public_key != "" ? "${var.ssh_user}:${var.ssh_public_key}" : ""
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx
    echo "<h1>Hello from ${var.name_prefix}-vm</h1>" > /var/www/html/index.html
  EOF

  service_account {
    email  = google_service_account.vm_service_account.email
    scopes = ["cloud-platform"]
  }

  depends_on = [
    google_compute_firewall.allow_ssh,
    google_compute_firewall.allow_http
  ]
}

# Create a service account using google-beta provider
resource "google_service_account" "vm_service_account" {
  provider = google-beta

  account_id   = "${var.name_prefix}-vm-sa"
  display_name = "Service Account for ${var.name_prefix} VM"
  description  = "Service account for the simple VM instance"
}

# Create a static IP address using standard google provider
resource "google_compute_address" "static_ip" {
  name   = "${var.name_prefix}-static-ip"
  region = var.region
}
