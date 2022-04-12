terraform {
  backend "s3" {
    bucket = "var.s3_bucket_name[count.index]"
    key = "terraform.tfstate"
    region = "eu-west-1"
    encrypt = true
  }
}

provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

resource "aws_s3_bucket" "storage" {
  count = length(var.s3_bucket_name)
  bucket = var.s3_bucket_name[count.index]

  tags = {
    Name        = var.s3_bucket_name[count.index]
    Environment = "ACME storage"
  }
}

