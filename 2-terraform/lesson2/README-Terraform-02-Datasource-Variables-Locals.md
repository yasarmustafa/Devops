# Hands-on Terraform-02 : Terraform Datasource, Locals,  Variables, Output:

Bu Hands-on çalışmasında terraform Datasourcei locals, variables ile değişken değeri atama ve output bloğu ile çıktı alma işlemlerini inceleyeceğiz.

## Outline

- Bölüm 1 - Terraform Datasource, Locals 

- Bölüm 2 - Terraform Variables, Output

- Bölüm 3 - Terraform Komutları

## Bölüm 1- Terraform Datasource, Locals

- Terraform’da datasource, mevcut kaynaklardan bilgi çekmenizi sağlar. Bu kaynaklar, Terraform’un oluşturduğu bir resource olabileceği gibi, manuel olarak ya da başka bir araçla oluşturulmuş bir kaynak da olabilir. Datasource’ları kullanarak bu kaynakların özelliklerine erişebilir, bu bilgileri başka kaynakların oluşturulmasında ya da yapılandırılmasında kullanabilirsiniz.

- Bu çalışmada ec2 instance için gerekli olan ami id'yi aws den data bloğu ile alacağız.

### 1a- Datasource Bloğunu kullanmak için Konfigurasyon Dosyasını Oluşturalım

- Çalışma Klasörümüzü oluşturalım

```bash
mkdir -p ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/terraform-02
cd ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/terraform-02
```

- Bu çalışmada ihtiyacımız olan configurasyon dosyalarını(`main.tf`` provider.tf` `data.tf`) boş olarak oluşturalım.

```bash
touch main.tf provider.tf data.tf
```

- `provider.tf` dosyasını oluşturuyoruz.

```t
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  region  = "us-east-1" # çalışılacak olan region ismi
  profile = "default"   # .aws dosyasındaki credentials ların bulunduğu profil ismi
  
  # Configuration options
  # access_key = "my-access-key"
  # secret_key = "my-secret-key"
}

```

- `data.tf` dosyasını oluşturuyoruz. Data.tf dosyası üzerinde biraz daha detaylı duralım. Konsoldan karşılaştıralım. 

```t

data "aws_ami" "latest_ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"] # AMI name
    #values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"] # AMI name
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Ubuntu'nun resmi AMI sahibi ID'si
}

```


- `main.tf` dosyasını oluşturuyoruz.


```t

resource "aws_instance" "main" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name        = "EC2-terraform-ubuntu"
    Environment = "test"
  }
}

```

### Terraform Scriptini Çalıştırıyoruz.

```bash
terraform init
terraform plan
terraform apply --auto-approve
```
### İşlem Tamalandıktan sonra aşağıdaki mesajı görüyoruz.

```bash
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

- ***NOT: Kodu Dışı Ek Bilgi----AMI ismini nereden bulacağız? AWS cli kullanarak varaolan kaynakların isimlerine olaşabiliriz.***
- konsoldan girerek kontrol edebiliriz.
- aws dokumantasyondan bulabiliriz
- aws cli komutlarını kullanarak çekebiliriz. Aşağıda örnek birkaç kod bulunmaktadır.

```bash
aws ec2 describe-images --owners amazon --profile default --region us-east-1 --filters "Name=name,Values=ubuntu*" 
aws ec2 describe-images --owners amazon --profile default --region us-east-1 --query 'Images[*].{ID:ImageId,Name:Name}'
aws ec2 describe-images --owners amazon --profile default --region us-east-1 --query 'Images[*].{ID:ImageId,Name:Name}' | grep ubuntu
aws ec2 describe-images --owners amazon --profile default --region us-east-1 --query 'Images[*].{ID:ImageId,Name:Name}' | grep ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*
```

### 1b- Locals Bloğunu kullanmak için Konfigurasyon Dosyasını Oluşturalım

```bash
touch locals.tf
```

- `locals.tf` dosyasını oluşturuyoruz.

```t

locals {
  Name        = "EC2-terraform"
  environment = "production"
  region      = "us-west-2"
  
}

```

- `main.tf` dosyasını güncelliyoruz.

```t

