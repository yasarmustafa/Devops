# Hands-on Terraform-03 : Terraform Functions:

Bu Hands-on çalışmasında terraform Fonksiyonlarını inceleyeceğiz.

## Outline

- Bölüm 1 - Terraform Fuctions-Bonus

## Bölüm 1- Terraform Fuctions-Bonus

# 🧠 Terraform Functions Hands-on Rehberi

Bu belge, Terraform'da yaygın olarak kullanılan fonksiyonları açıklamalar ve örneklerle birlikte öğretmeyi amaçlayan interaktif bir hands-on çalışmasıdır.

- Yeni Bir Çalışma Klasörümüzü oluşturalım

```bash
mkdir -p ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/terraform-03-functions
cd ~/Desktop/Bootcamp-Hands-on/Devops/Terraform/terraform-03-functions
```
- Hands-on çalışması için yeni gerekli konfigürasyon dosyalarını oluşturalım.

```bash
touch variables.tf output.tf
```

---

## 📘 1. `length()`

Bir liste, string veya map'in uzunluğunu döner.

### Örnek:

```hcl
variable "names" {
  default = ["ahmet", "ayşe", "mehmet"]
}

output "number_of_names" {
  value = length(var.names)
}
```

### Terraform Scriptini Çalıştırıyoruz.

```bash
terraform apply --auto-approve
```


### Beklenen Çıktı:
```
number_of_names = 3
```

---

## 🔤 2. `upper()` / `lower()`

Bir string ifadenin tamamını büyük (`upper`) ya da küçük (`lower`) harfe çevirir.

### Örnek:

```hcl
output "shout" {
  value = upper("terraform")
}

output "whisper" {
  value = lower("TERRAFORM")
}
```
### Terraform Scriptini Çalıştırıyoruz.

```bash
terraform apply --auto-approve
```


### Beklenen Çıktı:
```
shout = "TERRAFORM"
whisper = "terraform"
```
---

## 🔗 3. `join()`

Bir listeyi, verilen ayraç ile birleştirerek tek bir string oluşturur.

### Örnek:

```hcl
variable "names" {
  default = ["dev", "test", "prod"]
}

output "envs" {
  value = join("-", var.names)
}
```

```bash
terraform apply --auto-approve
```

### Beklenen Çıktı:
```
envs = "dev-test-prod"
```

---

## 📤 4. `split()`

Bir string ifadeyi belirli bir ayraçla ayırarak bir liste oluşturur.

### Örnek:

```hcl
output "split_envs" {
  value = split("-", "dev-test-prod")
}
```
```bash
terraform apply --auto-approve
```

### Beklenen Çıktı:
```
split_envs = ["dev", "test", "prod"]
```

---

## 🔄 5. `replace()`

Bir string içindeki metni yenisiyle değiştirir.

### Örnek:

```hcl
output "replaced" {
  value = replace("hello-world", "-", " ")
}
```
```bash
terraform apply --auto-approve
```

### Beklenen Çıktı:
```
replaced = "hello world"
```

---

## 🧮 6. `substr()`

Bir string'in belirli bir parçasını alır. `substr(string, start_index, length)`

### Örnek:

```hcl
output "short_name" {
  value = substr("terraform", 0, 4)
}
```

### Beklenen Çıktı:
```
short_name = "terr"
```

---

## 🔢 7. `tostring()`, `tolist()`, `tomap()`

Veri tiplerini dönüştürmek için kullanılır.

### Örnek:

```hcl
output "as_string" {
  value = tostring(123)
}

output "as_list" {
  value = tolist(["a", "b"])
}
```

---

## ✅ 8. `contains()`

Bir liste belirli bir öğeyi içeriyor mu, kontrol eder.

### Örnek:

```hcl
output "has_test" {
  value = contains(["dev", "test", "prod"], "test")
}
```

### Beklenen Çıktı:
```
has_test = true
```

---

## 🗺️ 9. `lookup()`

Map içinden anahtar ile değer alır. Eğer bulunamazsa varsayılan döner.

### Örnek:

```hcl
variable "env_tags" {
  default = {
    dev  = "Development"
    prod = "Production"
  }
}

output "env_name" {
  value = lookup(var.env_tags, "dev", "Unknown")
}
```

---

## 🧠 10. `coalesce()`

Verilen değerlerden ilk `null olmayan`ı döner. Boş turnak da null dur.

### Örnek:

```hcl
output "first_valid" {
  value = coalesce(null, "", "default-value", "another")
}
```

### Beklenen Çıktı:
```
first_valid = "default-value"
```

---

## 🧪 Test Etme

Yukarıdaki örnekleri test etmek için:
```bash
terraform console
> join("-", ["a", "b", "c"])
> replace("terraform-101", "-", " ")
> contains(["a", "b", "c"], "d")
```

---

Bu çalışma, Terraform fonksiyonları öğrenmek isteyenler için pratik ve açıklayıcı örneklerle hazırlanmıştır. Terraform fonksiyonları hakkında daha fazla bilgi için: [Terraform Docs - Functions](https://developer.hashicorp.com/terraform/language/functions)
