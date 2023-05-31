# resource "aws_instance" "ec2" {
#   ami = "ami-0084b3e5b489354fd"
#   instance_type = "t2.micro"

#   subnet_id = var.public_subnet_ids[0]

#   iam_instance_profile = aws_iam_instance_profile.iam_instance_profile.name
#   security_groups = [aws_security_group.sg.id]

#   key_name = "${local.prefix}-${local.suffix}"

#   tags = {
#     Name = "${local.prefix}-${local.suffix}"
#   }
# }

# resource "aws_eip" "web" {
#   vpc = true
# }

# resource "aws_eip_association" "web" {
#   allocation_id = aws_eip.web.id
#   instance_id   = aws_instance.ec2.id
# }

# resource "aws_iam_role" "iam-role-for-ec2" {
#   name               = "${local.prefix}-ec2-${local.suffix}"
#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action = "sts:AssumeRole"
#         Effect = "Allow"
#         Principal = {
#           Service = "ec2.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "secrets_manager" {
#   policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
#   role       = aws_iam_role.iam-role-for-ec2.name
# }

# resource "aws_iam_role_policy_attachment" "s3_read_only" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
#   role       = aws_iam_role.iam-role-for-ec2.name
# }

# resource "aws_iam_role_policy_attachment" "code_deploy_role" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
#   role       = aws_iam_role.iam-role-for-ec2.name
# }

# resource "aws_iam_role_policy_attachment" "ec2_code_deploy_role" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
#   role       = aws_iam_role.iam-role-for-ec2.name
# }

# resource "aws_iam_role_policy_attachment" "system-manager" {
#   policy_arn = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
#   role       = aws_iam_role.iam-role-for-ec2.name
# }
# resource "aws_iam_role_policy_attachment" "system-manager-2" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#   role       = aws_iam_role.iam-role-for-ec2.name
# }
# resource "aws_iam_instance_profile" "iam_instance_profile" {
#   name = "${local.prefix}-ec2-${local.suffix}"
#   role = aws_iam_role.iam-role-for-ec2.name
# }

# # resource "aws_key_pair" "key-pair" {
# #   key_name   = "${local.prefix}-${local.suffix}"
# #   public_key = file("~/.ssh/id_rsa.pub") # 필요한 경우 이 파일 경로를 해당 공개 키 파일 경로로 변경하세요.
# # }
