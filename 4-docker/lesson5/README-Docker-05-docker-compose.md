# Hands-on Docker-09 : Docker Compose ile Çoklu Container Yönetimi

Bu uygulamalı eğitimin amacı, öğrencilere Docker Compose kullanarak birden fazla container'ı tanımlama, başlatma ve yönetme yetkinliği kazandırmaktır.

## 🎯 Öğrenme Hedefleri

Bu uygulamalı eğitimin sonunda öğrenciler:

- Docker Compose nedir, neden kullanılır, anlayabilecek,
- `docker-compose.yml` dosyası oluşturabilecek,
- Bağımlı container’ları birlikte çalıştırabilecek,
- Ortak ağ ve hacim yapılandırmalarıyla uygulama inşa edebilecek,
- Bir web + veritabanı örneğini Compose ile başlatıp durdurabileceklerdir.

## 🧭 İçerik

- Bölüm 0 - Docker Makinesi Oluşturma ve SSH ile Bağlanma
- Bölüm 1 - Docker Compose Nedir?
- Bölüm 2 - Docker Compose Kurulumu (Opsiyonel)
- Bölüm 3 - Basit Compose Dosyası ile "Hello World"
- Bölüm 4 - Web + Veritabanı Mimarisinde Docker Compose Kullanımı
- Bölüm 5 - Komutlar ve Uygulama Kontrolü
- Bölüm 6 - Kendi Docker Compose Uygulaman

## Bölüm 0 - Docker Makinesi Oluşturma ve SSH ile Bağlanma

- 1. Alternatif: Lokal makinadan Docker Desktop çalıştıralım ve VS Code ile çalışmaya başlayalım.

- 2. Alternatif: https://labs.play-with-docker.com/ adresinden bir sanal makina oluşturalım ve SSH bağlatısını VS Cpde terminalimize yapıştırarak çalışmaya başlayalım.

- 3. Alternatif: Terraform dosyası ile AWS de bir Docker makinası oluşturalım ve SSH ile bağlanalım

```bash
$ ssh -i .ssh/your_pem.pem ec2-user@IP
```

- `~/Bootcamp/Devops/Docker` Çalışma dizini altına çalışma klasörünü oluşturalım. Bu ders ile alakalı tüm çalışmlarımızı bu klasörde yapalım.

```bash
mkdir docker-05-hands-on
cd docker-05-hands-on
```

## 🧩 Bölüm 1 - Docker Compose Nedir?

Docker Compose, çok sayıda container içeren uygulamaları kolaylıkla yönetebilmemizi sağlayan bir araçtır. Tüm servisleri bir YAML dosyasında tanımlarız ve tek komutla tüm uygulamayı ayağa kaldırabiliriz.

**Avantajları:**
- Tek dosya ile çoklu container yönetimi
- Ortak network/volume tanımlamaları
- Kolay versiyonlama ve dağıtım

## 🧩 Bölüm 2 - Docker Compose Kurulumu

Docker Compose genellikle Docker kurulumuna dahil gelir. Kontrol etmek için:

```bash
docker compose version
```

Yoksa Ubuntu'da:

```bash
sudo apt install docker-compose-plugin
```

## 🧩 Bölüm 3 - Basit "Hello Compose" Örneği

```bash
mkdir hello-compose && cd hello-compose
```

`docker-compose.yml` dosyası:

```yaml
echo 'version: "3.8"
services:
  hello:
    image: alpine
    command: ["echo", "Merhaba Docker Compose!"]' > docker-compose.yml
```

Çalıştır:

```bash
docker compose up
docker compose down
```

## 🧩 Bölüm 4 - Web + DB Yapısı

```bash
cd ..
mkdir web-db-compose && cd web-db-compose
```

`docker-compose.yml`:

```yaml
echo 'version: "3.8"

services:
  web:
    image: nginx
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html
    depends_on:
      - db

  db:
    image: mariadb:10.5
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: testdb
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:' > docker-compose.yml
```

HTML dosyası:

```bash
mkdir html
echo "<h1>Cloud Cloud Bootcapm - Docker Compose ile NGINX </h1>" > html/index.html
```

Başlat:

```bash
docker compose up -d
```

Tarayıcıda aç: `http://localhost:8080`

## 🧩 Bölüm 5 - Compose Komutları

| Komut | Açıklama |
|-------|----------|
| `docker compose up -d` | Arka planda başlatır |
| `docker compose ps` | Servisleri listeler |
| `docker compose down` | Hepsini durdurur |
| `docker compose restart` | Yeniden başlatır |


## 🐳 PHP + MySQL Docker Compose Uygulaması EK-proje

Bu proje, Docker kullanarak PHP (Apache) ile MySQL veritabanını birlikte çalıştıran örnek bir web uygulamasıdır. Amaç, Docker Compose ile çoklu konteyner ortamlarında servisler arası iletişimi, volume yönetimini ve PHP tarafında veritabanı bağlantılarını test etmektir.

