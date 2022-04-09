variable "aws_profile" {
  default = "default"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "s3_bucket_name" {
  type = list(any)
  default = [
    "acme-storage-dev-kc",
    "acme-storage-prod-kc",
  ]
}
