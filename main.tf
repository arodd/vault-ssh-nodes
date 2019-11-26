data aws_ami "immutable" {
  most_recent = true
  owners      = ["self"]
  name_regex  = "${var.ami_prefix}.*"

  filter {
    name   = "tag:OS"
    values = [var.ami_os]
  }

  filter {
    name   = "tag:OS-Version"
    values = [var.ami_os_release]
  }

  filter {
    name   = "tag:Owner"
    values = [var.owner]
  }

  filter {
    name   = "tag:Release"
    values = [var.ami_release]
  }
}

resource "random_id" "environment_name" {
  byte_length = 4
  prefix      = "${var.name_prefix}-"
}

resource "aws_instance" "web" {
  count         = 2
  ami           = data.aws_ami.immutable.id
  instance_type = "t3.nano"
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.internal-default.id
  ]

  subnet_id = var.web_subnet
  tags = {
    Name = "${random_id.environment_name.hex}-web-${count.index + 1}"
  }
}

resource "aws_instance" "app" {
  count         = 2
  ami           = data.aws_ami.immutable.id
  instance_type = "t3.nano"
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.internal-default.id
  ]
  subnet_id = var.app_subnet
  tags = {
    Name = "${random_id.environment_name.hex}-app-${count.index + 1}"
  }
}

resource "aws_security_group" "internal-default" {
  name        = "${random_id.environment_name.hex}-wide open"
  description = "Allow all"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
