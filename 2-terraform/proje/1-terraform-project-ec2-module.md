
# 🧪 Hands-on: Terraform ile EC2 Modülü Oluşturma

Bu doküman, AWS üzerinde Terraform kullanarak bir EC2 altyapısını modüler yapıda oluşturmak için tasarlanmış `terraform-aws-ec2` modülünün detaylı kurulumunu içerir.

---

## 📁 Klasör Yapısı

```bash
mkdir -p ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/project
cd ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/project

mkdir -p modules/terraform-aws-ec2/
```

```bash
modules/
└── terraform-aws-ec2/
    ├── data.tf
    ├── eip.tf
    ├── iam.tf
    ├── main.tf
    ├── sg.tf
    ├── ssm.tf
    └── variables.tf
```

---

## 🧾 Her Dosyanın Oluşturulması

### 📝 main.tf
```bash
touch main.tf
```

```hcl
resource "aws_instance" "main" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  associate_public_ip_address = var.associate_public_ip_address
  subnet_id                   = random_shuffle.zone.result[0]
  vpc_security_group_ids      = [aws_security_group.main.id]
  monitoring                  = var.detailed_monitoring
  disable_api_stop            = var.stop_protection
  disable_api_termination     = var.termination_protection
  source_dest_check           = var.source_dest_check
  iam_instance_profile        = length(var.instance_profile) == 0 ? null : aws_iam_instance_profile.main.name
  key_name                    = var.key_name
  user_data                   = (var.user_data) != null ? var.user_data : null
  tenancy                     = "default"

  credit_specification {
    cpu_credits = "unlimited"
  }

  maintenance_options {
    auto_recovery = "default"
  }

  root_block_device {
    delete_on_termination = var.delete_volumes_on_termination
    encrypted             = (var.encryption == true) ? true : false
    kms_key_id            = (var.encryption == true) ? var.kms_key_id : null
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    throughput            = var.root_throughput
    iops                  = var.root_iops

    tags = {
      Name        = "${var.tenant}-${var.name}-ec2-${var.ec2_name}-root-volume-${var.environment}"
      Tenant      = var.tenant
      Project     = var.name
      Environment = var.environment
      Maintainer  = "yonetimacademy"
      Terraform   = "yes"
    }
  }

  ebs_block_device {
    delete_on_termination = var.delete_volumes_on_termination
    encrypted             = (var.encryption == true) ? true : false
    kms_key_id            = (var.encryption == true) ? var.kms_key_id : null
    device_name           = "/dev/${var.ebs_device_name}"
    volume_type           = var.ebs_volume_type
    volume_size           = var.ebs_volume_size
    throughput            = var.ebs_throughput
    iops                  = var.ebs_iops

    tags = {
      #Name        = "${var.tenant}-${var.name}-ec2-${var.ec2_name}-${var.ebs_device_name}-volume-${var.environment}"
      Name        = "${var.tenant}-${var.name}-ec2-${var.ec2_name}-ebs-volume-${var.environment}"
      Tenant      = var.tenant
      Project     = var.name
      Environment = var.environment
      Maintainer  = "yonetimacademy"
      Terraform   = "yes"
    }
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-ec2-${var.ec2_name}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

resource "aws_iam_instance_profile" "main" {
  name = "${var.tenant}-${var.name}-ec2-${var.ec2_name}-${var.environment}"
  role =  aws_iam_role.main.name
}

```

---
### 📝 sg.tf
```bash
touch sg.tf
```

```hcl
resource "aws_security_group" "main" {
  name        = "${var.tenant}-${var.name}-ec2-${var.ec2_name}-sg-${var.environment}"
  description = "Managed by yonetimacademy"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress

    content {
      protocol    = ingress.value.protocol
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      description = lookup(ingress.value, "description", null)
      cidr_blocks = [ingress.value.cidr_blocks]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-ec2-${var.ec2_name}-sg-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

```

---
### 📝 eip.tf
```bash
touch eip.tf
```

```hcl
##### Create EC2 IPs
resource "aws_eip" "main" {
  count      = (var.create_eip == true) ? 1 : 0
  instance   = aws_instance.main.id 
  #vpc        = true

  lifecycle {
    prevent_destroy = false # testden sonra true yap
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.ec2_name}-eip-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}
```

---
### 📝 iam.tf
```bash
touch iam.tf
```

```hcl
##### Create IAM Role
resource "aws_iam_role" "main" {
  name = "${var.tenant}-${var.name}-${var.ec2_name}-ec2-iam-role-${var.environment}"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.ec2_name}-ec2-iam-role-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

resource "aws_iam_role_policy_attachment" "main" {
  count      = length(var.instance_profile) == 0 ? 0 : length(var.instance_profile)
  policy_arn = "arn:aws:iam::aws:policy/${var.instance_profile[count.index]}"
  role       = aws_iam_role.main.name
}
```

---
### 📝 ssm.tf
```bash
touch ssm.tf
```

```hcl
resource "aws_ssm_parameter" "main_instance_id" {
  name        = "/${var.tenant}/${var.name}/${var.environment}/ec2/${var.ec2_name}/id"
  description = "Managed by yonetimacademy"
  type        = "SecureString"
  value       = aws_instance.main.id

  tags = {
    Name        = "${var.tenant}-${var.name}-${var.environment}-ec2-${var.ec2_name}-id"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}
```

---
### 📝 data.tf
```bash
touch data.tf
```

```hcl
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "random_shuffle" "zone" {
  input        = var.subnet_ids
  result_count = 1
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
variable "vpc_id" {}
variable "cidr_block" {}
variable "subnet_ids" {}
variable "ec2_name" {}
variable "ami_id" {}
variable "instance_type" {}
variable "associate_public_ip_address" {}
variable "create_eip" {}
variable "detailed_monitoring" {}
variable "stop_protection" {}
variable "termination_protection" {}
variable "source_dest_check" {}
variable "instance_profile" {}
variable "key_name" {}
variable "user_data" {}
variable "delete_volumes_on_termination" {}
variable "encryption" {}
variable "kms_key_id" {}
variable "root_volume_type" {}
variable "root_volume_size" {}
variable "root_throughput" {}
variable "root_iops" {}
variable "ebs_device_name" {}
variable "ebs_volume_type" {}
variable "ebs_volume_size" {}
variable "ebs_throughput" {}
variable "ebs_iops" {}
variable "ingress" {}
```


---

## ✅ Uygulama

Bu modül, tenant dizinlerinde aşağıdaki gibi çağrılabilir:

```hcl
module "ec2" {
  source       = "../../modules/terraform-aws-ec2"
  instance_type = "t3.micro"
  ec2_name      = "web-server"
}
```
