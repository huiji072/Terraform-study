resource "aws_codedeploy_app" "codedeploy-app-test-app" {
  name = "${local.prefix}-${local.suffix}"
}

resource "aws_codedeploy_deployment_group" "deployment-group-test-app" {
  app_name               = aws_codedeploy_app.codedeploy-app-test-app.name
  deployment_group_name  = "${local.prefix}-${local.suffix}"
  service_role_arn       = aws_iam_role.codedeploy_role.arn

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "${local.prefix}-${local.suffix}"
    }
  }
}


resource "aws_iam_role" "codedeploy_role" {
  name = "${local.prefix}-codedeploy-${local.suffix}"

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
      "autoscaling:ResumeProcesses",
      "s3:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy_attachment" "codebuild_policy_attachment_s3" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.codedeploy_role.name
}