resource "aws_instance" "main" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = "t2.micro"

  tags = {
    Name        = "${local.Name}-my-local-name" # not string içinde başka bir bloktan veri alma
    Environment = "${local.environment}"              # local bloğundaki environmetn değişkenini kullanmak için local.environment
    #Environment = local.environment        # local bloğundaki environmetn değişkenini kullanmak için local.environment
  }
}

```

### Terraform Scriptini Çalıştırıyoruz.

```bash
terraform apply --auto-approve
terraform destroy
```

## Bölüm 2- Terraform Variables, Output

### 2a- Variables Bloğunu kullanarak Değişken tanımlama ve default değer atama.

```bash
touch variables.tf
```

- `variables.tf` dosyasınıın içeriğini oluşturuyoruz.

```t

variable "ec2_name" {
  default = "EC2-instance-name-from-var"
}

variable "ec2_type" {
  default = "t2.micro"
}

variable "environment" {
  default = "dev"
}

```

- `main.tf` dosyasını variable değerleri için güncelliyoruz.

```t

resource "aws_instance" "main" {
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = var.ec2_type

  tags = {
    Name        = var.ec2_name
    Environment = var.environment
  }
}

```

### Terraform Scriptini Çalıştırıyoruz.

```bash
terraform apply --auto-approve
```

### 2b- Environment variables kullanarak değişken değeri atama

- Terraform çalıştırıldığında öncelikle ortam değişkenlerini kontrol eder. Eğer değişkenler ortam değişkeni olarak tanımlanmışsa değerini oradan çeker.

- Environment Variable aşağıdaki `TF_VAR_` kelimesinin sonuna değişken ismi ve değeri eklenerek tanımlanır.

- aşağıdaki komutlarla varolan değişkenler kontrol edilebilir.

```bash
env
printenv
export TF_VAR_değişken-ismi=değişken-değeri  # ENV değişkenine değer atama
unset TF_VAR_değişken-ismi                   # ENV değişkenin değerini kaldırma
env | grep TF_VAR_*                          # değişkenleri filitreleme
```

```bash
export TF_VAR_ec2_name=my-EC2-instance-form-ENV       
echo "$TF_VAR_ec2_name"                           # atanılan değeri kontrol et

terraform plan

```

### 2c- (terraform.tfvars) (.tfvars) (*.auto.tfvars) kullanarak değişken değişken değeri atama

- Terraform değişken değerleri `terraform.tfvars` dosyası ile de tanımlanabilir. `terraform.tfvars` dosyası `default` değeri ve `Environment variables` ile girilen değerleri ezer.

- `terraform.tfvars` dosyasnı oluşturma

```bash
touch terraform.tfvars
```
- `terraform.tfvars` içeriğini aşağıdaki gibi oluşturuyoruz.

```t

ec2_name    = "my-EC2-instance-terraform.tfvars"
environment = "dev-terraform.tfvars"

```

```bash

terraform plan

```

- Terraform değişken değerleri `*.auto.tfvars` dosyası ile de tanımlanabilir. `*.auto.tfvars` dosyası `default` değeri ve `Environment variables` ile girilen değeri ve `terraform.tfvars` içeriğini ezer.

- `terraform.auto.tfvars` dosyasnı oluşturma

```bash
touch terraform.auto.tfvars
```
- `terraform.auto.tfvars` içeriğini aşağıdaki gibi oluşturuyoruz.

```t

ec2_name    = "my-EC2-instance-terraform.auto.tfvars"
environment = "dev-terraform.auto.tfvars"

```

```bash

terraform plan

```


### 2d- "-var" veya "-var-file" command line kullanarak değişken değeri atama

- Değişken değeri Terraform cli komutuna `-var` veya `-var-file` komutu eklenerek verilebilir. Bu şekilde değişken değeri tanımlanırsa daha önce tanımlanmış olan `default` değeri, `Environment variables` ile girilen değeri, `terraform.tfvars` içeriğini ve `*.auto.tfvars` içeriğini ezer.

-Aynı terraform cli komutu içinde `-var` ve `-var-file` birlikte kullanılırsa sonraki yazılan öncekini ezer. aşağıdaki örnekte `-var-file` ile girilen dosyadaki değerler `-var` ile girilen değeri ezer.

```bash
terraform plan  -var-file="test.tfvars" -var="ec2_name=my-EC2-instance-VAR"
```

- Terraform loads variables in the following order:

  - Any -var and -var-file options on the command line, in the order they are provided.
  - Any *.auto.tfvars or *.auto.tfvars.json files, processed in lexical order of their filenames.
  - The terraform.tfvars.json file, if present.
  - The terraform.tfvars file, if present.
  - Environment variables
  - Default

### 2e- Output Bloğunu kullanmak için Konfigurasyon Dosyasını Oluşturalım

```bash
touch output.tf
```

- `output.tf` dosyasınıın içeriğini oluşturuyoruz.

```t

