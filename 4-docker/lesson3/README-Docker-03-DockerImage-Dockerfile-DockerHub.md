# Hands-on Docker-03 : Docker Image ve Dockerfile İşlemleri

Bu eğitimin amacı, öğrencilere Docker'daki imajlar hakkında bilgi kazandırmaktır ve Dockerfile yazarak kendi mimajlarını oluşturmak.

## Neler Öğreneceğiz

Bu uygulamalı eğitim sonunda öğrenciler;

- Docker imajının ne olduğunu açıklayabilecekler.
- Docker imaj katmanlarını açıklayabilecekler.
- Docker'daki imajları listeleyebilecekler.
- Docker Hub’ı açıklayabilecekler.
- Docker Hub hesabı açabilecek ve bir repository oluşturabilecekler.
- Docker imajlarını çekebilecekler.
- İmaj etiketlerini açıklayabilecekler.
- Docker imajlarını inceleyebilecekler.
- Docker imajlarını arayabilecekler.
- Dockerfile’ın ne olduğunu açıklayabilecekler.
- Dockerfile ile imaj oluşturabilecekler.
- Oluşturulan imajları Docker Hub’a gönderebilecekler.
- Docker imajlarını silebilecekler.

## Outline

- Bölüm 0 - Docker Makine Örneği Başlatma ve SSH ile Bağlantı Kurma
- Bölüm 1 - Docker İmaj Komutları ve Docker Hub Kullanımı
- Bölüm 2 - Dockerfile ile Docker İmajları Oluşturma
- Bölüm 3 - Docker hub Repository oluşturma ve VS code ile Docker Hub a bağlanma
- Bölüm 4 - Multi-Stage Dockerfile Oluşturma
- Bölüm 5 - Çalışan konteynerları durdurma ve herşeyi temizleme


## Bölüm 0 - Docker Makinesi Oluşturma ve SSH ile Bağlanma

- 1. Alternatif: Lokal makinadan Docker Desktop çalıştıralım ve VS Code ile çalışmaya başlayalım.

- 2. Alternatif: https://labs.play-with-docker.com/ adresinden bir sanal makina oluşturalım ve SSH bağlatısını VS Cpde terminalimize yapıştırarak çalışmaya başlayalım.

- 3. Alternatif: Terraform dosyası ile AWS de bir Docker makinası oluşturalım ve SSH ile bağlanalım

```bash
$ ssh -i .ssh/your_pem.pem ec2-user@IP
```

## Bölüm 1 - Docker İmaj ve Docker Hub

- `~/Bootcamp/Devops/Docker` Çalışma dizini altına çalışma klasörünü oluşturalım. Bu ders ile alakalı tüm çalışmlarımızı bu klasörde yapalım.

```bash
mkdir docker-03-hands-on
cd docker-03-hands-on
```
- docker dokumantasyon sayfası

```bash
docker run -d -p 4000:4000 docs/docker.github.io
```


- Docker Hub nedir?
    Docker Hub, Docker imajlarının (image) depolanabildiği, paylaşılabildiği ve indirilebildiği bulut tabanlı bir imaj kayıt deposudur (container image registry). Docker tarafından sunulan resmi imajları, açık kaynak projelerini veya kendi özel (private) imajlarını barındırmak için kullanılır.

- Docker Hub Ne İçin Kullanılır?
    İmajları paylaşmak
    → Geliştiriciler oluşturdukları imajları Docker Hub’a push ederek başkalarıyla paylaşabilirler.

    İmajları çekmek (pull)
    → Docker kurulu olan bir makinede docker pull <image> komutuyla Docker Hub’daki bir imaj indirilebilir.

    Resmi imajlara erişmek
    → nginx, mysql, redis, ubuntu gibi birçok popüler yazılımın resmi ve güncel imajları burada yer alır.

    CI/CD süreçlerinde kullanmak
    → Otomatik build ve deployment senaryolarında merkezi bir imaj kaynağı olarak görev yapar.

    Private Repository oluşturmak
    → Sadece belirli kişilere açık olan özel imajlar barındırılabilir (ücretsiz sürümde sınırlı sayıda).

- Docker hub resmi web adresi: `https://hub.docker.com/` 

