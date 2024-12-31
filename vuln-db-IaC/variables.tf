
variable "gcp_project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP Region"
  type        = string
}

variable "gcp_zone" {
  description = "GCP Zone"
  type        = string
}


variable "vm_tier" {
  description = "VM Tier"
  type        = string
}

variable "os_image" {
  description = "OS Image"
  type        = string
}

variable "size" {
  description = "Size"
  type        = string
}