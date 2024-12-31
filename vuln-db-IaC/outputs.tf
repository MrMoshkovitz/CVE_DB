# outputs.tf

output "cve_bucket_name" {
  value = google_storage_bucket.cve_bucket.name
}

output "cve_bucket_id" {
  value = google_storage_bucket.cve_bucket.id
}

output "cve_bucket_url" {
  value = google_storage_bucket.cve_bucket.url
}

output "cve_bucket_self_link" {
  value = google_storage_bucket.cve_bucket.self_link
}

output "vm_instance_name" {
  value = google_compute_instance.vm_instance.name
}

output "vm_instance_id" {
  value = google_compute_instance.vm_instance.id
}

output "vm_instance_self_link" {
  value = google_compute_instance.vm_instance.self_link
}

output "vm_instance_public_ip" {
  value = google_compute_instance.vm_instance.network_interface[0].access_config[0].nat_ip
}

