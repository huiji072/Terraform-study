data "aws_caller_identity" "current" {}

locals {
  bucket = "codepipeline-bucket-${data.aws_caller_identity.current.account_id}"
  folder = "example_folder"
  file = "example.txt"
}
