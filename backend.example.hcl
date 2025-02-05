endpoints = {
    s3 = "https://s3.minio.example.com"
}
bucket = "terraform"
access_key = "ACCESS_KEY"
secret_key = "SECRET_KEY"
region = "us-east-1"

skip_region_validation      = true
skip_credentials_validation = true # Skip AWS related checks and validations
skip_requesting_account_id  = true
skip_metadata_api_check     = true
use_path_style              = true # Enable path-style S3 URLs (https://<HOST>/<BUCKET> https://developer.hashicorp.com/terraform/language/settings/backends/s3#use_path_style
