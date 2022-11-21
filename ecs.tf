resource "aws_ecs_cluster" "main" {
  name = "${var.prefix}-cluster"

  tags = var.common_tags
}

locals {
  aws_account_id       = data.aws_caller_identity.current.account_id
  service_namespace_id = aws_service_discovery_private_dns_namespace.app.id

}




resource "aws_iam_policy" "task_execution_role_policy" {
  name        = "${var.prefix}-task-exec-role-policy"
  path        = "/"
  description = "Allow retrieving images and adding to logs"
  policy      = file("${path.module}/templates/ecs/task-exec-role.json")
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${var.prefix}-task-exec-role"
  assume_role_policy = file("${path.module}/templates/ecs/assume-role-policy.json")
}
# permission that the task needs to start a new container
resource "aws_iam_role_policy_attachment" "task_execution_role" {
  role       = aws_iam_role.task_execution_role.name
  policy_arn = aws_iam_policy.task_execution_role_policy.arn
}
# role given to the running task: contains permission of the task at run time
resource "aws_iam_role" "app_iam_role" {
  name               = "${var.prefix}-api-task"
  assume_role_policy = file("${path.module}/templates/ecs/assume-role-policy.json")

  tags = var.common_tags
}

resource "aws_cloudwatch_log_group" "ecs_task_logs" {
  name = "${var.prefix}-api"
  tags = var.common_tags
}


data "template_file" "api_container_definitions" {
  template = file("${path.module}/templates/ecs/container-definitions.json.tpl")

  vars = {
    name                     = var.project
    app_image                = var.ecr_image_api
    proxy_image              = var.ecr_image_proxy
    django_secret_key        = var.django_secret_key
    admin                    = var.admin
    admin_password           = var.admin_password
    admin_email              = var.admin_email
    db_host                  = aws_db_instance.main.address
    db_name                  = aws_db_instance.main.name
    db_user                  = aws_db_instance.main.username
    db_pass                  = aws_db_instance.main.password
    log_group_name           = aws_cloudwatch_log_group.ecs_task_logs.name
    log_group_region         = var.region
    allowed_hosts            = aws_route53_record.app.fqdn
    s3_storage_bucket_name   = aws_s3_bucket.app_public_files.bucket
    s3_storage_bucket_region = var.region
    service_namespace_id     = local.service_namespace_id

  }
}

resource "aws_ecs_task_definition" "api" {
  family                   = "${var.prefix}-api"
  container_definitions    = data.template_file.api_container_definitions.rendered
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  task_role_arn            = aws_iam_role.app_iam_role.arn
  volume {
    name = "static"
  }

  tags = var.common_tags
}


resource "aws_security_group" "ecs_service" {
  description = "Access for the ECS service"
  name        = "${var.prefix}-ecs-service"
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
    from_port = 8000
    to_port   = 8000
    protocol  = "tcp"
    security_groups = [
      aws_security_group.lb.id
    ]

  }

  tags = var.common_tags
}

resource "aws_ecs_service" "api" {
  name            = "${var.prefix}-api"
  cluster         = aws_ecs_cluster.main.name
  task_definition = aws_ecs_task_definition.api.family
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = module.vpc.private_subnets
    security_groups = [aws_security_group.ecs_service.id]

  }
  load_balancer {
    target_group_arn = aws_lb_target_group.api.arn
    container_name   = "proxy"
    container_port   = 8000
  }
  depends_on = [aws_lb_listener.api_https]
}
data "template_file" "ecs_s3_write_policy" {
  template = file("${path.module}/templates/ecs/s3-write-policy.json.tpl")

  vars = {
    bucket_arn = aws_s3_bucket.app_public_files.arn
  }
}

resource "aws_iam_policy" "ecs_s3_access" {
  name        = "${var.prefix}-AppS3AccessPolicy"
  path        = "/"
  description = "Allow access to the traffic app S3 bucket"

  policy = data.template_file.ecs_s3_write_policy.rendered
}

resource "aws_iam_role_policy_attachment" "ecs_s3_access" {
  role       = aws_iam_role.app_iam_role.name
  policy_arn = aws_iam_policy.ecs_s3_access.arn
}


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
}