
# 🧪 Hands-on: Terraform ile VPC Modülü Oluşturma

Bu doküman, AWS üzerinde Terraform kullanarak özelleştirilmiş bir VPC altyapısı oluşturmak için hazırlanan `terraform-aws-vpc` modülünün detaylı kurulum adımlarını içermektedir.

---

## 📁 Klasör Yapısı


```bash
mkdir -p ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/project
cd ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/project

mkdir -p modules/terraform-aws-vpc/
```

```bash
modules/
└── terraform-aws-vpc/
    ├── data.tf
    ├── main.tf
    ├── nacl.tf
    ├── nat.tf
    ├── outputs.tf
    ├── route.tf
    ├── subnets.tf
    └── variables.tf
```

---

## 🧾 Her Dosyanın Oluşturulması

### 📝 main.tf
```bash
touch main.tf
```

```hcl
##### Create VPC
resource "aws_vpc" "main" {
  cidr_block                        = var.cidr_block
  enable_dns_support                = true
  enable_dns_hostnames              = true
  assign_generated_ipv6_cidr_block  = false

  tags = {
    Name        = "${var.tenant}-${var.name}-vpc-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id        = aws_vpc.main.id

  tags = {
    Name        = "${var.tenant}-${var.name}-igw-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}
```

---
### 📝 subnets.tf
```bash
touch subnets.tf
```

```hcl
##### Create Public Subnets
resource "aws_subnet" "main_pbl" {
  count                   = length(var.pbl_sub_count)
  cidr_block              = lookup(var.pbl_sub_count[count.index], "cidr")
  availability_zone       = "${data.aws_region.current.name}${lookup(var.pbl_sub_count[count.index], "zone")}"
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.tenant}-${var.name}-snet-pbl-${lookup(var.pbl_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create Private Subnets
resource "aws_subnet" "main_pvt" {
  count                   = length(var.pvt_sub_count)
  cidr_block              = lookup(var.pvt_sub_count[count.index], "cidr")
  availability_zone       = "${data.aws_region.current.name}${lookup(var.pvt_sub_count[count.index], "zone")}"
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.tenant}-${var.name}-snet-pvt-${lookup(var.pvt_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create EKS Subnets
resource "aws_subnet" "main_eks" {
  count                   = length(var.eks_sub_count)
  cidr_block              = lookup(var.eks_sub_count[count.index], "cidr")
  availability_zone       = "${data.aws_region.current.name}${lookup(var.eks_sub_count[count.index], "zone")}"
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.tenant}-${var.name}-snet-eks-${lookup(var.eks_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create DB Subnets
resource "aws_subnet" "main_db" {
  count                   = length(var.db_sub_count)
  cidr_block              = lookup(var.db_sub_count[count.index], "cidr")
  availability_zone       = "${data.aws_region.current.name}${lookup(var.db_sub_count[count.index], "zone")}"
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.tenant}-${var.name}-snet-db-${lookup(var.db_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create LAMBDA Subnets
resource "aws_subnet" "main_lambda" {
  count                   = length(var.lambda_sub_count)
  cidr_block              = lookup(var.lambda_sub_count[count.index], "cidr")
  availability_zone       = "${data.aws_region.current.name}${lookup(var.lambda_sub_count[count.index], "zone")}"
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.tenant}-${var.name}-snet-lambda-${lookup(var.lambda_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

```

---
### 📝 route.tf
```bash
touch route.tf
```

```hcl
##### Adopt Private Route Table (Default/Main)
resource "aws_default_route_table" "main_default" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  tags = {
    Name        = "${var.tenant}-${var.name}-default-route-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create Public Route Table
resource "aws_route_table" "main_pbl" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-pbl-route-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create Private Route Table
resource "aws_route_table" "main_pvt" {
  count  = (length(var.pvt_sub_count) > 0) ? local.nat_count : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-pvt-route-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create EKS Route Table
resource "aws_route_table" "main_eks" {
  count  = (length(var.eks_sub_count) > 0) ? local.nat_count : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-eks-route-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create DB Route Table
resource "aws_route_table" "main_db" {
  count  = (length(var.db_sub_count) > 0) ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-db-route-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create Lambda Route Table
resource "aws_route_table" "main_lambda" {
  count  = (length(var.lambda_sub_count) > 0) ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.main.*.id, count.index)
  }

  lifecycle {
    ignore_changes = [route]
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-lambda-route-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Route Table Association for Public Subnets
resource "aws_route_table_association" "main_pbl_route_association" {
  count          = length(var.pbl_sub_count)
  subnet_id      = element(aws_subnet.main_pbl.*.id, count.index)
  route_table_id = aws_route_table.main_pbl.id
}

##### Route Table Association for Private Subnets
resource "aws_route_table_association" "main_pvt_route_association" {
  count          = length(var.pvt_sub_count)
  subnet_id      = element(aws_subnet.main_pvt.*.id, count.index)
  route_table_id = element(aws_route_table.main_pvt.*.id, count.index)
}

##### Route Table Association for EKS Subnets
resource "aws_route_table_association" "main_eks_route_association" {
  count          = length(var.eks_sub_count)
  subnet_id      = element(aws_subnet.main_eks.*.id, count.index)
  route_table_id = element(aws_route_table.main_eks.*.id, count.index)
}

##### Route Table Association for DB Subnets
resource "aws_route_table_association" "main_db_route_association" {
  count          = length(var.db_sub_count)
  subnet_id      = element(aws_subnet.main_db.*.id, count.index)
  route_table_id = aws_route_table.main_db[0].id
}

##### Route Table Association for Lambda Subnets
resource "aws_route_table_association" "main_lambda_route_association" {
  count          = length(var.lambda_sub_count)
  subnet_id      = element(aws_subnet.main_lambda.*.id, count.index)
  route_table_id = element(aws_route_table.main_lambda.*.id, count.index)
}
```

