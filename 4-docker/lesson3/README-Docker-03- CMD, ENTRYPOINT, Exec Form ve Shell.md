# Hands-on Docker-09 : CMD, ENTRYPOINT, Exec Form ve Shell Form Kullanımı

Bu uygulamalı çalışmanın amacı, Dockerfile yazarken kullanılan `CMD`, `ENTRYPOINT`, `exec form`, ve `shell form` komutlarının kullanımını öğretmek, farklarını açıklamak ve gerçek örneklerle öğrencinin bu komutları nasıl kullanacağını kavratmaktır.

---

## 🎯 Öğrenme Hedefleri

Bu çalışmanın sonunda katılımcılar:

- `CMD` ve `ENTRYPOINT` talimatlarının Dockerfile'daki rolünü anlayacak,
- `exec form` ve `shell form` arasındaki farkları bilecek,
- Farklı senaryolarda hangi formun ve hangi komutun tercih edilmesi gerektiğini kavrayacak,
- Uygulamalı örneklerle bu kavramları pekiştirecekler.

---

## 🧭 İçerik

- Bölüm 1 - CMD ve ENTRYPOINT Nedir?
- Bölüm 2 - Exec Form ve Shell Form Nedir?
- Bölüm 3 - CMD vs ENTRYPOINT: Farklar ve Kullanım Senaryoları
- Bölüm 4 - Uygulama 1: CMD ile Örnek Dockerfile
- Bölüm 5 - Uygulama 2: ENTRYPOINT ile Script Çalıştırma
- Bölüm 6 - Uygulama 3: CMD + ENTRYPOINT Birlikte Kullanımı
- Bölüm 7 - Özet 

---

## 🧩 Bölüm 1 - CMD ve ENTRYPOINT Nedir?

### `CMD`

- Container başlatıldığında **varsayılan olarak** çalışacak komutu belirtir.
- Eğer `docker run` ile başka bir komut verilirse, `CMD` **geçersiz kılınır override edilir**.

```bash
mkdir cmd-ornek
cd cmd-ornek
```
- docker hub üzerinde ubuntu, nginx ve mongodb imajlarını inceleyelim

- CMD komutu bir konteyner ayağa kalktığı zaman çalışan komutu içerir, bir docker file da sadece bir tan ecmd komutu çalışır. Override edilebilr.

```dockerfile
FROM ubuntu
CMD ["sleep", "2"]
```

```dockerfile
FROM busybox
CMD ["echo", "Merhaba Dünya"]
```

Yukarıdaki örnekte, başka komut verilmezse `echo Merhaba Dünya` çalışacaktır.

---

### `ENTRYPOINT`

- Container başlatıldığında çalıştırılacak **ana uygulamayı** tanımlar.
- `docker run` ile verilen komutlar `ENTRYPOINT`’e **argüman** olarak iletilir.
- Daha çok bir uygulamanın başlatılmasında ya da container’ın hep aynı işlevi görmesi istendiğinde tercih edilir.

```dockerfile
ENTRYPOINT ["echo", "Selam"]
ENTRYPOINT ["echo"] # tek başına çalışmaz arguman ister, CMD ile veya run komutu ile arguman göndermemiz gerekir
CMD ["selam"]
```

`docker run` ile `hello` derseniz çıktı:  
➡️ `Selam hello`

---

## 🧩 Bölüm 2 - Exec Form ve Shell Form Nedir?

Dockerfile'daki `CMD` ve `ENTRYPOINT` komutları iki şekilde yazılabilir:

### **1. Exec Form (JSON Dizisi)**

```dockerfile
CMD ["echo", "Merhaba Dünya"] # Bu, direkt olarak `execve` ile çalıştırılır. Shell kullanılmaz.
```
🔧 Özellikler:
    Daha güvenli ve tahmin edilebilir.
    PID 1 olan işlem doğrudan belirtilen programdır (örn. myapp).
    Bash özellikleri (&&, |, $VAR) çalışmaz.

```dockerfile
ENTRYPOINT ["executable", "param1"]
CMD ["executable", "param1", "param2"]


```

- **Tavsiye edilen yöntemdir.**
- Shell üzerinden değil, doğrudan çalıştırılır.
- `ENTRYPOINT` ve `CMD` ayrı ayrı tanımlanabilir.

### **2. Shell Form (Tek Satır Komut)**

- komut bir shell `sh` aracılığı ile çalıştırılır.

🔧 Özellikler:
    Shell özellikleri (örn: &&, |, environment variable expansion $VAR) çalışır.
    Daha kısa yazılır, özellikle bash script gibi komut zincirlerinde kullanışlıdır.
    PID 1 olan işlem sh olur, uygulamanın kendisi değil.

```bash
CMD echo "Merhaba Dünya"            # bu komut şuna eşittir; /bin/sh -c "echo Merhaba Dünya"
/bin/sh -c "echo Merhaba Dünya"
```

```dockerfile
CMD executable param1 param2
ENTRYPOINT executable param1
```

