data "aws_ami" "amazon_linux" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }
  owners = ["amazon"]
}

resource "aws_iam_role" "bastion" {
  name               = "${var.prefix}-bastion"
  assume_role_policy = file("${path.module}/templates/bastion/instance-profile-policy.json")

  tags = var.common_tags
}

resource "aws_iam_role_policy_attachment" "bastion_attach_policy" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.prefix}-bastion-instance-profile"
  role = aws_iam_role.bastion.name
}


resource "aws_instance" "bastion" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.bastion_instance

  user_data            = file("${path.module}/templates/bastion/user-data.sh")
  iam_instance_profile = aws_iam_instance_profile.bastion.name
  key_name             = "${var.project}-${var.bastion_key_name}"
  subnet_id            = module.vpc.public_subnets[0]
  vpc_security_group_ids = [
    aws_security_group.bastion.id
  ]


  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-bastion" })
  )
}

resource "aws_security_group" "bastion" {
  description = "Control bastion inbound and outbound access"
  name        = "${var.prefix}-bastion"
  vpc_id      = module.vpc.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = module.vpc.private_subnets_cidr_blocks
  }

  tags = merge(
    var.common_tags,
    tomap({ "Name" = "${var.prefix}-sg-bastion" })
  )
}
