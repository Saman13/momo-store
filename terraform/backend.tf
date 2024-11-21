terraform {
  backend "s3" {
  endpoint = "storage.yandexcloud.net"
  bucket = "terraform-state-saman"
  region = "ru-central1"
  key = "bucket/terraform.tfstate"
  access_key = "YCAJEimMzGGGkBokFymyzDSsG"
  secret_key = "YCPzMLwbQTwJXtHlG_kdvJzrRB3ZXqKCVt53TyxO"
  skip_region_validation = true
  skip_credentials_validation = true
  }
}
