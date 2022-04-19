variable "aws_profile" {
  default = "default"
}

variable "aws_region" {
  default = "eu-west-1"
}

variable "s3_bucket_name" {
  type    = string
  default = "acme-storage-dev-kc"
}
