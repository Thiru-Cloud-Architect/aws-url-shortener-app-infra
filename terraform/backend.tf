terraform {
  backend "s3" {
    bucket       = "infra-code-utilities-bucket"
    key          = "url-shortener-dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}