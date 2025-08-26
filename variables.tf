variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "simple-vm"
}

variable "machine_type" {
  description = "The machine type for the VM instance"
  type        = string
  default     = "e2-micro"
}

variable "image_project" {
  description = "The image project to use for the VM instance"
  type        = string
  default     = "ubuntu-os-cloud"
}

variable "image_family" {
  description = "The image family to use for the VM instance"
  type        = string
  default     = "ubuntu-2404-lts-amd64"
}

variable "disk_size" {
  description = "The size of the boot disk in GB"
  type        = number
  default     = 20
}

variable "ssh_user" {
  description = "SSH username"
  type        = string
  default     = "ubuntu"
}

variable "ssh_public_key" {
  description = "SSH public key for accessing the VM"
  type        = string
  default     = ""
}
