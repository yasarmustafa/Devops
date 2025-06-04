//This Terraform Template creates 4 Ansible Machines on EC2 Instances
//Ansible Machines will run on Amazon Linux 2023 and Ubuntu 22.04 with custom security group
//allowing SSH (22) and HTTP (80) connections from anywhere.
//User needs to select appropriate key name when launching the instance.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" 
}

# Security Group
resource "aws_security_group" "public_sg" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Default VPC ve Public Subnet'i al
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default_public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Amazon Linux 2023 EC2 (3 adet)
resource "aws_instance" "amzn_linux" {
  count         = 3
  ami           = var.amznlnx2023
  instance_type = var.instance_type
  subnet_id     = element(data.aws_subnets.default_public.ids, 0)
  key_name      = var.key_name # key-pem yolunu kontrol edin
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  tags = {
    Name = element(var.tags, count.index)
  }
}

# Ubuntu 22.04 EC2 (1 adet)
resource "aws_instance" "ubuntu" {
  ami           = var.ubuntu 
  instance_type = var.instance_type
  subnet_id     = element(data.aws_subnets.default_public.ids, 0)
  key_name      = var.key_name # key-pem yolunu kontrol edin
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  tags = {
    Name = "node_3"
  }
}