---

### 📁 Proje Yapısı

```
php-mysql-app/
├── Dockerfile
├── docker-compose.yml
└── src/
    └── index.php
```

---

## 🚀 Kurulum ve Çalıştırma Adımları

- Bu bölümde, Docker ortamında çalışan basit bir PHP web uygulaması ile MySQL veritabanını birlikte kullanacağız. İki servis arasında Docker Compose ile bağlantı kurulacak ve PHP tarafında mysqli eklentisiyle veritabanına bağlanılacak.

### 1. Proje Klasörünü Oluştur

```bash
mkdir -p php-mysql-app/src
cd php-mysql-app
```

- Açıklama:
    `mkdir -p php-mysql-app/src`: Uygulamanın ana dizinini (php-mysql-app) ve içinde PHP dosyalarının bulunacağı src klasörünü oluşturur.
    `cd php-mysql-app`: Çalışma dizinini proje köküne alırız. Buraya Dockerfile, docker-compose.yml gibi dosyalar yazılacaktır.

- Bu komut ile uygulamanın çalışacağı klasör ve kaynak dosyalarının yerleştirileceği `src/` dizini oluşturulur.

---

### 2. PHP Dosyasını (`index.php`) Oluştur

```bash
cat <<'EOF' > src/index.php
<?php
$mysqli = new mysqli("db", "root", "root123", "mydb");
if ($mysqli->connect_error) {
  echo "MySQL'e bağlanılamadı: " . $mysqli->connect_error;
} else {
  echo "MySQL bağlantısı TAMAM!";
}
?>
EOF
```

- Açıklama:
    `new mysqli("db", "root", "root123", "mydb");`: Docker Compose içindeki db adlı MySQL servisine, root kullanıcısı ve şifreyle bağlanmayı dener.
    "db" burada bir DNS adıdır, Docker Compose her servise kendi ismini DNS olarak atar.
    Bağlantı hatası varsa hata mesajı döner, değilse bağlantı başarılı mesajı görüntülenir.

- Bu dosyada PHP'nin `mysqli` sınıfı ile MySQL servisine bağlanmaya çalışılır. 
- `db` ismi, Docker Compose içinde tanımlanan veritabanı servisinin adıdır ve DNS üzerinden çözülür.

---

### 3. Dockerfile Oluştur

```bash
cat <<EOF > Dockerfile
FROM php:8.0-apache

# mysqli uzantısını yükle
RUN docker-php-ext-install mysqli

# PHP dosyalarını Apache root dizinine kopyala
COPY src/ /var/www/html/
EOF
```

- Açıklama:
    `FROM php:8.0-apache`: PHP 8.0 ve Apache içeren resmi imajı temel alır.
    `docker-php-ext-install mysqli`: PHP için mysqli eklentisini kurar (veritabanı bağlantısı için gereklidir).
    `COPY src/ /var/www/html/`: PHP uygulamasını Apache'nin servis verdiği dizine kopyalar.
    `RUN docker-php-ext-install mysqli` : Eğer bu uzantı kurulmazsa Class "mysqli" not found hatası alınır.
    Dockerfile, `php:8.0-apache` temel imajı üzerine PHP `mysqli` uzantısını yükler ve proje dosyalarını web sunucusunun dizinine kopyalar.

---

### 4. docker-compose.yml Oluştur

```bash
cat <<EOF > docker-compose.yml
version: "3.8"

services:
  web:
    build: .
    ports:
      - "8081:80"
    depends_on:
      - db

  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: mydb
EOF
```

- Açıklama:
    `services`: Bu blok içinde iki servis tanımlıyoruz: web (PHP uygulaması) ve db (MySQL).
    `build: .`: Dockerfile’ın bulunduğu dizinden özel imajı inşa eder.
    `ports: "8081:80"`: Host makinedeki 8081 portunu konteynerin 80 portuna yönlendirir. Tarayıcıdan http://localhost:8081 ile erişim sağlanır.
    `depends_on`: web servisi başlamadan önce db servisini başlatır.
    `MYSQL_ROOT_PASSWORD, MYSQL_DATABASE`: MySQL’in başlangıç ayarlarıdır.
    Bu ayarlarla root şifresi root123, varsayılan veritabanı mydb olarak ayarlanır.

- Docker Compose ile iki servis tanımlanır:
- `web`: PHP uygulamasını çalıştırır, kendi Dockerfile'ından build edilir.
- `db`: MySQL sunucusudur. `root` kullanıcısı için şifre belirlenir ve `mydb` isimli veritabanı oluşturulur.

---

### 5. Uygulamayı Başlat

```bash
docker compose up -d
docker compose up --build -d # iage dosyasında değişiklik yapıldıysa
```