output "ec2_instance_id" {
  value = aws_instance.main.id
}

output "ec2_instance_public_ip" {
  value = aws_instance.main.public_ip
}

output "ec2_instance_private_ip" {
  value = aws_instance.main.private_ip
}

```

### Terraform Scriptini Çalıştırıyoruz.

```bash
terraform apply --auto-approve
```

### Kaynaklar Oluşduktan sonra state kontrolu yapıyoruz.

- Terraform `terraform state` komutu ileri state yönetimi için kullanılır. Oluşturulan state içerisindeki kaynakların detayını incelemeye yarar. Bu kaynaklar `terraform state list` komuru ile listelenebilir.

```bash
terraform state list
terraform state show state_name # terraform list ile listelediğimiz state' lerin detayını görebilirsiniz.

```
### Destroy

- Oluşturduğumuz tüm kaynakları siliyoruz.

```bash
terraform destroy
```

## Bölüm 3 - Terraform Komutları (BONUS)

```yaml
Main commands:
  init          Prepare your working directory for other commands
  validate      Check whether the configuration is valid
  plan          Show changes required by the current configuration
  apply         Create or update infrastructure
  destroy       Destroy previously-created infrastructure

All other commands:
  console       Try Terraform expressions at an interactive command prompt
  fmt           Reformat your configuration in the standard style
  force-unlock  Release a stuck lock on the current workspace
  get           Install or upgrade remote Terraform modules
  graph         Generate a Graphviz graph of the steps in an operation
  import        Associate existing infrastructure with a Terraform resource
  login         Obtain and save credentials for a remote host
  logout        Remove locally-stored credentials for a remote host
  metadata      Metadata related commands
  modules       Show all declared modules in a working directory
  output        Show output values from your root module
  providers     Show the providers required for this configuration
  refresh       Update the state to match remote systems
  show          Show the current state or a saved plan
  state         Advanced state management
  taint         Mark a resource instance as not fully functional
  test          Execute integration tests for Terraform modules
  untaint       Remove the 'tainted' state from a resource instance
  version       Show the current Terraform version
  workspace     Workspace management

Global options (use these before the subcommand, if any):
  -chdir=DIR    Switch to a different working directory before executing the given subcommand.
  -help         Show this help output, or the help for a specified subcommand.
  -version      An alias for the "version" subcommand.

```


# 🛠️ Terraform CLI Komutları: Kapsamlı Hands-on Rehber

Bu belge, Terraform CLI komutlarının tümünü **açıklamalar**, **örnek komutlar** ve **senaryo bazlı kullanımlar** ile detaylı bir şekilde anlatmaktadır.

---

## ✅ `terraform console`

- terraform console komutu, Terraform çalışma dizinindeki mevcut konfigürasyona ve state dosyasına erişerek ifade (expression) testi yapmanı, değişkenleri incelemeni, ve resource değerlerini sorgulamanı sağlayan etkileşimli bir CLI ortamıdır.

Kısaca: Terraform kodlarını "debug" etmek veya state içindeki kaynakları incelemek için kullanılır.

### 📌 Kullanımı:
```bash
terraform console
```

### 🧪 Örnekler:

```bash
> 1 + 2
3

> upper("devops")
"DEVOPS"

> aws_instance.main.instance_type
"t2.micro"

> aws_instance.main.public_ip
"i-0123456789abcdef0"

> aws_instance.main.ami
"ami-0a7620d611d3ceae4"

> aws_instance.main # bu komut girilirse aşağıdaki json elde edilir. aradan filitreleme yapılarak state instenilen değer çekilir.
"ami-0a7620d611d3ceae4"

