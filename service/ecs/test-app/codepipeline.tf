resource "aws_codepipeline" "pipeline-test-app" {
  name     = "${local.prefix}-${local.suffix}"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = var.s3_codepipeline_id
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
      output_artifacts = ["Source"]

      configuration = {
        Owner               = local.repo_owner
        Repo                = local.repo_name
        Branch              = local.repo_branch
        OAuthToken          = var.github_token
        # PollForSourceChanges = "true"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name            = "Build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      version         = "1"
      input_artifacts  = ["Source"]
      output_artifacts = ["Build"]

      configuration = {
        ProjectName = "${local.prefix}-${local.suffix}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["Build"]

      configuration = { 
        # FileName          = "imagedefinitions.json"
        ClusterName       = aws_ecs_cluster.this.name
        ServiceName       = aws_ecs_service.this.name
      }
    }
  }
}

resource "aws_iam_role" "codepipeline_role" {
  name = "${local.prefix}-codepipeline-${local.suffix}"

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
      "s3:*"
    ]
    resources = [
        "*"    ]
  }

  statement {
    actions = [
      "codedeploy:*",
      "ec2:*",
      "codebuild:*",
      "ecr:*",
      "ecs:*"
    ]
    resources = ["*"]
  }
}
