
# Hands-on Jenkins-03 : JOBs to JENKINSFILE

## 🎓 Öğrenme Hedefleri (Learning Outcomes)

Bu uygulamalı eğitimin sonunda katılımcılar:

* Jenkins yüklü bir sunucu oluşturabilecek,
* Jenkins sunucusuna Java, Maven, Docker gibi araçları manuel olarak kurabilecek,
* Maven projesi için Jenkins Free Style job'u oluşturabilecek,
* Maven komutları ile projeyi test ve package adımlarında çalıştırabilecek,
* Dockerfile kullanarak bir Java uygulamasını imaj haline getirip Docker Hub’a gönderebilecek,
* Jenkins üzerinden container deploy edebilecek,
* `Jenkinsfile` kullanarak basit bir pipeline tanımı oluşturabilecek,
* SCM (GitHub) üzerinden `Jenkinsfile` ile otomatik çalışan bir pipeline job yapılandırabileceklerdir.

---

## 📘 İçerik (Outline)

* **Bölüm 1** – Jenkins Sunucusunu Terraform ile Ayağa Kaldırma
* **Bölüm 2** – Maven Kurulumu (Manuel veya Jenkins Dashboard üzerinden)
* **Bölüm 3** – Java-Maven Free Style Job Oluşturma
* **Bölüm 4** – Maven ile Test ve Package Aşamaları
* **Bölüm 5** – Dockerfile ile Uygulamanın İmaj Haline Getirilmesi ve Docker Hub’a Gönderilmesi
* **Bölüm 6** – Docker Container olarak Uygulamanın Deploy Edilmesi
* **Bölüm 7** – Jenkins Üzerinden Basit Bir Pipeline Tanımı Yapma
* **Bölüm 8** – GitHub’daki `Jenkinsfile` ile Otomatik Pipeline Job Oluşturma

---

## Part 1 - Jenkins Sunucuyu AYağa kaldırma

> create-jenkins-server-tf klasöründeki terraform dosyalarını kullanarak 22 ve 8080 portları açık hazır jenkins yüklü makine ayağa kaldırarak kulanmaya başlayabilrsiniz.

## Part 2 - Maven paketlerini yükleyin

- **Yöntem-1**

> jenkins server'a manuel yükleme
  
```bash
sudo su
cd /opt
wget https://dlcdn.apache.org/maven/maven-3/3.9.11/binaries/apache-maven-3.9.11-bin.tar.gz
tar -zxvf apache-maven-3.9.11-bin.tar.gz
rm -f apache-maven-3.9.11-bin.tar.gz
ln -s /opt/apache-maven-3.9.11/bin/mvn /usr/bin/mvn # mvn komutunu herkesin erişebileceği şekilde /usr/bin içine linkle
exit
```

- **Yöntem-2** 

> Jenkins Dashboard > Manage Jenkins > Tools > Maven installations ;

- Add Maven
  - Name : maven-<version-number>
  - Install automatically seçili olsun. 
    - Version : son versiyonu seçin

Save 

## Part 3 - Creating Package Application - Free Style Maven Job

### Adım 1 - github repo'da örnek java uygulaması oluştruma

github reponuza giderek `https://github.com/JBCodeWorld/java-tomcat-sample` reposunu forklayın.  

---

### Adım 2 - compile

- Jenkins ana sayfasına giderek yeni bir job oluşturmak için `New Item` seçeneğine tıklayın.  

- `Java-Tomcat-Sample-Freestyle` adını girin, `free style project` seçeneğini işaretleyin ve `OK` butonuna tıklayın.  

    - General:
      - Description: This Job going to run Java-Tomcat-Sample Project.

    - Sourve Code Management:
      - Git:
      - Repo URL'si: https://github.com/<your-github-account-name>/java-tomcat-sample-main.git
      - Credentails: gerek yok, repomuz public.
       
    - Derlenecek Branch: `java-tomcat-sample-main` GitHub Reposundaki branch adı ile aynı olmalıdır. Eğer Reponuzun varsayılan branch adı "main" ise, "master" yerine "main" olarak değiştirin.  
    (`git status` komutunu vererek de hangi brach olduğunu görebilirsiniz.)

    - Build Steps:
      - Add build step:
        - invoke-top-level-maven:
        - Maven Version: maven
            mvn clean test
   
