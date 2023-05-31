locals {
  prefix       = "test-app-ec2"
  suffix       = "stage"
  repo_owner   = "finexblock-dev"  
  repo_name    = "finexblock-matching-engine"   
  repo_branch    = "dev"   
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