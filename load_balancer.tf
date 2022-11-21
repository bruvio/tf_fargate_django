resource "aws_lb" "api" {
  name               = "${var.prefix}-main"
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets

  security_groups = [aws_security_group.lb.id]

  tags = var.common_tags
}

resource "aws_lb_target_group" "api" {
  name     = "${var.prefix}-api"
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  target_type = "ip"
  port        = 8000

  health_check {
    path = "/admin/login/"
  }
}

resource "aws_lb_listener" "api" {
  load_balancer_arn = aws_lb.api.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "api_https" {
  load_balancer_arn = aws_lb.api.arn
  port              = 443
  protocol          = "HTTPS"

  certificate_arn = aws_acm_certificate_validation.cert.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}


resource "aws_security_group" "lb" {
  description = "Allow access to Application Load Balancer"
  name        = "${var.prefix}-lb"
  vpc_id      = module.vpc.vpc_id


  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.common_tags
}
