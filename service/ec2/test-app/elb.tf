# Target Group
resource "aws_lb_target_group" "example" {
  name     = "${local.prefix}-${local.suffix}"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id

  health_check {
    enabled = true
    interval = 30
    path = "/"
    timeout = 5
  }
}

# ALB
resource "aws_lb" "example" {
  name               = "${local.prefix}-${local.suffix}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sg.id]
  subnets            = var.public_subnet_ids
}

resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.example.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.example.arn
  }
}

# Target Group Attachment
resource "aws_lb_target_group_attachment" "example" {
  target_group_arn = aws_lb_target_group.example.arn
  target_id        = aws_instance.ec2.private_ip
  port             = 80
}