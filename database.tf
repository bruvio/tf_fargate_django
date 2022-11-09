resource "aws_db_subnet_group" "main" {
  name = "${var.prefix}-main"
  subnet_ids = [
    aws_subnet.private_a.id,
    aws_subnet.private_b.id
  ]

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-main" })
  )
}

resource "aws_security_group" "rds" {
  description = "Allow access to the RDS database instance."
  name        = "${var.prefix}-rds-inbound-access"
  vpc_id      = aws_vpc.main.id

  ingress {
    protocol  = "tcp"
    from_port = 5432
    to_port   = 5432
    security_groups = [
      aws_security_group.bastion.id,
      aws_security_group.ecs_service.id,
    ]
  }

  tags = var.common_tags
}

resource "aws_db_instance" "main" {
  identifier              = "${var.prefix}-db"
  name                    = var.db_name
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "12.7"
  instance_class          = "db.t2.micro"
  db_subnet_group_name    = aws_db_subnet_group.main.name
  password                = var.db_password
  username                = var.db_username
  backup_retention_period = 0
  multi_az                = false
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.rds.id]

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-main" })
  )
}