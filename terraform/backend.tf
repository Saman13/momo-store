terraform {
  backend "s3" {
  endpoint = "storage.yandexcloud.net"
  bucket = "terraform-state-saman"
  region = "ru-central1"
  key = "bucket/terraform.tfstate"
  access_key = "YCAJELbbZRJ5cRfJG7gq_Oxfo"
  secret_key = "YCPRUhzwQQke1gbsz3TV6EYxQYDG2y5OKMgJTYPm"
  skip_region_validation = true
  skip_credentials_validation = true
  }
}