- Açıklama:
    `docker compose`: Docker Compose V2 ile çalışır.
    `up`: Servisleri başlatır (gerekirse build eder).
    `-d`: Arka planda (detached mode) çalıştırır.
    Bu komut hem PHP+Apache container’ını hem de MySQL container’ını arka planda başlatır.

---

## 🌐 Web Uygulamasına Erişim

Tarayıcıdan:

```bash 
http://localhost:8081

```

Eğer bağlantı başarılıysa şunu göreceksin:

```bash 
MySQL bağlantısı başarılı!
```

Aksi takdirde, MySQL henüz başlatılmamış olabilir. Bu durumda sayfayı birkaç saniye sonra tekrar yenileyin.

---

## 🧪 Servis Durumunu ve Logları Kontrol Et

### Servislerin durumu:

```bash
docker compose ps

NAME                  IMAGE               COMMAND                  SERVICE   CREATED         STATUS         PORTS
php-mysql-app-db-1    mysql:5.7           "docker-entrypoint.s…"   db        9 minutes ago   Up 9 minutes   3306/tcp, 33060/tcp
php-mysql-app-web-1   php-mysql-app-web   "docker-php-entrypoi…"   web       7 minutes ago   Up 7 minutes   0.0.0.0:8081->80/tcp
```
- Açıklama
    State: Up: Servisler aktif çalışıyor
    8081->80: Web servisi 8081 portundan erişilebilir

### MySQL servis logları:

```bash
docker logs php-mysql-app-db-1
```

- Loglarda “ready for connections” mesajı, veritabanının hazır olduğunu gösterir.

---

## 🧹 Temizlik

Uygulama ve bağlı kaynakları temizlemek için:

```bash
docker compose down --volumes --remove-orphans
```
- Açıklama:
    `down`: Tüm servisleri durdurur ve siler.
    `--volumes`: Veritabanı gibi kalıcı volume’ları da siler.
    `--remove-orphans`: Tanımsız (eski) konteynerleri de temizler.

---

## 📌 Ek Bilgiler

- Docker Compose ile birden fazla servisi aynı ağda çalıştırmak kolaylaşır.
- `depends_on` servisi başlatma sırasını düzenler fakat servis hazır olana kadar bekletmez.
- Daha sağlam senaryolar için `healthcheck` veya `wait-for-it.sh` scriptleri kullanılabilir.

---

- 📌 Özet

| Bileşen              | Açıklama                                              |
| -------------------- | ----------------------------------------------------- |
| `Dockerfile`         | PHP + Apache + `mysqli` içeren özel imaj              |
| `docker-compose.yml` | Web ve veritabanı servisini birlikte yönetir          |
| `index.php`          | PHP ile veritabanına bağlantıyı test eder             |
| `build` ve `up`      | Uygulamayı başlatır ve port yönlendirmesi sağlar      |
| `depends_on`         | Web servisinin veritabanından önce başlamasını sağlar |





### Çalışan cantainer ları durduralım ve silelim

- remove and stop all containers

```bash
docker stop $(docker ps -a -q) 
docker rm $(docker ps -a -q) 
docker system prune -a # herşeyi temizle

```









## 🧩 Bölüm 6 - Kendi Uygulaman: PHP + MySQL

```bash
cd ..
mkdir -p php-mysql-app/src && cd php-mysql-app
```


`src/index.php`:

```bash
cat <<'EOF' > src/index.php
<?php
$mysqli = new mysqli("db", "root", "root123", "mydb");
if ($mysqli->connect_error) {
  echo "MySQL'e bağlanılamadı: " . $mysqli->connect_error;
} else {
  echo "MySQL bağlantısı başarılı!";
}
?>
EOF
```

- Docker file oluşturalım

```bash
cat <<EOF > Dockerfile
FROM php:8.0-apache

# mysqli uzantısını yükle
RUN docker-php-ext-install mysqli

# Geliştirici için ekstra yardımcılar istenirse:
# RUN apt-get update && apt-get install -y vim curl

# Belge klasörünü otomatik tanıması için (gerekirse)
COPY src/ /var/www/html/
EOF
```


`docker-compose.yml`:

```yaml
cat <<EOF > docker-compose.yml
version: "3.8"

services:
  web:
    build: .
    ports:
      - "8081:80"
    depends_on:
      - db

  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: root123
      MYSQL_DATABASE: mydb
EOF
```



Başlat:

```bash
docker compose up -d
```

Kontrol et: `http://localhost:8081`

---

- Sistem çalışıyor ve şimdi logları vs inceleyebiliriz.

```bash
docker compose ps

Name                 Command                  State           Ports
php-mysql-app-db     docker-entrypoint.sh ... Up      3306/tcp
php-mysql-app-web    apache2-foreground       Up      0.0.0.0:8081->80/tcp

docker logs php-mysql-app-db

```


Hazırlayan: Fevzi Topcu  
Tarih: Mayıs 2025  
Konu: Docker Compose ile Hands-on  
Düzey: Başlangıç – Orta Seviye
