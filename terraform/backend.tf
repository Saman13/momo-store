terraform {
  backend "s3" {
  endpoint = "storage.yandexcloud.net"
  bucket = "terraform-state-saman"
  region = "ru-central1"
  key = "bucket/terraform.tfstate"
  access_key = "aje1j5uq9jucjduuntoh"
  secret_key = "AQVNwZl9pM_Mm33r9xG5nleFAWuJ76LXoGNfmDED"
  skip_region_validation = true
  skip_credentials_validation = true
  }
}