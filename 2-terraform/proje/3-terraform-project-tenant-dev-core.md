
# 🧪 Hands-on: Terraform `tenant/dev/core` Ortamının Oluşturulması

Bu doküman, `terraform-aws-vpc` ve `terraform-aws-ec2` modüllerini çağıran `tenant/dev/core` dizin yapısını açıklar. Bu yapı, tek bir ortam (örneğin `dev`) için temel altyapı bileşenlerini devreye alır.

---

## 📁 Klasör Yapısı

```bash
mkdir -p ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/project
cd ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/project

mkdir -p tenant/dev/core
cd tenant/dev/core
```

```bash
tenant/
└── dev/
    └── core/
        ├── ec2.tf
        ├── vpc.tf
        └── variables.tf
```

---

## 🧾 Her Dosyanın Oluşturulması

### 📝 vpc.tf
```bash
touch vpc.tf
```

```hcl
module "core_vpc" {

  source      = "../../../modules/terraform-aws-vpc"
  tenant      = var.tenant
  name        = var.name
  environment = var.environment

  # VPC Configuration
  cidr_block    = "10.10.0.0/16"
  single_az_nat = true # testden sonra false yalp
  pbl_sub_count = [
    { cidr = "10.10.1.0/24", zone = "a", eip = "" }

  ]
  pvt_sub_count = [
    { cidr = "10.10.2.0/24", zone = "a" }
  ]
  eks_sub_count = []
  db_sub_count = [
    { cidr = "10.10.3.0/24", zone = "a" }
  ]
  lambda_sub_count = []
}

```

---
### 📝 ec2.tf
```bash
touch ec2.tf
```

```hcl
module "ec2-instance-bootcamp" {
  source      = "../../../modules/terraform-aws-ec2"
  tenant      = var.tenant
  name        = var.name
  environment = var.environment
  vpc_id      = module.core_vpc.vpc_id //core-core_vpc
  cidr_block  = module.core_vpc.cidr_block
  subnet_ids  = module.core_vpc.pbl_subnet_ids

  ##### EC2 Configuration
  ec2_name                    = var.name
  ami_id                      = "ami-0554aa6767e249943" # amazon linux-2 ami us-east-1
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  create_eip                  = false # you must have an internet gateway attached | otherwise, boom!//?
  detailed_monitoring         = false
  stop_protection             = false
  termination_protection      = false
  source_dest_check           = true
  instance_profile            = [] # "IAM role" varsa "Permissions policies" Poicy name liste olarak girilecek yoksa [],
  key_name                    = "keypair_name"                       # can be null
  user_data                   = file("${path.module}/userdata.sh")    # can be false

  ##### EBS Configuration
  encryption                    = true
  kms_key_id                    = null
  delete_volumes_on_termination = true

  # Root Volume Configuration
  root_volume_type = "gp2" # can be null
  root_volume_size = 8     # can be null
  root_throughput  = null  # can be null
  root_iops        = null  # can be null

  # Additional Volume Configuration (only one)
  ebs_device_name = "xvda"
  ebs_volume_type = null # can be null
  ebs_volume_size = null # can be null
  ebs_throughput  = null # can be null
  ebs_iops        = null # can be null

  # Security Group Configuration
  ingress = [
    {
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      description = "Listen ssh from home"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      protocol    = "tcp"
      from_port   = 8080
      to_port     = 8080
      description = "Custom TCP"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

```

---
### 📝 variables.tf
```bash
touch variables.tf
```

```hcl
variable "tenant" {}
variable "name" {}
variable "environment" {}
```

### 📝 userdata.sh
```bash
touch userdata.sh
```

```bash
#!/bin/bash

# Update OS
yum update -y

# Set hostname
hostnamectl set-hostname jenkins-server

# Install dependencies
yum install -y git java-17-amazon-corretto wget python3-pip unzip docker bash-completion

# Enable and start Docker
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user
usermod -aG docker jenkins || true

# Jenkins repo
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat/jenkins.io-2023.key

# Install Jenkins
yum install -y jenkins
systemctl enable jenkins
systemctl start jenkins

# Docker Compose
curl -SL https://github.com/docker/compose/releases/download/v2.29.4/docker-compose-linux-x86_64 -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Install Ansible and Boto3
pip3 install ansible boto3 botocore

# Apply git-aware colored PS1 to ec2-user
cat << 'EOF' >> /home/ec2-user/.bashrc
parse_git_branch() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  git symbolic-ref --short HEAD 2>/dev/null | awk '{print " (" $1 ")"}'
}
export PS1="\[\e[34m\]\u\[\e[32m\]@\h \[\e[33m\]\W\[\e[36m\]\$(parse_git_branch)\[\e[0m\]\$ "
EOF

# Ensure .bashrc is sourced on login
grep -q 'source ~/.bashrc' /home/ec2-user/.bash_profile || echo 'if [ -f ~/.bashrc ]; then . ~/.bashrc; fi' >> /home/ec2-user/.bash_profile

# Set permissions
chown ec2-user:ec2-user /home/ec2-user/.bashrc /home/ec2-user/.bash_profile


```
---

## ✅ Uygulama

Bu dizinde aşağıdaki komutlar ile çalışmayı başlatabilirsin:

```bash
terraform init
terraform plan
terraform apply
```

> Bu yapılandırma ile hem VPC hem de EC2 kaynakları oluşturulur. Ortam etiketleme, adlandırma kuralları ve parametre geçişleri modüller üzerinden yapılır.
