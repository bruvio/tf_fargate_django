# ----------------------------
# ECS Cluster
# ----------------------------
resource "aws_ecs_cluster" "main" {
  name = "${var.project}-cluster"

  tags = var.common_tags
}

# ----------------------------
# Locals
# ----------------------------
locals {
  aws_account_id       = data.aws_caller_identity.current.account_id
  service_namespace_id = aws_service_discovery_private_dns_namespace.app.id
}

# ----------------------------
# IAM Policies and Roles
# ----------------------------

## Task Execution Role Policy
resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${var.project}-task-exec-role-policy"
  path        = "/"
  description = "Allow retrieving images and adding to logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "secretsmanager:GetSecretValue",
          "kms:Decrypt"
        ]
        Resource = "*"
      }
    ]
  })
}

## Task Execution Role
resource "aws_iam_role" "task_execution_role" {
  name = "${var.project}-task-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
        }
        Effect = "Allow"
      }
    ]
  })
}

## Attach Task Execution Policy to Role
resource "aws_iam_role_policy_attachment" "task_execution_role_attachment" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}

## App IAM Role
resource "aws_iam_role" "app_iam_role" {
  name = "${var.project}-api-task"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = ["ecs.amazonaws.com", "ecs-tasks.amazonaws.com"]
        }
        Effect = "Allow"
      }
    ]
  })

  tags = var.common_tags
}

## S3 Access Policy
resource "aws_iam_policy" "ecs_s3_access" {
  name        = "${var.project}-AppS3AccessPolicy"
  path        = "/"
  description = "Allow access to the traffic app S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          # "s3:GetObjectAcl",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject",
          # "s3:PutObjectAcl"
        ]
        Resource = [
          "${aws_s3_bucket.app_public_files.arn}/*",
          "${aws_s3_bucket.app_public_files.arn}"
        ]
      }
    ]
  })
}

## Attach S3 Access Policy to App IAM Role
resource "aws_iam_role_policy_attachment" "ecs_s3_access_attachment" {
  role       = aws_iam_role.app_iam_role.name
  policy_arn = aws_iam_policy.ecs_s3_access.arn
}

# ----------------------------
# CloudWatch Log Group
# ----------------------------
resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${var.project}-api"
  tags = var.common_tags
}

# ----------------------------
# ECS Task Definition
# ----------------------------
resource "aws_ecs_task_definition" "api" {
  family                   = "${var.project}-api"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.app_iam_role.arn

  container_definitions = jsonencode([
    {
      name              = var.project
      image             = var.ecr_image_api
      essential         = true
      memoryReservation = 256
      environment = [
        { name = "DJANGO_SECRET_KEY", value = var.django_secret_key },
        { name = "DB_HOST", value = aws_db_instance.main.address },
        { name = "DB_NAME", value = aws_db_instance.main.db_name },
        { name = "DB_USER", value = aws_db_instance.main.username },
        { name = "DB_PASS", value = aws_db_instance.main.password },
        { name = "ALLOWED_HOSTS", value = aws_route53_record.app.fqdn },
        { name = "ADMIN_EMAIL", value = var.admin_email },
        { name = "ADMIN_PASSWORD", value = var.admin_password },
        { name = "ADMIN", value = var.admin },
        { name = "S3_STORAGE_BUCKET_NAME", value = aws_s3_bucket.app_public_files.bucket },
        { name = "S3_STORAGE_BUCKET_REGION", value = var.region },
        { name = "SERVICE_DISCOVERY_NAMESPACE_ID", value = local.service_namespace_id },
        { name = "SYSTEM_ENV", value = "PRODUCTION" },
        { name = "DEBUG", value = "0" },
        { name = "S3_STORAGE_BACKEND", value = "1" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_task_logs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "${var.project}"
        }
      }
      portMappings = [
        {
          containerPort = 9000
          hostPort      = 9000
          protocol      = "tcp"
        }
      ]

    },
    {
      name              = "proxy"
      image             = var.ecr_image_proxy
      essential         = true
      memoryReservation = 256
      environment = [
        { name = "APP_HOST", value = "127.0.0.1" },
        { name = "APP_PORT", value = "9000" },
        { name = "LISTEN_PORT", value = "8000" },
        { name = "S3_STORAGE_BUCKET_NAME", value = aws_s3_bucket.app_public_files.bucket },
        { name = "S3_STORAGE_BUCKET_REGION", value = var.region },
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_task_logs.name
          "awslogs-region"        = var.region
          "awslogs-stream-prefix" = "proxy"
        }
      }
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]

    }
  ])



  tags = var.common_tags
}

# ----------------------------
# Security Group for ECS Service
# ----------------------------
resource "aws_security_group" "ecs_service" {
  description = "Access for the ECS service"
  name        = "${var.project}-ecs-service"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  ingress {
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.lb.id]
  }

  tags = var.common_tags
}

# ----------------------------
# ECS Service
# ----------------------------
resource "aws_ecs_service" "api" {
  name                 = "${var.project}-api"
  cluster              = aws_ecs_cluster.main.name
  task_definition      = aws_ecs_task_definition.api.arn
  desired_count        = 1
  launch_type          = "FARGATE"
  force_new_deployment = var.force_new_deployment
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_service.id]
    assign_public_ip = false # Typically false for Fargate in private subnets
  }
  deployment_circuit_breaker {
    enable   = var.enable_deployment_circuit_breaker
    rollback = var.enable_rollback
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "proxy"
    container_port   = 8000
  }

  depends_on = [aws_lb_listener.api_https]

  tags = var.common_tags
}

# ----------------------------
# Service Discovery
# ----------------------------
resource "aws_service_discovery_service" "app_service" {
  name = var.project

  dns_config {
    namespace_id = local.service_namespace_id

    dns_records {
      ttl  = 10
      type = "A"
    }

    dns_records {
      ttl  = 10
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = var.common_tags
}