{
  "ami" = "ami-0a7620d611d3ceae4"
  "arn" = "arn:aws:ec2:us-east-1:444876369282:instance/i-0c6f92390a3972c2d"
  "associate_public_ip_address" = true
  "availability_zone" = "us-east-1d"
  "capacity_reservation_specification" = tolist([
    {
      "capacity_reservation_preference" = "open"
      "capacity_reservation_target" = tolist([])
    },
  ])
  "cpu_core_count" = 1
  "cpu_options" = tolist([
    {
      "amd_sev_snp" = ""
      "core_count" = 1
      "threads_per_core" = 1
    },
  ])
  "cpu_threads_per_core" = 1
  "credit_specification" = tolist([
    {
      "cpu_credits" = "standard"
    },
  ])
  "disable_api_stop" = false
  "disable_api_termination" = false
  "ebs_block_device" = toset([])
  "ebs_optimized" = false
  "enable_primary_ipv6" = tobool(null)
  "enclave_options" = tolist([
    {
      "enabled" = false
    },
  ])
  "ephemeral_block_device" = toset([])
  "get_password_data" = false
  "hibernation" = false
  "host_id" = ""
  "host_resource_group_arn" = tostring(null)
  "iam_instance_profile" = ""
  "id" = "i-0c6f92390a3972c2d"
  "instance_initiated_shutdown_behavior" = "stop"
  "instance_lifecycle" = ""
  "instance_market_options" = tolist([])
  "instance_state" = "running"
  "instance_type" = "t2.micro"
  "ipv6_address_count" = 0
  "ipv6_addresses" = tolist([])
  "key_name" = ""
  "launch_template" = tolist([])
  "maintenance_options" = tolist([
    {
      "auto_recovery" = "default"
    },
  ])
  "metadata_options" = tolist([
    {
      "http_endpoint" = "enabled"
      "http_protocol_ipv6" = "disabled"
      "http_put_response_hop_limit" = 2
      "http_tokens" = "required"
      "instance_metadata_tags" = "disabled"
    },
  ])
  "monitoring" = false
  "network_interface" = toset([])
  "outpost_arn" = ""
  "password_data" = ""
  "placement_group" = ""
  "placement_partition_number" = 0
  "primary_network_interface_id" = "eni-02ac6d4b8eca0d858"
  "private_dns" = "ip-172-31-85-72.ec2.internal"
  "private_dns_name_options" = tolist([
    {
      "enable_resource_name_dns_a_record" = false
      "enable_resource_name_dns_aaaa_record" = false
      "hostname_type" = "ip-name"
    },
  ])
  "private_ip" = "172.31.85.72"
  "public_dns" = "ec2-52-90-51-218.compute-1.amazonaws.com"
  "public_ip" = "52.90.51.218"
  "root_block_device" = tolist([
    {
      "delete_on_termination" = true
      "device_name" = "/dev/sda1"
      "encrypted" = false
      "iops" = 3000
      "kms_key_id" = ""
      "tags" = tomap({})
      "tags_all" = tomap({})
      "throughput" = 125
      "volume_id" = "vol-0f501d04cf56779aa"
      "volume_size" = 8
      "volume_type" = "gp3"
    },
  ])
  "secondary_private_ips" = toset([])
  "security_groups" = toset([
    "default",
  ])
  "source_dest_check" = true
  "spot_instance_request_id" = ""
  "subnet_id" = "subnet-0f08e1bdbdebc6448"
  "tags" = tomap({
    "Environment" = "dev"
    "Name" = "my-EC2-instance"
  })
  "tags_all" = tomap({
    "Environment" = "dev"
    "Name" = "my-EC2-instance"
  })
  "tenancy" = "default"
  "timeouts" = null /* object */
  "user_data" = tostring(null)
  "user_data_base64" = tostring(null)
  "user_data_replace_on_change" = false
  "volume_tags" = tomap(null) /* of string */
  "vpc_security_group_ids" = toset([
    "sg-0f054e73156e8c432",
  ])
}
```

### 🎯 Ne zaman kullanılır?
- Değişken veya output değerlerini test etmek
- Map, list, string fonksiyonlarını denemek
- Resource'ların state değerlerine bakmak

---



## 🎨 `terraform fmt`

Terraform dosyalarını HashiCorp'un önerdiği biçimde otomatik olarak düzenler.

### 📌 Kullanımı:
```bash
terraform fmt
terraform fmt -recursive  # Alt dizinlerdeki tf dosyalarını da düzenler
```

---

## 🔓 `terraform force-unlock`

Sıkışmış (stuck) bir state lock kilidini kaldırır.

### 📌 Kullanımı:
```bash
terraform force-unlock 12345678-aaaa-bbbb-cccc-ddddeeeeffff
```

---

## 📦 `terraform get`

Module bloklarında tanımlanan harici kaynakları indirir veya günceller.

### 📌 Kullanımı:
```bash
terraform get
```

---

## 📊 `terraform graph`

Terraform konfigürasyonundaki bağımlılıkları `.dot` formatında grafik olarak verir.

### 📌 Kullanımı:
```bash

