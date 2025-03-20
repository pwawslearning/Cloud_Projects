terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.91.0"
    }
  }
}
provider "aws" {
  profile = "test-cli"
  region  = "ap-southeast-1"
}
provider "aws" {
  profile = "test-cli"
  region  = "ap-southeast-1"
  alias   = "ap-southeast-1"
}
provider "aws" {
  profile = "test-cli"
  region  = "ap-southeast-2"
  alias   = "ap-southeast-2"
}

