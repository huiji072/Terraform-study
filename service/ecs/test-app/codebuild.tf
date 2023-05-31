data "aws_caller_identity" "current" {}

resource "aws_codebuild_project" "example" {
  name          = "${local.prefix}-${local.suffix}"
  description   = "An example CodeBuild project using Terraform"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode = true

    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = local.region
    }
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "${data.aws_caller_identity.current.account_id}"
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = local.ecr_repository_name
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = local.ecr_repository_tag
    }
    environment_variable {
      name  = "EnvironmentName"
      value = "${local.prefix}-${local.suffix}"
    }

  }

  source {
    type            = "GITHUB"
    location        = "https://github.com/${local.repo_owner}/${local.repo_name}.git"
    git_clone_depth = 1
    buildspec = local.buildspec_filename
    # buildspec = file("buildspec.yml")
  }

}

resource "aws_iam_role" "codebuild_role" {
  name = "${local.prefix}-codebuild-${local.suffix}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment_1" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.codebuild_role.name
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment_2" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.codebuild_role.name
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment_3" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
  role       = aws_iam_role.codebuild_role.name
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment_4" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.codebuild_role.name
}

