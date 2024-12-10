terraform {
  backend "s3" {
  endpoint = "storage.yandexcloud.net"
  bucket = "terraform-state-saman"
  region = "ru-central1"
  key = "bucket/terraform.tfstate"
  access_key = ""
  secret_key = ""
  skip_region_validation = true
  skip_credentials_validation = true
  }
}
