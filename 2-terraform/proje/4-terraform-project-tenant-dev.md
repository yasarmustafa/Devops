
# 🧪 Hands-on: Terraform `tenant/dev` Ortam Ana Yapılandırması

Bu doküman, `tenant/dev/` dizinindeki ana Terraform yapılandırmalarını açıklar. Bu dizin, alt dizinlerdeki modüllerin (`core/`, `network/`, `apps/`, vb.) yürütülmesini koordine eder.

---

## 📁 Klasör Yapısı
```bash
mkdir -p ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/project
cd ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/project

cd tenant/dev/
```

```bash
tenant/
└── dev/
    ├── main.tf
    ├── providers.tf
    └── core/
```

---

## 🎯 Amaç

- AWS Provider yapılandırmasını yönetmek
- Alt modülleri `main.tf` üzerinden çağırmak
- Ortam seviyesinde Terraform yönetimini kolaylaştırmak

---

## 🧾 Her Dosyanın Oluşturulması

### 📝 providers.tf
```bash
touch providers.tf
```

```hcl
##### Define Terraform State Backend and Must Providers
terraform {
  backend "s3" {
    bucket  = "bucker_name"
    key     = "dev/infrastructure.tfstate"
    profile = "default"
    region  = "eu-west-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.24.0"
    }
  }
}

##### Give Provider Credentials
provider "aws" {
  profile = "default"
  region  = "eu-west-1"
}

```

---
### 📝 main.tf
```bash
touch main.tf
```

```hcl
##### Parameters to forward for Core deployment
module "core" {
  source      = "./core"
  tenant      = "bootcamp"
  name        = "my-project"
  environment = "dev"
}

```


---

## ✅ Uygulama

Terraform işlemlerini doğrudan bu klasörde aşağıdaki şekilde başlatabilirsin:


```bash
terraform -chdir=tenant/dev/ init

terraform -chdir=tenant/dev/ init -target=module.core.module.core_vpc
terraform -chdir=tenant/dev/ apply -target=module.core.module.core_vpc

terraform -chdir=tenant/dev/ apply -target=module.core.module.ec2-instance-bootcamp
```

> Bu yapı, ortam geneli için merkezi kontrol sağlar ve tüm alt modüller (örneğin `core/`) bu seviyeden çalıştırılır.

