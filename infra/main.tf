terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.9.0"
    }
  }
  backend "s3" {
    bucket  = "acme-storage-dev-kc-storage"
    key     = "infra_dev/terraform.tfstate"
    region  = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "aws_s3_bucket" "storage" {
  bucket = "${var.s3_bucket_name}-storage"

  tags = {
    Name        = "${var.s3_bucket_name}-storage"
    Environment = "ACME storage dev"
  }
}
