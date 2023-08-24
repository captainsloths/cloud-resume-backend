terraform {
  required_providers {
    aws = {
      version = ">=4.9.0"
      source  = "hashicorp/aws"
    }
  }
}
provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

provider "aws" {
  alias = "aws-s3"
  profile = "default"
  region = "us-east-1"
}
