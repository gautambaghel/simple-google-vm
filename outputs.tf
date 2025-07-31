output "vm_name" {
  description = "Name of the VM instance"
  value       = google_compute_instance.vm_instance.name
}

output "vm_internal_ip" {
  description = "Internal IP address of the VM instance"
  value       = google_compute_instance.vm_instance.network_interface[0].network_ip
}

output "vm_external_ip" {
  description = "External IP address of the VM instance"
  value       = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

output "static_ip" {
  description = "Static IP address"
  value       = google_compute_address.static_ip.address
}

output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc_network.name
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "service_account_email" {
  description = "Email of the service account"
  value       = google_service_account.vm_service_account.email
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "gcloud compute ssh ${google_compute_instance.vm_instance.name} --zone=${var.zone} --project=${var.project_id}"
}
