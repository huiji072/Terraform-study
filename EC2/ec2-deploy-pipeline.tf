locals {
  github_token = var.github_token # GitHub 토큰으로 대체
  repo_owner   = "huijikim00"   # GitHub 저장소 소유자로 대체
  repo_name    = "code-test"     # GitHub 저장소 이름으로 대체
}

data "aws_caller_identity" "current" {}

resource "aws_codepipeline" "pipeline" {
  name     = "pipe-test"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        Owner               = local.repo_owner
        Repo                = local.repo_name
        Branch              = "main"
        OAuthToken          = local.github_token
        # PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["source"]
      version         = "1"

      configuration = {
        ApplicationName  = aws_codedeploy_app.app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
      }
    }
  }
}

resource "aws_codedeploy_app" "app" {
  name = "deploy-application"
}

resource "aws_codedeploy_deployment_group" "deployment_group" {
  app_name               = aws_codedeploy_app.app.name
  deployment_group_name  = "deploy-group-test"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

#   autoscaling_groups = [
#     "your-autoscaling-group-name", # 실제 Autoscaling 그룹 이름으로 대체하세요
#   ]

  # CodeDeploy EC2/On-Premises 태그 설정
  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "ec2-name" # 실제 인스턴스 이름으로 대체하세요
    }
  }
}

resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codedeploy_policy" {
  name   = "codedeploy_policy"
  role   = aws_iam_role.codedeploy_role.id
  policy = data.aws_iam_policy_document.codedeploy_policy_document.json
}

data "aws_iam_policy_document" "codedeploy_policy_document" {
  statement {
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeInstanceStatus",
      "autoscaling:Describe*",
      "autoscaling:SuspendProcesses",
      "autoscaling:ResumeProcesses"
    ]
    resources = ["*"]
  }
}

resource "aws_s3_bucket" "pipeline_bucket" {
  bucket = "codepipeline-bucket-${data.aws_caller_identity.current.account_id}"
  acl    = "private"
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy_document.json
}

data "aws_iam_policy_document" "codepipeline_policy_document" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning"
    ]
    resources = [
      "${aws_s3_bucket.pipeline_bucket.arn}",
      "${aws_s3_bucket.pipeline_bucket.arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.pipeline_bucket.arn}/*"
    ]
  }

  statement {
    actions = [
      "codedeploy:*"
    ]
    resources = ["*"]
  }
}
