# Hands-on Terraform-03 : Terraform Commands, Loops, Conditionals:

Bu Hands-on çalışmasında terraform conditions, şart ve döngüleri inceleyeceğiz.

## Outline

- Bölüm 1 - Conditionals and Loops

- Bölüm 2 - Terraform Fuctions-yeni handson


## Bölüm 1- Terraform Conditionals and Loops

- Çalışma Klasörümüzü oluşturalım

```bash
mkdir -p ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/terraform-03
cd ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/terraform-03
```
- Hands-on çalışması için yeni gerekli konfigürasyon dosyalarını oluşturalım.

```bash
touch main.tf provider.tf variables.tf output.tf
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

- `main.tf` dosyasının içeriğini oluşturuyoruz.

```t

resource "aws_instance" "main" {
  ami           = "ami-043a5a82b6cf98947"
  instance_type = var.ec2_type

  tags = {
    Name        = var.ec2_name
    Environment = var.environment
  }
}

```

- `variables.tf` dosyasınıın içeriğini oluşturuyoruz.

```t

variable "ec2_name" {
  default = "my-EC2-instance"
}

variable "ec2_type" {
  default = "t2.micro"
}

variable "environment" {
  default = "dev"
}

```

- `output.tf` dosyasının içeriğini aşağıdaki gibi oluşturalım.

```t
output "ami" {
  value = aws_instance.main.ami
}

output "instance_id" {
  value = aws_instance.main.id
}

output "instance_ip" {
  value = aws_instance.main.private_ip
}

output "instance_tags" {
  value = aws_instance.main.tags_all
}
```


### Terraform Scriptini Çalıştırıyoruz.

```bash
terraform init
terraform apply --auto-approve
```

### İşlem Tamalandıktan sonra aşağıdaki mesajı görüyoruz.

```bash
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```




### conditionals

- Terraform'da conditionals (koşullular), yapılandırmayı daha dinamik hale getirmek için koşullu ifadeler kullanmanıza olanak tanır. Bu ifadeler sayesinde, belirli bir koşulun doğru veya yanlış olmasına bağlı olarak farklı değerler veya davranışlar tanımlayabilirsiniz.

- Şart bloğunun yapısı şu şekildedir: `condition ? true_value : false_value`

condition   : Doğru veya yanlış dönen bir ifade.
true_value  : Koşul doğruysa kullanılacak değer.
false_value : Koşul yanlışsa kullanılacak değer.

- `main.tf` dosyasında aşağıdaki değişikliği yapalım

```t
resource "aws_instance" "main" {
  ami           = "ami-043a5a82b6cf98947"
  instance_type = var.is_production ? "t2.large" : "t2.micro"

  tags = {
    Name        = var.ec2_name
    Environment = var.is_production ? "Production" : "Development"
  }
}
```

- `variables.tf` dosyasına aşağıdaki değişkeni ekleyelim

```t
variable "is_production" {
  default = true
}
```
- `output.tf` dosyasında aşağıdaki değişikliği yapalım

```t
output "ami" {
  value = aws_instance.main.ami
}

output "instance_id" {
  value = aws_instance.main.id
}

output "instance_ip" {
  value = aws_instance.main.private_ip
}
```

```bash
terraform plan
terraform apply --auto-approve
```

### count

- Terraform'da count parametresi, aynı türde birden fazla kaynağı (resource) veya modülü dinamik olarak oluşturmak için kullanılır. Bu özellik, tekrarlayan kod yazmayı önler ve altyapıyı daha ölçeklenebilir ve esnek hale getirir. count, kaynakların sayısını belirlemek için bir integer (tam sayı) değer alır.

- `main.tf` dosyasında aşağıdaki değişikliği yapalım

```t
resource "aws_instance" "main" {
  count         = 2
  ami           = "ami-043a5a82b6cf98947"
  instance_type = var.is_production ? "t2.large" : "t2.micro"

  tags = {
    Name        = var.ec2_name
    Environment = var.is_production ? "Production" : "Development"
  }
}
```
- `output.tf` dosyasında aşağıdaki değişikliği yapalım

```t
output "instance_ami" {
  value = aws_instance.main.*.ami
}

