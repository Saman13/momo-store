variable "cloud_id" {
  description = "Cloud ID"
  type = string
}

variable "folder_id" {
  description = "Cloud folder ID"
  type = string
}

variable "zone_name" {
  description = "Cloud zone name"
  type = string
}

variable "token" {
  description = "OAuth token"
  sensitive = true
}

variable "domain" {
  description = "DNS domain"
  sensitive = true
}