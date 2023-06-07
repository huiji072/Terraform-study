output "ec2_public_ip" {
  value       = aws_instance.ec2.id
  description = "The public IP address of the EC2 instance"
}