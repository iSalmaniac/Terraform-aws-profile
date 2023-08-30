terraform {
  backend "s3" {
    bucket = "terraform-provisioning"
    key = "terraform/backend"
    region = "ap-south-1"
  }
}