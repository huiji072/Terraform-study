terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.67.0"
    }
  }
}

resource "aws_instance" "example" {
  ami = "ami-0346548773a8dbddd"
  instance_type = "t2.micro"

  tags = {
    Name = "example-instance"
  }
}