- `/bin/sh -c` üzerinden çalıştırılır.
- Bash fonksiyonları, pipe (`|`) gibi shell özellikleri kullanılabilir.


## Shell Form Örneği: Dockerfile

```bash
mkdir shell-demo
cd shell-demo
```
- aşağıdaki dockerfile oluşturalım.

```dockerfile
FROM ubuntu:22.04
ENV NAME=Ahmet
CMD echo "Merhaba $NAME" && echo "Docker $NAME tarafından başlatıldı"
```

🔍 Çıktı değerlendirme?
Bu örnekte:
    $NAME → ortam değişkeni olarak değerlendirilir.
    && → ilk echo başarılı olursa ikinci echo çalışır.
    | → ikinci echo çıktısı tee komutu ile hem ekrana yazılır hem /output.txt'ye kaydedilir.

```bash
docker build -t shell-form-demo .
docker run --rm shell-form-demo
docker run --rm -e NAME=CLOUD shell-form-demo
docker run --rm --env NAME=BOOTCAMP shell-form-demo
```

---

## 🧩 Bölüm 3 - CMD vs ENTRYPOINT: Farklar ve Kullanım Senaryoları

| Özellik                                  | CMD | ENTRYPOINT            |
|------------------------------------------|-----|-----------------------|
| Varsayılan komut olarak                  | ✅ | ❌                    |
| Ana süreç tanımı olarak                  | ❌ | ✅                    |
| `docker run` ile override edilebilir mi? | ✅ | 🚫 (exec form ise)    |
| Argüman alabilir mi?                     | ✅ | ✅                    |
| Birlikte kullanılabilir mi?              | ✅ | ✅                    |

Birlikte kullanıldığında:

```dockerfile
ENTRYPOINT ["echo"]
CMD ["Hello"]
```

Çıktı: `echo Hello`

---

## 🧪 Bölüm 4 - Uygulama 1: CMD ile Örnek Dockerfile

### 1. Çalışma dizinini oluşturun:

```bash
mkdir docker-cmd-example && cd docker-cmd-example
```

### 2. `Dockerfile` oluşturun:

```dockerfile
# Dockerfile
FROM alpine
CMD ["echo", "Bu bir CMD örneğidir"]
```

### 3. Docker imajını oluşturun:

```bash
docker build -t cmd-example .
```

### 4. Container'ı çalıştırın:

```bash
docker run cmd-example
```

🔍 Çıktı: `Bu bir CMD örneğidir`

### 5. Alternatif komut ile çalıştırın:

```bash
docker run cmd-example echo "CMD override edildi"
```

🔍 Çıktı: `CMD override edildi` — Gördüğünüz gibi `CMD` geçersiz kılındı.

---

## 🧪 Bölüm 5 - Uygulama 2: ENTRYPOINT ile Script Çalıştırma

### 1. Çalışma dizini:

```bash
mkdir docker-entrypoint-example && cd docker-entrypoint-example
```

### 2. `entrypoint.sh` adında bir script oluşturun:

```bash
#!/bin/sh
echo "Merhaba, bu bir ENTRYPOINT komutudur!"
echo "Argümanlar: $@"
```
```bash
chmod +x entrypoint.sh
```

### 3. Dockerfile oluşturun:

```dockerfile
FROM alpine
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

### 4. İmajı oluşturun ve çalıştırın:

```bash
docker build -t entrypoint-example .
docker run entrypoint-example Docker Kullanıcısı
```

🔍 Çıktı:
```
Merhaba, bu bir ENTRYPOINT komutudur!
Argümanlar: Docker Kullanıcısı
```

---

## 🧪 Bölüm 6 - Uygulama 3: ENTRYPOINT ve CMD Birlikte Kullanımı

```dockerfile
# Dockerfile
FROM alpine
ENTRYPOINT ["echo"]
CMD ["Merhaba Dünya"]
```

```bash
docker build -t birlikte-kullanim .
docker run birlikte-kullanim
docker run birlikte-kullanim "Fevzi Topcu"
```

🔍 Çıktılar:
- İlk komut: `Merhaba Dünya`
- İkinci komut: `Fevzi Topcu` — `CMD` yerine geçiyor, ama `ENTRYPOINT` sabit.

---

## 🧭 Bölüm 7 - Özet ve Tercih Rehberi

- **CMD**: Varsayılan komut belirtmek için idealdir.
- **ENTRYPOINT**: Uygulamanın ana işlemini tanımlamak için uygundur.
- **Exec form**: Daha güvenli, sinyal yakalama ve PID yönetimi için tavsiye edilir.
- **Shell form**: Bash özelliklerine ihtiyaç duyulduğunda kullanılabilir.

🧠 **İpucu**:  
ENTRYPOINT ile birlikte CMD kullanmak, argümanları dışarıdan değiştirmeye olanak tanır.

---

Hazırlayan: Fevzi Topcu  
Tarih: Mayıs 2025  
Konu: CMD, ENTRYPOINT, exec ve shell form hands-on  
Düzey: Orta Seviye