- `Apply` ve `Save` seçeneklerine tıklayın. `Build now` ile jobu çalıştırın ve `console output`u inceleyin.


---

### Adım 3 - package

> Uygulamayı paketleyeceğiz. Uygulama bir webapp uygulaması olduğu için .war uzantılı bir dosya oluşturacak.

- `Java-Tomcat-Sample-Freestyle` job'unu configure diyerek güncellleyin.

- Build steps kısmında add build step diyerek ikinci step'i oluşturun. 

    - Build Steps:
      - Add build step:
        - invoke-top-level-maven:
        - Maven Version: maven
            clean package

- `Apply` ve `Save` seçeneklerine tıklayın. `Build now` ile jobu çalıştırın ve `console output`u inceleyin.

---

### Adım 4 - build

> Uygulamayı Dockerfile ile build ederek imaj haline getireceğiz. 

### Adım 4.1 - Github repoda Dockerfile oluşturun.

```Dockerfile
# 1. Maven ile uygulamayı build et
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /app
COPY . .
RUN mvn clean package

# 2. Tomcat imajına geç
FROM tomcat:9.0-jdk17

# 3. War dosyasını Tomcat webapps klasörüne kopyala
COPY --from=builder /app/target/*.war /usr/local/tomcat/webapps/hello.war

# 4. Tomcat 8080 portunu dışa aç
EXPOSE 8080

# 5. Tomcat başlat
CMD ["catalina.sh", "run"]
```

### Adım 4.2 - DockerHub hesabınıza giderek `java-app-hub` adında bir private repo oluşturun.

### Adım 4.4 - Jenkins sunucusuna docker yükleyin.

```bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
sudo -u jenkins docker version # test etmek için, jenkins kullanıcısı docker'a erişebiliyor mu? 
```

### Adım 4.4 - imajı build etme

- `Java-Tomcat-Sample-Freestyle` job'unu configure diyerek güncellleyin.

- Build steps kısmında add build step diyerek üçüncü step'i oluşturun.  (imaj formatı: <docker-hub-kullanıcı-adı/repo-adı:tag>)

    - Build Steps:
      - Add build step:
        - Execute Shell:
            docker build -t <docker-hub-kullanıcı-adı>/java-app-hub:java-1.0 . 

- `Apply` ve `Save` seçeneklerine tıklayın. `Build now` ile jobu çalıştırın ve `console output`u inceleyin.

### Adım 4.3 - imajı kontrol etme

- Jenkins makinesine giderek `sudo docker image ls` komutuyla oluşan imajı görüntüleyin.

### Adım 5 - push

> Oluşturduğumuz imajı Docker Hub repomuza göndereceğiz.

- `Java-Tomcat-Sample-Freestyle` job'unu configure diyerek güncellleyin.

    - Build Environment:
       - Use secret text(s) or file(s)
    - Bindings:
       - Username and password (seperated)
          - username variable: USER
          - password variable: SIFRE
          - credentails: docker-hub (yukarıda oluşturduğunuz credential id)
       - Credentials
          - username with password
            - username: <dockerhub-kullanıcı-adınız>
            - şifre: <dockerhub-şifreniz>
            - ID: docker-hub


    - Build Steps:
      - Add build step:
        - Execute Shell:
            docker build -t <docker-hub-kullanıcı-adı:java-app-hub:java-1.0> .
            docker login -u $USER -p $SIFRE # güvenli değil uyarısı vercek direkt aşağıdaki şekilde de yazabilrisiniz.
            echo $SIFRE | docker login -u $USER --password-stdin
            docker push <docker-hub-kullanıcı-adı:java-app-hub:java-1.0>   # komut docker hub da var. ecr da ki gibi

- `Apply` ve `Save` seçeneklerine tıklayın. `Build now` ile jobu çalıştırın ve `console output`u inceleyin. 
- Docker Hub reponuzda imajın gelip gelmediğini kontrol edin.

### Adım 5 - deploy

- `Java-Tomcat-Sample-Freestyle` job'unu configure diyerek güncellleyin. Jobu build ettiğimizde tüm komutlar yeniden çalıştrılacak. Var olan imajı tekrar push ederken hata almamak adına versiyonu değiştirdik.

    - Build Steps:
      - Add build step:
        - Execute Shell:
            docker build -t <docker-hub-kullanıcı-adı:java-app-hub:java-2.0> .
            echo $SIFRE | docker login -u $USER --password-stdin
            docker push <docker-hub-kullanıcı-adı:java-app-hub:java-2.0>
            docker run -dp 80:8080 <docker-hub-kullanıcı-adı:java-app-hub:java-2.0>

