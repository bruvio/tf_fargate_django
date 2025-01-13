#trivy:ignore:AVD-AWS-0053
resource "aws_lb" "api" {
  name                       = "${var.project}-main"
  load_balancer_type         = "application"
  subnets                    = module.vpc.public_subnets
  drop_invalid_header_fields = true
  security_groups            = [aws_security_group.lb.id]

  tags = var.common_tags
}

resource "aws_lb_target_group" "api" {
  name     = "${var.project}-api"
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  target_type = "ip"
  port        = 8000

  health_check {
    path                = "/health/"
    protocol            = "HTTP"
    interval            = 60
    timeout             = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-299"
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


resource "aws_lb_listener_rule" "host_header_rule" {
  listener_arn = aws_lb_listener.api_https.arn
  priority     = 100

  condition {
    host_header {
      values = ["${aws_route53_record.app.fqdn}"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api.arn
  }
}

#trivy:ignore:AVD-AWS-0104
resource "aws_security_group" "lb" {
  description = "Allow access to Application Load Balancer"
  name        = "${var.project}-lb"
  vpc_id      = module.vpc.vpc_id


  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = var.private ? [var.my_ip] : ["0.0.0.0/0"] # Conditional ingress rule

  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = var.private ? [var.my_ip] : ["0.0.0.0/0"] # Conditional ingress rule

  }

  egress {
    protocol    = "tcp"
    from_port   = 8000
    to_port     = 8000
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
  tags = var.common_tags
}