---
### 📝 nat.tf
```bash
touch nat.tf
```

```hcl
##### Create NAT IPs
resource "aws_eip" "nat_gateway" {
  count      = (lookup(var.pbl_sub_count[0], "eip") == "") ? local.nat_count : 0
  #vpc        = true
  depends_on = [aws_internet_gateway.main]

  lifecycle {
    prevent_destroy = false # test den sonra true yap
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-natgw-eip-${lookup(var.pbl_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Use existing NAT IPs
data "aws_eip" "nat_gateway" {
  count = (lookup(var.pbl_sub_count[0], "eip") == "") ? 0 : local.nat_count
  id    = lookup(var.pbl_sub_count[count.index], "eip")
}

##### Create NAT Gateway
resource "aws_nat_gateway" "main" {
  count         = local.nat_count
  allocation_id = (lookup(var.pbl_sub_count[0], "eip") == "") ? element(aws_eip.nat_gateway.*.id, count.index) : element(data.aws_eip.nat_gateway.*.id, count.index)
  subnet_id     = element(aws_subnet.main_pbl.*.id, count.index)
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name        = "${var.tenant}-${var.name}-natgw-pbl-${lookup(var.pbl_sub_count[count.index], "zone")}-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}
```

---
### 📝 nacl.tf
```bash
touch nacl.tf
```

```hcl
##### Create Public Access Control List
resource "aws_network_acl" "main_pbl" {
  vpc_id       = aws_vpc.main.id
  subnet_ids   = aws_subnet.main_pbl.*.id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-pbl-acl-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create Private Access Control List
resource "aws_network_acl" "main_pvt" {
  count        = length(var.pvt_sub_count) > 0 ? 1 : 0
  vpc_id       = aws_vpc.main.id
  subnet_ids   = aws_subnet.main_pvt.*.id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-pvt-acl-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create EKS Access Control List
resource "aws_network_acl" "main_eks" {
  count        = length(var.eks_sub_count) > 0 ? 1 : 0
  vpc_id       = aws_vpc.main.id
  subnet_ids   = aws_subnet.main_eks.*.id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-eks-acl-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create DB Access Control List
resource "aws_network_acl" "main_db" {
  count        = length(var.db_sub_count) > 0 ? 1 : 0
  vpc_id       = aws_vpc.main.id
  subnet_ids   = aws_subnet.main_db.*.id

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-db-acl-${var.environment}"
    Tenant      = var.tenant
    Project     = var.name
    Environment = var.environment
    Maintainer  = "yonetimacademy"
    Terraform   = "yes"
  }
}

##### Create Lambda Access Control List
resource "aws_network_acl" "main_lambda" {
  count        = length(var.lambda_sub_count) > 0 ? 1 : 0
  vpc_id       = aws_vpc.main.id
  subnet_ids   = aws_subnet.main_lambda.*.id
  
  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

    ingress {
    protocol   = -1
    rule_no    = 300
    action     = "allow"
    cidr_block = "10.0.0.0/8"
    from_port  = 0
    to_port    = 0
  }

    ingress {
    protocol   = -1
    rule_no    = 400
    action     = "allow"
    cidr_block = "172.31.0.0/16"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name        = "${var.tenant}-${var.name}-lambda-acl-${var.environment}"
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
data "aws_region" "current" {}

locals {
  nat_count = (
    (length(var.pbl_sub_count) > 0 && var.single_az_nat == true) ? 1 : false ||
    (length(var.pbl_sub_count) > 0 && var.single_az_nat == false) ? length(var.pbl_sub_count) : false ||
    (length(var.pbl_sub_count) == 0) ? 0 : 0
  )
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
variable "cidr_block" {}
variable "single_az_nat" {}
variable "pbl_sub_count" {}
variable "pvt_sub_count" {}
variable "eks_sub_count" {}
variable "db_sub_count" {}
variable "lambda_sub_count" {}

```

---
### 📝 outputs.tf
```bash
touch outputs.tf
```

```hcl
output "vpc_id" {
	value = aws_vpc.main.id
}

output "cidr_block" {
	value = aws_vpc.main.cidr_block
}

output "pbl_subnet_ids" {
	value = aws_subnet.main_pbl.*.id
}

output "pvt_subnet_ids" {
	value = aws_subnet.main_pvt.*.id
}

output "eks_subnet_ids" {
	value = aws_subnet.main_eks.*.id
}

output "db_subnet_ids" {
	value = aws_subnet.main_db.*.id
}

output "lambda_subnet_ids" {
	value = aws_subnet.main_lambda.*.id
}

#######################

output "pbl_route_table_ids" {
  value       = aws_route_table.main_pbl.*.id
}

output "pvt_route_table_ids" {
  value       = aws_route_table.main_pvt.*.id
}

######################
output "db_route_table_ids" {
  value       = aws_route_table.main_db.*.id
}
```


---

## ✅ Kullanım Örneği

Bu modül bir tenant klasöründe şu şekilde çağrılabilir:

```hcl
module "vpc" {
  source       = "../../modules/terraform-aws-vpc"
  name         = "network"
  environment  = "dev"
  cidr_block   = "10.0.0.0/16"
}
```