sudo apt install graphviz # linux ubuntu
brew install graphviz # macos

terraform graph > graph.dot
dot -Tpng graph.dot -o graph.png
```

---

## 🔁 `terraform import`

Mevcut bir altyapı kaynağını Terraform yönetimine alır.

### 📌 Kullanımı:
```bash
terraform import aws_instance.example i-1234567890abcdef0
```

> Not: `main.tf` içinde aws_instance tanımı önceden yapılmalıdır.

---

## 🔐 `terraform login`

Terraform Cloud ya da özel backend sistemlerine giriş yapılmasını sağlar.

### 📌 Kullanımı:
```bash
terraform login
```

---

## 🚪 `terraform logout`

Giriş bilgilerini silerek oturumu kapatır.

```bash
terraform logout
```


## 📚 `terraform modules`

Çalışma dizininde tanımlı tüm modülleri listeler.

```bash
terraform modules
```

---

## 📤 `terraform output`

Terraform'da output olarak tanımlanmış değerleri gösterir.

```bash
terraform output
terraform output instance_ip
```

---

## 🌐 `terraform providers`

Kullanılan provider’ları ve versiyonlarını gösterir.

```bash
terraform providers
```

---

## 🔄 `terraform refresh`

Remote sistemlerle durumu karşılaştırarak state dosyasını günceller. Altyapıda yapılan manuel değişiklikleri tanır.

```bash
terraform refresh
```

---

## 🔍 `terraform show`

State veya plan dosyasını okunabilir biçimde gösterir.

```bash
terraform show
terraform show plan.out
```

---

## 📦 `terraform state`

State dosyası üzerinde ileri seviye işlemler yapar.

### 📌 Kullanımı:
```bash
terraform state list
terraform state show aws_instance.main
terraform state rm aws_instance.main # varolan state siler
```

---

## ⚠️ `terraform taint`

Bir kaynağı bozuk (tainted) olarak işaretler, bir sonraki `apply` sırasında yeniden oluşturulur.

```bash
terraform taint aws_instance.web
```

---

## ✅ `terraform test`

Terraform modülleri için otomasyon testleri çalıştırır. (Terraform >= 1.6)

```bash
terraform test
```

---

## ♻️ `terraform untaint`

Tainted olarak işaretlenmiş kaynağın durumunu kaldırır.

```bash
terraform untaint aws_instance.web
```

---

## 🔢 `terraform version`

Yüklü olan Terraform sürümünü gösterir.

```bash
terraform version
```

---

## 🧪 `terraform workspace`

Ortamları izole etmek için kullanılır. Her workspace kendi state dosyasına sahiptir.

### 📌 Kullanımı:
```bash
terraform workspace list
terraform workspace new staging
terraform workspace select staging
```

---

## 🌍 Global Seçenekler

### 🔄 `-chdir=DIR`

Komutu belirtilen dizinde çalıştırır.

```bash
terraform -chdir=modules/network apply
```

### 🆘 `-help`

Yardım ekranını veya alt komutların yardım metnini gösterir.

```bash
terraform -help
terraform destroy -help
```

### 🔢 `-version`

Terraform sürüm bilgisini verir.

```bash
terraform -version
```

---

Bu doküman Terraform CLI komutlarının detaylı bir referansıdır. Her komut gerçek dünya senaryoları ile desteklenmiş, açıklayıcı ve öğretici olacak şekilde hazırlanmıştır. Öğrendiklerinizi uygulayarak pekiştirmeniz önerilir.