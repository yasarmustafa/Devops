
# Hands-on Docker-07 : Docker Networking

Bu uygulamalı eğitimin amacı, öğrencilere Docker'da ağ yapılandırmaları hakkında hem temel hem de ileri düzey bilgileri kazandırmak, container'lar arası iletişimi yönetebilmeyi öğretmektir.

---

## 🎯 Öğrenme Hedefleri

Bu uygulamalı eğitimin sonunda öğrenciler:

- Docker'daki ağ sürücülerini (network drivers) tanıyabilecek (bridge, host, none, overlay),
- Docker container’larını özel ağlarda çalıştırabilecek,
- Farklı container’lar arasında isimle (DNS üzerinden) iletişim sağlayabilecek,
- Overlay network ile farklı host’lardaki container’ları konuşturabilecek,
- `docker network` komutlarını etkin şekilde kullanabileceklerdir.

---

## 🧭 İçerik

- Bölüm 1 - Docker'da Ağ Sürücüleri (Network Drivers) Tanıtımı
- Bölüm 2 - Özel Ağ (User-defined Bridge) Oluşturma ve Kullanma
- Bölüm 3 - Farklı Ağlardaki Container’ların İletişimi
- Bölüm 4 - Host ve None Ağ Sürücülerinin Kullanımı
- Bölüm 5 - Container’lar Arası DNS Çözümleme

---

## 🧩 Bölüm 1 - Docker'da Ağ Sürücüleri (Network Drivers) Tanıtımı

- Docker, container’ların birbirleriyle iletişim kurmasını sağlayan birkaç yerleşik ağ sürücüsü sunar. Bunlar şunlardır:

- **bridge**:
    Docker'ın standart varsayılan ağıdır. docker run ile konteyner başlattığında, başka bir ağ belirtmezsen bu ağa bağlanır. Konteynerler arasında private iletişim sağlar.

- **host**: 
    Konteyneri host’un ağına bağlar. Yani konteyner, host'un IP'sini ve portlarını doğrudan kullanır. Linux üzerinde çalışır, Windows’ta desteklenmez. Performans avantajı vardır ama port çakışmalarına açıktır.
- **none**:
    Konteyneri herhangi bir ağla bağlamaz. Ağ izolasyonu gerekirken (örneğin özel güvenlik senaryolarında) kullanılır.
- **overlay**: 
    Çok host’lu yapılarda farklı makinelerdeki container’ları aynı ağda gösterir (Swarm gerektirir).
- **docker_gwbridge**:
    Bu ağ, Docker Swarm modunda otomatik olarak oluşturulur. Overlay network'lerin dış dünya ile iletişimini sağlar. Normal container çalıştırmada kullanılmaz.
- **ingress**:
    Bu da Swarm için özel olarak oluşturulan bir overlay network’tür. Ingress routing yapısı sayesinde, dış istekleri ilgili servise yönlendirmek için kullanılır.

```bash
# Docker'da mevcut tüm ağları listeleyelim
docker network ls
```

```bash
# Varsayılan bridge ağı hakkında detaylı bilgi alalım
docker network inspect bridge
```

### Default Network kullanarak iki container başlatalım:

```bash
docker run -dit --name container1  alpine sh
docker run -dit --name container2  alpine sh
```

- `-d` arka planda çalıştırır, `-it` terminal etkileşimi sağlar, `alpine` hafif bir Linux dağıtımıdır, `sh` ile terminal başlatırız.

```bash
# container1 içine girip container2'ye isimle ping atalım
docker exec -it container1 sh
ping container2
```

- container ismi ile ping atmayı denediğimizde iki konteyner birbirini göremeyecektir. 

```bash
docker inspect container1 # container1 i incleyelim
docker exec -it container1 hostname -i # ip adresini öğrenelim
$ 172.17.0.2
docker exec -it container2 hostname -i # ip adresini öğrenelim
$ 172.17.0.3

docker exec -it container1 sh # container1 e bağlanlım
ping container2_IP
```
- default networktedeki konteynerlar birbiri ile IP üzerinden haberleşebilir.

---
## 🧩 Bölüm 2 - Özel Ağ (User-defined Bridge) Oluşturma ve Kullanma

