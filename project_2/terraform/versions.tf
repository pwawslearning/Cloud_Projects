terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.67.0"
    }
  }
}

provider "aws" {
  # Configuration options
  profile = var.profile
}

<<<<<<< HEAD
=======

>>>>>>> baa3b26cf2a312c362ab12683c4fe10ce2749513
# To store statefile in s3
terraform {
  backend "s3" {
    bucket = "apache-websvr-bk"
    key    = "terraform.tfstate"
    region = "ap-southeast-1"
  }
}