- Linke tıklayıp `sign up` butonu ile kayıt olalım. Mevcut kaydımız varsa `sing in` tıklayarak giriş yapaılm. Docker Hub’a kaydolup inceleyeim.

- Docker Hub'daki imajları inceleyelim.

- Docker iamge komutları

```bash
docker  build       #Build an image from a Dockerfile
docker  pull        #Download an image from a registry
docker  push        #Upload an image to a registry
docker  images      #List images
docker  login       #Authenticate to a registry
docker  logout      #Log out from a registry
docker  search      #Search Docker Hub for images
```


## Bölüm 2 - Dockerfile ile Docker İmajları Oluşturma

### 🎯 Amaç

Dockerfile’ın ne olduğunu, nasıl yazıldığını, hangi komutları içerdiğini ve bu komutların hangi durumlarda nasıl kullanıldığını öğrenmek.

### 🛠️ Dockerfile Nedir?

Dockerfile, bir Docker imajı oluşturmak için gerekli tüm adımları tanımlayan, metin tabanlı bir betik (script) dosyasıdır. Docker engine, bu dosyadaki talimatları sırasıyla okuyarak yeni bir imaj üretir.

---

### 🧱 Temel Dockerfile Talimatları ve Kullanım Açıklamaları

#### `FROM`

- Bir Dockerfile’ın her zaman bir `FROM` komutu ile başlaması gerekir.
- Kullanılacak temel (base) imajı belirtir.
- Örn: `FROM ubuntu:22.04`

#### `RUN`

- Docker imajı oluşturulurken bir komut çalıştırmak için kullanılır.
- Örn: `RUN apt update && apt install -y curl`

#### `CMD`

- Konteyner başlatıldığında çalışacak varsayılan komutu tanımlar.
- Dockerfile’da yalnızca bir `CMD` olabilir (sonuncusu geçerlidir).
- `CMD` çalıştırılabilir (exec form) veya shell formda olabilir.

#### `ENTRYPOINT`

- Konteyner çalıştığında her zaman çalışacak komuttur.
- Genellikle `CMD` ile birlikte kullanılır.
- `ENTRYPOINT` ile `CMD` birlikte kullanıldığında, `CMD` parametre olarak davranır.

**Karşılaştırma: `CMD` vs `ENTRYPOINT`**

| Özellik     | CMD                          | ENTRYPOINT                                 |
|-------------|------------------------------|--------------------------------------------|
| Amaç        | Varsayılan komut             | Değiştirilemeyen ana komut                 |
| Ezilebilir  | `docker run` ile ezilebilir  | `docker run` ile ezilemez                  |
| Kullanım    | `CMD ["python", "app.py"]`   | `ENTRYPOINT ["python"]` + `CMD ["app.py"]` |

#### `COPY` ve `ADD`

- COPY ve ADD, Dockerfile içinde host sisteminden (build konteyner dışı) konteyner imajına dosya kopyalamak için kullanılır. Ancak aralarındaki farkları iyi anlamak önemlidir, çünkü genellikle COPY tercih edilir ve ADD sadece özel durumlar için kullanılır.

✅ COPY Kullanımı
    1-Sadece dosya/dizin kopyalar.
    2-Kaynak dizin .dockerignore'a uygunsa, göz ardı edilir.
    3-En güvenli ve deterministik seçimdir.

✅ ADD Kullanımı
    1-URL’den Dosya Çekme
    2-Arşiv Açma (Sadece .tar formatları), files.tar.gz otomatik olarak açılır ve /app/ altına içerikleri yerleştirilir.
    3-.zip dosyaları desteklenmez, Bu nedenle .tar.gz gibi dosyalar için faydalı olabilir.

**ADD yerine genellikle curl veya wget ile RUN içinde yapılması tercih edilir:**
```bash
ADD https://example.com/data.json /app/data.json # zorunlu hallerde tercih edilir.
RUN curl -L https://example.com/data.json -o /app/data.json
```

🔍 COPY ve ADD Karşılaştırması