- Docker, kullanıcı tanımlı ağlar oluşturmanıza olanak tanır. Bu sayede container’lar arasında daha kontrollü ve güvenli bir iletişim sağlayabilirsiniz.

```bash
# Yeni bir özel ağ (bridge tipi) oluşturalım
docker network create --driver bridge my_custom_net
```

```bash
# Oluşturduğumuz ağın listelendiğinden emin olalım
docker network ls
```

### Şimdi bu ağı kullanarak iki container başlatalım:

```bash
docker run -dit --name container3 --network my_custom_net alpine sh
docker run -dit --name container4 --network my_custom_net alpine sh
```

- `-d` arka planda çalıştırır, `-it` terminal etkileşimi sağlar, `alpine` hafif bir Linux dağıtımıdır, `sh` ile terminal başlatırız.

```bash
# container1 içine girip container2'ye isimle ping atalım
docker exec -it container3 sh
ping container4
```

- Açıklama: Aynı user-defined ağda olan container’lar birbirlerinin ismini kullanarak DNS çözümlemesi ile haberleşebilir. Aşağıdaki komutları girerek containerlerin bağlı olukları network ağlarını inceleyelim.

```bash
docker inspect container1
docker inspect container2
docker inspect container3
docker inspect container4

```
---

## 🧩 Bölüm 3 - Farklı Ağlardaki Container’ların İletişimi

Bu bölümde container’lar farklı ağlarda başladığında nasıl haberleşemediklerini ve birden fazla ağa bağlanarak nasıl iletişim kurabileceklerini göreceğiz.

```bash
# Yeni bir ağ daha oluşturalım
docker network create another_net
```

```bash
# Bu yeni ağda yeni bir container oluşturalım
docker run -dit --name container5 --network another_net alpine sh
```

```bash
# container3 üzerinden container5'e ping atmayı deneyelim
docker exec -it container3 ping container5  # Bu deneme başarısız olur çünkü aynı ağda değiller
```

- Şimdi container5'ü, container3’in bulunduğu `my_custom_net` ağına da bağlayalım:

```bash
docker network connect my_custom_net container5
```

```bash
# Artık container1'den container3'e ping başarılı olur
docker exec -it container3 ping container5
```

- Açıklama: Bir container birden fazla ağa bağlanabilir. Bu yöntemle farklı ağlar arasında geçiş yapılabilir.

---

### Çalışan cantainer ları durduralım ve silelim

- remove and stop all containers

```bash
docker stop $(docker ps -a -q) 
docker rm $(docker ps -a -q) 

docker network prune # oluşturulan networkleri sil
```

## 🧩 Bölüm 4 - Host ve None Ağ Sürücülerinin Kullanımı

### Host Network

Bu modda container, host makinenin IP’sini kullanır. Bağlantılar container’dan değil, doğrudan host üzerinden yapılır.

```bash
docker run --rm -dit --name my_nginx --network host nginx sh
docker exec -it my_nginx sh
```

- `ifconfig` veya `ip a` komutlarıyla IP adresi kontrol edilebilir.

- Ağ yapılandırması için:

```bash
docker exec -it my_nginx sh
apt-get update
apt-get install net-tools
ifconfig
```
- Host içinde ifconfig çıktısını alın ve karşılaştırın:

```bash
ifconfig
```

- Konteyneri durdurun:

```bash
docker container stop my_nginx
```
### Host Network örnek

- Bir nginx konteyneri çalıştırın:

- Host ağıyla nginx çalıştırın:

```bash
docker run --rm -dit --network host --name my_nginx nginx
docker inspect my_nginx | grep -i networkmode
```

- Ağ yapılandırması için:

```bash
docker container exec -it my_nginx sh
apt-get update
apt-get install net-tools
ifconfig

http://192.168.65.255/
http://localhost
```

- Host içinde ifconfig çıktısını alın ve karşılaştırın:

```bash
ifconfig
```

- Konteyneri durdurun:

```bash
docker container stop my_nginx
```

### None Network

- Bu modda container tamamen izole edilir. Hiçbir ağa bağlanmaz.

- Bu tür container’lar genellikle güvenlik veya özel test senaryoları için kullanılır.

