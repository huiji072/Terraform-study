resource "aws_codepipeline" "pipeline" {
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
      output_artifacts = ["source"]

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
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["source"]
      version         = "1"

      configuration = {
        ApplicationName  = aws_codedeploy_app.codedeploy_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.deployment_group.deployment_group_name
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

resource "aws_iam_role_policy_attachment" "s3_read_only-pipeline" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.codedeploy_role.name
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
        "*"
    ]
  }

  statement {
    actions = [
      "codedeploy:*"
    ]
    resources = ["*"]
  }
}