| Özellik                           | `COPY`             | `ADD`                                             |
| --------------------------------- | -------------------| ------------------------------------------------  |
| Dosya ve dizin kopyalama          | ✅ Evet           | ✅ Evet                                           |
| URL'den veri çekme (`http/https`) | ❌ Hayır          | ✅ Evet                                           |
| Arşiv dosyaları açma (`.tar.gz`)  | ❌ Hayır          | ✅ Evet (sadece `.tar`, `.tar.gz`, `.tar.bz2` vs) |
| Daha öngörülebilir davranış       | ✅ Evet           | ❌ Hayır (otomatik açma bazen istenmez)           |
| Güvenlik ve best practice         | ✅ Tavsiye edilir | ⚠️ Sadece gerektiğinde                            |

**Örnek:**
```Dockerfile
COPY ./app.py /app/app.py
COPY ./config/ /app/config/
ADD https://example.com/data.zip /app/data.zip
```

#### `ENV` ve `ARG`

| Özellik    | `ENV`                              | `ARG`                                |
|------------|------------------------------------|--------------------------------------|
| Kullanım   | Konteyner çalışırken geçerli olur  | Yalnızca build zamanında geçerlidir  |
| Ömür       | İmaj içinde kalır                  | Build tamamlandığında kaybolur       |
| Örnek      | `ENV PORT=8080`                    | `ARG VERSION=1.0`                    |

#### Diğer Talimatlar

- `WORKDIR`: Komutların çalışacağı dizini tanımlar.
- `LABEL`  : İmaja metadata ekler.
- `EXPOSE` : Konteynerin hangi portları açtığını bildirir (açmaz!).
- `VOLUME` : Host ile konteyner arasında kalıcı veri paylaşımı sağlar.

---

### 🧪 Uygulamalı Örnek: Python Uygulaması için Dockerfile

```bash
mkdir myapp
cd myapp
```
```
myapp/
├── app.py
└── Dockerfile
```

### app.py

```python
echo 'print("Merhaba Docker Dünyası!")' > app.py
```

### Dockerfile

```Dockerfile
echo 'FROM python:3.10-slim
WORKDIR /app
COPY app.py .
CMD ["python", "app.py"]' > Dockerfile
```

### Komutlar

```bash
docker build -t my-python-app .
docker run my-python-app
```

---

## Bölüm 3 - Docker hub public repo oluşturma ve VS code ile Docker Hub a bağlanma

- Docker hub web adresi: `https://hub.docker.com/` 

- Linke tıklayıp `sign up` butonu ile kayıt olalım. Mevcut kaydımız varsa `sing in` tıklayarak giriş yapaılm. Docker Hub’a kaydolup giriş yapaılm. Daha önce Docker Hub hesabı oluştruduğumuz için giriş yapmamı zyeterli olacaktır.

- https://hub.docker.com/u/dockerhub_username tıklayarak prfilimize girelim. burada varaolan repolarımız görebiliriz. Şimdi yeni bir repo oluşturalım: `flask-app` isminde ve `This image repo holds Flask apps.` açıklamasında bir repository oluşturun ve kaydedin. 

- Docker hub a vscode terminalinden bağlanabiliriz. Terminalden aşağıdaki komutu yazarak Docker Hub `<username>` ve `password` ile giriş yapalım.


```bash
docker login -u <username> # giriş için bu komutu kullanlalım
password:                  # dockerhub hesabımızın şifresini girelim. Eğer google ile kayıt olduysak account settings ten bir şifre oluşturalım
docker logout # ihtiyaç halinde çıkış için kullanlan komuttur. ancak kendi local bilgisayarımız olduğu için çıkış yapmanıza gerek yoktur.
```

- `ubuntu` imajını indirin ve Docker Hub’da varsayılan etiketin `latest` olduğunu açıklayın. `latest` etiketinin `24.04` sürümüne karşılık geldiğini gösterin.

```bash
docker image pull ubuntu
docker image ls
```

- `ubuntu` imajını interaktif shell ile konteyner olarak çalıştırın.

```bash
docker run -it ubuntu
```

- Konteyner içindeki `ubuntu` işletim sistemi bilgilerini gösterin (`VERSION="24.04.2 LTS (Noble Numbat)"`) ve bu bilgilerin Docker Hub ile eşleştiğini belirtin. Ardından çıkın.

```bash
cat /etc/os-release
exit
```

- `ubuntu:24.04` etiketli önceki sürümü indirin ve imaj listesini açıklayın.

