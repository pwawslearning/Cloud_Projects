terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.0.0-beta3"
    }
  }
}

provider "aws" {
  # Configuration options
  profile = var.profile
}


# resource "aws_s3_bucket" "to_storestatefile" {
#   bucket = "to-storetfstatefile-1706"
# }
# # To store statefile in s3
# terraform {
#   backend "s3" {
#     bucket = "to-storetfstatefile-1706"
#     key    = "terraform.tfstate"
#     region = "ap-southeast-1"
#   }
# }