output "instance_ids" {
  value = aws_instance.main.*.id
}

output "instance_ips" {
  value = aws_instance.main.*.private_ip
}

output "instance_tags" {
  value = aws_instance.main.*.tags_all
}
```

```bash
terraform plan
terraform apply --auto-approve
```

- count parametresini conditionals ile birlikte de kullanabiliriz. Yapıyı daha dimaik hale getirmek için count conditionals birlikte kullanılmaktadır.

- `main.tf` dosyasında aşağıdaki değişikliği yapalım

```t
resource "aws_instance" "main" {
  count         = var.is_production ? 3 : 1
  ami           = "ami-043a5a82b6cf98947"
  instance_type = var.is_production ? "t2.large" : "t2.micro"

  tags = {
    Name        = "${var.ec2_name}-${count.index + 1}"
    Environment = var.is_production ? "Production" : "Development"
  }
}
```
- `output.tf` dosyasında aşağıdaki değişikliği yapalım

```t
output "instance_ami" {
  value = aws_instance.main.*.ami
}

output "instance_ids" {
  value = aws_instance.main.*.id
}

output "instance_ips" {
  value = aws_instance.main.*.private_ip
}

output "instance_tags" {
  value = aws_instance.main.*.tags_all
}
```

```bash
terraform plan
terraform apply --auto-approve
```

### for_each

- Terraform'da for_each, birden fazla kaynak (resource) veya modülün dinamik olarak oluşturulmasını sağlayan güçlü bir mekanizmadır. Özellikle bir liste veya harita (map) içindeki her bir öğe için kaynak oluşturmak istediğinizde kullanılır. for_each, count parametresine kıyasla daha esnektir çünkü bireysel öğelere doğrudan erişim sağlar.

- **toset() Nedir?**
    toset() fonksiyonu, Terraform'da bir list’i set veri tipine çevirir.

    Yani ["dev", "test", "prod"] gibi sıralı ve tekrar edebilir bir listeyi, sırasız ve benzersiz öğelere sahip bir kümeye çevirir.

    for_each sadece map veya set türü koleksiyonlarla çalışır. Ama ["dev", "test", "prod"] bir list olduğu için doğrudan kullanılamaz.

    Terraform her bir değer için each.value ile erişilebilecek ayrı bir kaynak üretir.  

- **Map ile for_each kullanımı**

```t
for_each = {
  dev  = "t2.micro"
  prod = "t3.large"
  }

Bu durumda:
each.key → "dev"
each.value → "t2.micro"
```
| Yapı       | Açıklama                                           |
| ---------- | -------------------------------------------------- |
| `list`     | Sıralı, tekrar edebilir. `for_each` kullanamaz.    |
| `set`      | Sırasız, benzersiz. `for_each` ile kullanılabilir. |
| `toset()`  | `list` → `set` dönüşümünü sağlar.                  |
| `for_each` | Eleman bazlı resource çoğaltma için ideal.         |


- `main.tf` dosyasında aşağıdaki değişikliği yapalım

```t
resource "aws_instance" "main" {
  for_each      = toset(["dev", "test", "prod"])
  ami           = "ami-043a5a82b6cf98947"
  instance_type = var.is_production ? "t2.large" : "t2.micro"

  tags = {
    Name        = "${each.key}-instance"
    Environment = each.value
  }
}
```
- `output.tf` dosyasında aşağıdaki değişikliği yapalım

```t
output "instance_ami" {
  value = {
    for instance_key, instance in aws_instance.main :
    instance_key => instance.ami
  }
}

output "instance_ids" {
  value = {
    for instance_key, instance in aws_instance.main :
    instance_key => instance.id
  }
}

output "instance_ips" {
    value = {
    for instance_key, instance in aws_instance.main :
    instance_key => instance.private_ip
  }
}

