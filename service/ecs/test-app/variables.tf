locals {
  region       = "ap-northeast-2"
  prefix       = "test-app"
  suffix       = "stage"
  repo_owner   = "huijikim00"  
  repo_name    = "code-test"   
  repo_branch    = "main"
  ecr_repository_name = "test-app-stage"
  ecr_repository_tag = "dev"
  buildspec_filename = "./buildspec.yml"
}

variable "github_token" {
  type        = string
  description = "The GitHub Token."
}

variable "vpc_id" {
  type        = string
  description = "The vpc ID"
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "The public subnet IDs"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The private subnet IDs"
}

variable "s3_codepipeline_id" {
  type        = string
  description = "The s3 codepipeline ID"
}

variable "s3_codepipeline_arn" {
  type        = string
  description = "The s3 codepipeline ARN"
}