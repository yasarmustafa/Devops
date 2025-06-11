//This Terraform Template creates 3 Ansible Machines on EC2 Instances
//Ansible Machines will run on ubuntu 22.04 with custom security group
//allowing SSH (22), HTTP (80) and MYSQL/Aurora (3306) connections from anywhere.
//User needs to select appropriate variables form "tfvars" file when launching the instance.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
  # secret_key = ""
  # access_key = ""
}

locals {
  user = "yasar" # Change this to your username
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "nodes" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "${count.index == 0 ? var.control-node-type : var.worker-node-type}"
  count = var.num
  key_name = var.mykey
  vpc_security_group_ids = [aws_security_group.tf-sec-gr.id]
  tags = {
    Name = "${element(var.tags, count.index)}-${local.user}"
  }
}

resource "aws_security_group" "tf-sec-gr" {
  name = "ansible-session04-sec-gr-${local.user}"
  tags = {
    Name = "ansible-session04-sec-gr-${local.user}"
  }

  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3306
    protocol    = "tcp"
    to_port     = 3306
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    protocol    = -1
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "null_resource" "config" {
  depends_on = [aws_instance.nodes[0]]
  connection {
    host = aws_instance.nodes[0].public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file("~/.ssh/${var.mykey}.pem") # Do not forget to define your key file path correctly!
  }

  provisioner "file" {
    source = "./ansible.cfg"
    destination = "/home/ubuntu/.ansible.cfg"
  }

  provisioner "file" {
    source = "~/.ssh/${var.mykey}.pem"  # Do not forget to define your key file path correctly!
    destination = "/home/ubuntu/${var.mykey}.pem"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname Control-Node",
      "sudo apt update -y",
      "sudo apt install ansible -y",
      "echo [servers] >> inventory.ini",
      "echo db_server ansible_host=${aws_instance.nodes[1].private_ip} ansible_ssh_private_key_file=/home/ubuntu/${var.mykey}.pem ansible_user=ubuntu >> inventory.ini",
      "echo web_server ansible_host=${aws_instance.nodes[2].private_ip} ansible_ssh_private_key_file=/home/ubuntu/${var.mykey}.pem ansible_user=ubuntu >> inventory.ini",
      "chmod 400 ${var.mykey}.pem"
    ]
  }
}

output "controlnodeip" {
  value = aws_instance.nodes[0].public_ip
}

