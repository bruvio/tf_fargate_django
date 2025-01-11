resource "aws_db_subnet_group" "main" {
  name       = "${var.project}-main"
  subnet_ids = module.vpc.private_subnets

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.project}-main" })
  )
}

resource "aws_security_group" "rds" {
  description = "Allow access to the RDS database instance."
  name        = "${var.prefix}-rds-inbound-access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    # Existing ingress rule for Bastion and ECS services
    protocol  = "tcp"
    from_port = 5432
    to_port   = 5432
    security_groups = [
      aws_security_group.bastion.id,
      aws_security_group.ecs_service.id,
    ]
  }

  ingress {
    # New ingress rule for your local machine
    protocol  = "tcp"
    from_port = 5432
    to_port   = 5432
    cidr_blocks = [
      "YOUR_PUBLIC_IP/32", # Replace YOUR_PUBLIC_IP with your actual public IP address
    ]
  }

  tags = var.common_tags
}


resource "aws_db_instance" "main" {
  identifier                 = "${var.project}-db"
  db_name                    = var.db_name
  auto_minor_version_upgrade = true
  allocated_storage          = var.rds_storage
  storage_type               = "gp2"
  engine                     = "postgres"
  engine_version             = var.engine_version
  instance_class             = var.rds_instance
  db_subnet_group_name       = aws_db_subnet_group.main.name
  password                   = var.db_password
  username                   = var.db_username
  backup_retention_period    = 0
  multi_az                   = false
  skip_final_snapshot        = true
  vpc_security_group_ids     = [aws_security_group.rds.id]

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.project}-main" })
  )
}