```bash
docker run --rm -it --network none --name nullcontainer alpine
ifconfig
ping -c 4 google.com
```
---


## 🧩 Bölüm 6 - Container’lar Arası DNS Çözümleme

- 🎯 Amaç:
    Docker’ın kullanıcı tanımlı (user-defined) ağlarında otomatik olarak sağladığı DNS (isim çözümleme) yeteneğini anlamak ve test etmek.
    Docker’ın kullanıcı tanımlı ağlarında dahili bir DNS sistemi bulunur.


- 🔍 Temel Bilgi: Docker DNS Nedir?
        Docker, bridge driver kullanılarak oluşturulmuş user-defined ağlar içinde, container’ların birbirini isimleriyle bulabilmesini sağlayan yerleşik bir DNS sunucusu çalıştırır.

        Bu özellik sayesinde:
        IP adresi bilmeye gerek kalmaz,
        Sadece container adıyla diğer konteynerlere erişilebilir.
        Varsayılan bridge ağı bu özelliğe sahip değildir. Sadece kullanıcı tanımlı bridge ağları DNS çözümlemesi sağlar.


### 1. Kullanıcı tanımlı bir ağ oluştur:

```bash
docker network create my_dns_net
```
###  2. İki container başlat (aynı ağda)

```bash
docker run -dit --name dns_test1 --network my_dns_net alpine sh
docker run -dit --name dns_test2 --network my_dns_net alpine sh
```

```bash
# dns_test1 içine girip isim çözümlemeyi deneyelim
docker exec -it dns_test1 sh
ping dns_test2
```

- Açıklama: Docker container’ların isimlerini ağ içindeki IP adreslerine otomatik olarak çevirir.

```bash
# DNS yapılandırmasını container içinde görüntüleyelim
cat /etc/resolv.conf

# Generated by Docker Engine.
# This file can be edited; Docker Engine will not make further changes once it
# has been modified.

nameserver 127.0.0.11
options ndots:0

# Based on host file: '/etc/resolv.conf' (internal resolver)
# ExtServers: [host(192.168.65.7)]
# Overrides: []
# Option ndots from: internal
```
- Docker'ın yerleşik DNS sunucusu 127.0.0.11 IP adresiyle çalışır. Bu adres, container içinde çalışan DNS proxy’dir.

### DNS’in Çalışmadığı Durumlar

- Container’lar farklı ağlardaysa (biri bridge biri host gibi),
- Container `--network none` ile başlatılmışsa,
- Elle `/etc/hosts` dosyasına eklenmemişse.

---

## ✅ Özet

Bu uygulamalı çalışmada şunları öğrendik:

- Docker’ın ağ yapılarını (network drivers) nasıl kullandığını,
- Container’ların özel ağlar ile nasıl haberleştiğini,
- DNS çözümleme ve isimle erişimin nasıl sağlandığını,
- Overlay network ile farklı host’lardaki container’ların nasıl konuşturulduğunu.

---

| Tavsiye                                           | Açıklama                        |
| ---------------------------------------------------| ------------------------------- |
| ✅ User-defined network kullan                    | DNS çözümleme sağlar            |
| ✅ Anlamlı container isimleri ver                 | `--name` ile                    |
| ✅ Çoklu servislerde Compose ile isimlendirme yap | DNS çözümleme otomatik olur     |
| ❌ IP adresine bağımlı olma                       | DNS sayesinde bağımsızlık kazan |


### 🧪 BONUS: DNS çözümlemesini nslookup ile test etmek

```bash
# Alpine’e bind-tools kur (içinde nslookup vardır):
docker exec -it dns_test1 sh
apk add bind-tools
nslookup dns_test2
```
```bash
$ docker exec -it dns_test1 sh
/ # nslookup dns_test2
Server:         127.0.0.11
Address:        127.0.0.11#53

Non-authoritative answer:
Name:   dns_test2
Address: 172.19.0.3
```

### Çalışan cantainer ları durduralım ve silelim

- remove and stop all containers

```bash
docker stop $(docker ps -a -q) 
docker rm -f $(docker ps -a -q) 
docker system prune -a # herşeyi temizle

```
---