```bash
docker image pull ubuntu:24.04
docker image ls
```

- `ubuntu` imajını inceleyin ve özelliklerini açıklayın.

```bash
docker image inspect ubuntu
docker image inspect ubuntu:24.04
```

- Docker imajlarını hem terminalden hem de Docker Hub üzerinden arayın.

```bash
docker search ubuntu
```


### Örmek Çalışma-2 - Oluşturulan imajın Docker Hub a gönderilmesi

- `python:alpine` tabanlı bir Dockerfile ile Python Flask uygulama imajı oluşturun ve bunu Docker Hub’a gönderin.

- Gerekli dosyaların tutulacağı bir klasör oluşturun.

```bash
cd ../docker-03-hands-on # bir üst dizine çıkalım
mkdir cloud_web
cd cloud_web
```

- Aşağıdaki Flask uygulamasını `welcome.py` dosyasına kaydedin:



```python
from flask import Flask
app = Flask(__name__)
@app.route("/")
def hello():
    return "<h1>Welcome to Cloud BootCamp</h1>"
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
```

- Veya Aşağıdaki `echo` komutu ile Flask kodunu `welcome.py` dosyasına yazabilirsin:

```python
echo 'from flask import Flask
app = Flask(__name__)
@app.route("/")
def hello():
    return "<h1>Welcome to Cloud BootCamp, Hello From Docker</h1>"
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)' > welcome.py
```

- Gerekli paketleri belirten bir `Dockerfile` oluşturun:

```Dockerfile
RUN apt-get update -y
RUN apt-get install python3 -y
RUN apt-get install python3-pip -y
RUN pip3 install Flask --break-system-packages
COPY . /app
WORKDIR /app
CMD python3 ./welcome.py'
```

- `echo` komutu ile `Dockerfile` oluşturma.

```Dockerfile

echo 'FROM ubuntu
RUN apt-get update -y
RUN apt-get install python3 -y
RUN apt-get install python3-pip -y
RUN pip3 install Flask --break-system-packages
COPY . /app
WORKDIR /app
CMD python3 ./welcome.py' > Dockerfile
```

- Dockerfile’dan imajı oluşturun, uygun etiketle etiketleyin ve adım adım açıklayın:

```bash
docker build -t "dockerhub_username/flask-app:1.0" .
docker build -t "fevzitopcu/flask-app:1.0" .
docker image ls
```

- Oluşturulan imajı `welcome` adında bir konteyner olarak detached modda çalıştırın ve 80 portunu eşleyin:

```bash
docker run -d --name welcome -p 8080:80 dockerhub_username/flask-app:1.0
docker run -d --name welcome -p 8080:80 fevzitopcu/flask-app:1.0
docker container ls

http://localhost/
http://127.0.0.1/

```

- Docker Hub’a giriş yapın:

```bash
docker login
```

- İmajı Docker Hub’a gönderin:

```bash
docker push dockerhub_username/flask-app:1.0
docker push fevzitopcu/flask-app:1.0
```

- Daha küçük boyutta bir imaj oluşturmak için `python:alpine` tabanlı `Dockerfile-alpine` dosyasını oluşturun:

```Dockerfile
FROM python3:alpine
RUN pip install flask
COPY . /app
WORKDIR /app
EXPOSE 80
CMD python3 ./welcome.py
```

- `echo` komutu ile `Dockerfile-alpine` oluşturma.

```Dockerfile

echo 'FROM python:alpine
RUN pip install flask
COPY . /app
WORKDIR /app
EXPOSE 80
CMD ["python", "./welcome.py"]' > Dockerfile-alpine
```

- Yeni Dockerfile ile imajı oluşturun ve `2.0` etiketiyle etiketleyin:

```bash
docker build -t "dockerhub_username/flask-app:2.0" -f ./Dockerfile-alpine . 
docker build -t "fevzitopcu/flask-app:2.0" -f ./Dockerfile-alpine . 
docker image ls
docker push fevzitopcu/flask-app:2.0
```

- `dockerhub_username/flask-app:1.0` ile oluşturlan uygulama yaklaşık 800MB iken `dockerhub_username/flask-app:2.0` ile oluşturlan sadece 91MB’dır.