output "instance_tags" {
    value = {
    for instance_key, instance in aws_instance.main :
    instance_key => instance.tags_all
  }

}

```
```bash
terraform plan
terraform apply --auto-approve
```

### for loop

- Terraform for döngüleri, aynı türden birden fazla kaynak oluşturmak istediğinizde kod tekrarını önlemek ve konfigürasyonlarınızı daha yönetilebilir hale getirmek için kullanılan güçlü bir mekanizmadır. Bu sayede, benzer özelliklere sahip birçok kaynak (örneğin, aynı güvenlik grubunda birden fazla EC2 instance'ı) tek bir konfigürasyon bloğu içinde tanımlanabilir.

- Liste üzerinde kullanım: `[for item in list : expression]` şeklinde yapıya sahiptir. Dosyalarda aşağıdaki değişiklikleri yapacak terraform plan işlemini uygulayalım.

- `variables.tf` dosyasına aşağıdaki değişkeni ekleyelim.

```t
variable "names" {
  default = ["dev", "test", "prod"]
}
```
- `output.tf` dosyasında aşağıdaki değeriekleyelim.

```t
output "uppercased_names" {
  value = [for name in var.names : upper(name)] # for dongüsü değişkenleri sıra ile çekerek fonksiyonu uyguluyor.
}
```

```bash
terraform plan
Çıktı olarak `uppercased_names = ["DEV", "TEST", "PROD"]` göreceksiniz.
```

- Map üzerinde kullanım: `{for key, value in map : key => expression}` şeklinde yapıya sahiptir. Dosyalarda aşağıdaki değişiklikleri yapacak terraform plan işlemini uygulayalım.

- `variables.tf` dosyasına aşağıdaki değişkeni ekleyelim.

```t
variable "region_map" {
  default = {
    us-east-1 = "Virginia"
    us-west-1 = "California"
  }
}
```
- `output.tf` dosyasında aşağıdaki değeriekleyelim.

```t
output "region_names" {
  value = [for region, name in var.region_map : "${region} is in ${name}"]
}
```

```bash
terraform plan
Çıktı olarak `region_names = ["us-east-1 is in Virginia", "us-west-1 is in California"]` göreceksiniz.
```

### If bloğu

- If bloğu, Terraform'da koşullu ifadeler oluşturmak için kullanılır. Bu ifadeler, for loop içinde belirli bir koşulun sağlanıp sağlanmadığını kontrol etmek ve yalnızca bu koşul geçerliyse işlem yapmak için uygundur.

- For Loop ve If Bloğu Birlikte Kullanımı: `[for item in list : expression if condition]`

- `variables.tf` dosyasına aşağıdaki değişkeni ekleyelim.

```t
variable "numbers" {
  default = [1, 2, 3, 4, 5, 33, 44, 55, 40]
}
```
- `output.tf` dosyasında aşağıdaki değeriekleyelim.

```t
output "even_numbers" {
  value = [for num in var.numbers : num if num % 2 == 0]
}
```

```bash
terraform plan
Çıktı olarak `even_numbers = [2, 4, 44, 40]` göreceksiniz.
```

- For Loop ve If Bloğu Map yapısında Birlikte Kullanımı: `{for key, value in map : key => expression if condition}`

- `variables.tf` dosyasına aşağıdaki değişkeni ekleyelim. Önceki (variable "region_map" {}) güncelleyelim.

```t
variable "region_map" {
  default = {
    "us-east-1"    = "Virginia"
    "us-west-1"    = "California"
    "eu-central-1" = "Frankfurt"
  }
}
```
- `output.tf` dosyasında aşağıdaki değeriekleyelim.

```t
output "us_regions" {
  value = { for region, name in var.region_map : region => name if startswith(region, "us-") }
}
```

```bash
terraform plan
Çıktı olarak `us_regions = {us-east-1 = "Virginia" us-west-1 = "California"}` göreceksiniz.
```

```bash
terraform destroy
```

