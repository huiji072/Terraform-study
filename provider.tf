provider "aws" {
  region     = "ap-northeast-2"
  access_key = var.access_key
  secret_key = var.secret_key
}

data "aws_caller_identity" "current" {}