- Yeni imajı `welcome-light` adında bir konteyner olarak çalıştırın:

```bash
docker run -d --name welcome-light -p 8090:80 dockerhub_username/flask-app:2.0
docker run -d --name welcome-light -p 8090:80 fevzitopcu/flask-app:2.0
docker ps

http://127.0.0.1:8090/
http://localhost:8090/
```

- `welcome` konteynerini durdurun ve silin:

```bash
docker stop welcome && docker rm welcome
docker stop welcome-light && docker rm welcome-light
```

- Yeni imajı Docker Hub’a gönderin:

```bash
docker push dockerhub_username/flask-app:2.0
```

- Aynı imajı farklı etiketlerle etiketleyebilirsiniz:

```bash
docker image tag dockerhub_username/flask-app:2.0 dockerhub_username/flask-app:latest
```

- İmajları `image_id` kullanarak veya `docker system prune -a`komutu ile yerelden silin:


## Bölüm 4 - Multi-Stage Dockerfile Oluşturma

### 🎯 Amaç

Multi-stage build ile minimum boyutta, sade ve güvenli imajlar oluşturmayı öğrenmek.

### ❓ Multi-Stage Neden Kullanılır?

- Build sırasında gerekli ama çalışmada gereksiz dosyalar imajdan çıkarılır.
- İmaj boyutu ciddi oranda küçülür.
- Daha güvenli ve dağıtıma hazır hale gelir.

### 🧪 Uygulama: Go ile Multi-Stage Build

### Proje Yapısı

```
multiStage/
├── main.go
└── Dockerfile
```

```bash
cd ../docker-03-hands-on # bir üst dizine çıkalım
mkdir multiStage
cd multiStage
```
### main.go

- `main.go` isimli bir dosya oluşturalım ve içine aşağıdaki kodu yazalım

```go
package main
import "fmt"

func main() {
    fmt.Println("Multi-stage Dockerfile ile derlendi!")
}
```

### Dockerfile-single stage

- `Dockerfile-singlestage` isimli dosya oluşturalım ve içini aşağıdaki gibi dolduralım.

```Dockerfile
# Hem derleme hem çalıştırma için tek bir base image
FROM golang:1.21

WORKDIR /app

# Uygulama kodunu kopyala
COPY . .

# Uygulamayı derle
RUN go build -o myapp main.go

# Uygulamayı çalıştır
CMD ["./myapp"]
```


- `Dockerfile` isimli dosya oluşturalım ve içini aşağıdaki gibi dolduralım.

### Dockerfile

```Dockerfile
# Build aşaması
FROM golang:1.21 AS builder

WORKDIR /app
COPY . .
RUN go build -o myapp main.go

# Çalışma aşaması
FROM debian:bullseye-slim

WORKDIR /app
COPY --from=builder /app/myapp .

CMD ["./myapp"]
```

### Komutlar

```bash
docker build -t single-go-app -f ./Dockerfile-singlestage .
docker build -t multi-go-app .

docker images

docker run multi-go-app
docker run single-go-app
```

### 💡 Açıklama

- `AS builder`: İlk imaj için bir takma ad verilir.
- `COPY --from=builder`: Derlenmiş binary, ikinci imaja aktarılır.
- Sonuç: Sadece çalıştırılabilir dosya içeren hafif bir imaj elde edilir.

---

### 📌 Sonuç

- Dockerfile talimatlarının hem temel hem ileri düzey farklarını öğrendik.
- `CMD`, `ENTRYPOINT`, `ENV`, `ARG`, `COPY`, `ADD` gibi komutların farklarını kavradık.
- Multi-stage build ile gerçek hayata uygun ve profesyonel bir imaj üretimi gerçekleştirdik.

Bu bilgiler, Docker ile sağlam ve ölçeklenebilir uygulamalar geliştirmenin temelini oluşturur.



## Bölüm 5 - Çalışan konteynerları durdurma ve herşeyi temizleme

```bash
docker ps
docker ps -a
docker stop container_id
docker image rm image_id
```

- remove and stop all containers

```bash
docker stop $(docker ps -a -q) #çalışan tüm konteynerları stop eder.
docker rm $(docker ps -a -q)   # stop edilen tüm conteynerları siler
docker system prune -a # herşeyi temizle

```

