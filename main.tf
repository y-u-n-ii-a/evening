terraform {
  cloud {
    organization = "yuniiaolkhova"
    workspaces {
      name = "evening"
    }
  }
}

provider "aws" {
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = local.default_tags
  }
}

# --------- network ---------
resource "aws_vpc" "vpc" {}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.vpc_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.environment}-public-subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = local.vpc_cidr
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.environment}-private-subnet"
  }
}

resource "aws_security_group" "rainy_evening" {
  name   = "bastion_ssh"
  vpc_id = aws_vpc.vpc.id

  dynamic "ingress" {
    for_each = {
      tcp   = 22
      http  = 80
      https = 443
    }
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = ingress.key
      cidr_blocks = [local.vpc_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --------- auto scaling group ---------

data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = [137112412989]

  filter {
    name   = "name"
    values = ["amzn2-ami-minimal-selinux-enforcing-hvm-*-x86_64-gp2"]
  }
}

resource "aws_launch_configuration" "rainy_evening" {
  image_id      = data.aws_ami.ubuntu_latest.id
  instance_type = "t3.micro"
  user_data     = file("user_data.sh")
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "rainy_evening" {
  launch_configuration = aws_launch_configuration.rainy_evening.id
  max_size             = 2
  min_size             = 2
  min_elb_capacity     = 2
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.rainy_evening.id]
}

resource "aws_elb" "rainy_evening" {
  name     = "rainy-evening"
  internal = false
  subnets  = [aws_subnet.public.id, aws_subnet.private.id]

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}