- `Apply` ve `Save` seçeneklerine tıklayın. `Build now` ile jobu çalıştırın ve `console output`u inceleyin. 
- Docker Hub reponuzda imajın gelip gelmediğini kontrol edin.
- Jenkins servera giderek docker ps komutuyla containerı kontrol edin.
- Tarayıcıda http://<jenkins-server-public-ip>/hello ile de kontrol sağlayabilrisiniz. portu 80 verdiğim için ayrıca port belirtmedik.


böylelikle baştan sona bir dağıtımı jenkins joblarla adım adım manuel yapmış olduk.

---

# pipeline & jenkinsfile

## Bölüm 6 - Jenkins ile Basit Bir Pipeline Oluşturma  

- **Jenkins Dashboard'a gidin ve `"New Item"` butonuna tıklayarak yeni bir pipeline oluşturun.**  

- **Pipeline adı olarak** `"first-pipeline"` yazın, ardından **"Pipeline"** seçeneğini seçip **"OK"** butonuna tıklayın.  

- **Açıklama alanına** `"My first simple pipeline"` yazın.  

- **"Pipeline" bölümüne gidin**, aşağıdaki script'i girin, ardından **"Apply" ve "Save"** butonlarına tıklayın:  

```groovy
pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                echo "Cloud&Cloud - Sıfırdan Zirveye"
                sh 'echo second step'
                sh 'echo another step'                
                sh '''
                echo 'Multiline'
                echo 'Example'
                '''
                echo 'not using shell'
            }
        }
    }
}
```  

- **Proje sayfasına gidin ve `"Build Now"` butonuna tıklayarak pipeline'ı çalıştırın.**  

- **Pipeline çalıştırma sonucunu inceleyin.**  


## Bölüm 7 - Jenkinsfile ile Bir Jenkins Pipeline Oluşturma  

- **GitHub hesabınızda** `"jenkinsfile-pipeline-project"` adında **herkese açık bir repository oluşturun**.  

- **Yerel bilgisayarınıza** `"jenkinsfile-pipeline-project"` repository'sini klonlayın:  

```bash
git clone <your-repo-url>
```  

- **Yerel "jenkinsfile-pipeline-project" repository'sinde bir `Jenkinsfile` oluşturun** ve aşağıdaki pipeline script'ini içine kaydedin. Unutmayın, `"Jenkinsfile"` dosya adı büyük/küçük harf duyarlıdır.  

```groovy
pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                echo "Cloud&Cloud - Sıfırdan Zirveye"
                sh 'echo using shell within Jenkinsfile'
                echo 'not using shell in the Jenkinsfile'
            }
        }
    }
}
```  

- **Değişiklikleri commit edip GitHub repository’sine gönderin:**  

```bash
git add .
git commit -m 'added Jenkinsfile'
git push
```  

- **Jenkins Dashboard’a gidin ve `"New Item"` butonuna tıklayarak yeni bir pipeline oluşturun.**  

- **Pipeline adı olarak** `"pipeline-from-jenkinsfile"` yazın, ardından **"Pipeline"** seçeneğini seçip **"OK"** butonuna tıklayın.  

- **Açıklama alanına** `"Simple pipeline configured with Jenkinsfile"` yazın.  

- **"Pipeline" bölümüne gidin ve "Definition" alanında `"Pipeline script from SCM"` seçeneğini seçin.**  

- **"SCM" alanında `"Git"` seçeneğini işaretleyin.**  

- **Repository URL alanına, oluşturduğunuz GitHub repository’sinin URL’sini girin:**  

```text
https://github.com/<your_github_account_name>/jenkinsfile-pipeline-project/
```

- Script Path default Jenkinsfile gelir. **Unutmayın, `Jenkinsfile` dosyası repository’nin kök dizininde bulunmalıdır.**  

- **"Apply" ve "Save" butonlarına tıklayarak kaydedin.** 

- **Jenkins proje sayfasına gidin ve `"Build Now"` butonuna tıklayarak pipeline'ı çalıştırın.**  

---

