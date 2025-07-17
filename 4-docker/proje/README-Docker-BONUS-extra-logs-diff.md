# Hands-on Docker-14 : `docker logs`, `top`, `stats`, ve `diff` Komutları

Bu çalışmanın amacı, Docker container’larını izlemek ve teşhis etmek için kullanılan `logs`, `top`, `stats`, ve `diff` komutlarının kullanımını öğretmektir.

---

## 🎯 Öğrenme Hedefleri

Bu uygulama sonunda katılımcılar:

- `docker logs` ile container loglarını görüntülemeyi,
- `docker top` ile container içindeki aktif işlemleri listelemeyi,
- `docker stats` ile container kaynak kullanımını izlemeyi,
- `docker diff` ile container dosya sistemindeki değişiklikleri tespit etmeyi öğreneceklerdir.

---

## 🧭 İçerik

- Bölüm 1 - Uygulama Ortamını Hazırlama
- Bölüm 2 - `docker logs` Komutu
- Bölüm 3 - `docker top` Komutu
- Bölüm 4 - `docker stats` Komutu
- Bölüm 5 - `docker diff` Komutu
- Bölüm 6 - Özet

---

## 🔧 Bölüm 1 - Uygulama Ortamını Hazırlama

Test yapabilmek için log üreten bir container oluşturalım:

```bash
#docker run -d --rm --name logtest-container busybox sh -c "while true; do echo Merhaba Docker ; sleep 2; done"
docker run -d --rm --name logtest-container busybox sh -c "while true; do echo \$(date '+%Y-%m-%d %H:%M:%S') Merhaba Docker; sleep 2; done"
docker run -d --rm --name logtest-container busybox sh -c "while true; do echo \$(TZ='UTC-3' date) Merhaba Docker; sleep 2; done"
```

Bu komut:
- Arka planda çalışan (`-d`) bir container oluşturur,
- Container içinde sonsuz döngüyle `Merhaba Docker` mesajını her 2 saniyede bir yazar,
- Bu sayede log, CPU ve diff testleri için uygun bir ortam sağlar.

---

## 📜 Bölüm 2 - `docker logs` Komutu

### Açıklama:

`docker logs` komutu, bir container’ın stdout ve stderr çıktılarını görüntüler. Loglar, container yeniden başlatılana veya silinene kadar saklanır (log driver varsayılan olarak `json-file`).

### Kullanım:

```bash
docker logs logtest-container
```

🔍 Bu komut, container içindeki `echo Merhaba Docker` çıktısını gösterir.

### Canlı log takibi:

```bash
docker logs -f logtest-container
```

`-f` bayrağı ile canlı log akışı (tail -f gibi) izlenebilir.

### Sadece son satırlar:

```bash
docker logs --tail 5 logtest-container
```

Son 5 log satırını getirir.

### Belirli zamandan sonra:

```bash
docker logs --since 10s logtest-container
```

Son 10 saniyelik logları getirir.

---

## 🧠 Bölüm 3 - `docker top` Komutu

### Açıklama:

Container içinde çalışan işlemleri (process) listeler. Tıpkı Linux’ta `ps` komutuna benzer.

### Kullanım:

```bash
docker top logtest-container
```

🔍 Çıktı olarak container içinde hangi işlemlerin (PID, kullanıcı, komut vs.) çalıştığını görebilirsiniz.

Örnek çıktı:
```
UID        PID  PPID  C STIME TTY          TIME CMD
root       1234 1230  0 00:00 ?        00:00:00 sh -c while true...
```

---

## 📊 Bölüm 4 - `docker stats` Komutu

### Açıklama:

Container’ların gerçek zamanlı kaynak kullanım istatistiklerini (CPU, bellek, ağ, disk I/O) gösterir.

### Kullanım:

```bash
docker stats logtest-container
```

Çıktı:
```
CONTAINER ID   NAME               CPU %     MEM USAGE / LIMIT    NET I/O        BLOCK I/O
a1b2c3d4e5f6   logtest-container  0.10%     1.2MiB / 2GiB         1.2kB / 0B     0B / 0B
```

### Tüm container'lar için:

```bash
docker stats
```

> Bu komut `htop` benzeri bir izleme sağlar, container’lar üzerinde anlık performans kontrolü yapmak için çok kullanışlıdır.

---

## 🧬 Bölüm 5 - `docker diff` Komutu

### Açıklama:

Container’ın, bağlı olduğu imaja göre hangi dosyaların **değiştiğini**, **eklendiğini** veya **silindiğini** gösterir.

### Örnek:

Yeni bir container oluşturalım ve bazı değişiklikler yapalım:

```bash
docker run -it --name diff-example-container ubuntu bash
```

Container içindeyken:

```bash
touch /tmp/yeni-dosya.txt
rm /etc/issue
```

Çıkmak için `exit` yazın.

### Değişiklikleri listele:

```bash
docker diff diff-example-container
```

Olası çıktı:
```
C /tmp
A /tmp/yeni-dosya.txt
D /etc/issue
```

| Simge | Anlamı |
|-------|--------|
| A     | Yeni dosya eklendi |
| D     | Dosya silindi |
| C     | Dosya değiştirildi |

---

## 📦 Bölüm 6 - Özet

| Komut            | Açıklama |
|------------------|----------|
| `docker logs`    | stdout/stderr çıktısını gösterir |
| `docker top`     | Container içindeki işlemleri listeler |
| `docker stats`   | Gerçek zamanlı kaynak kullanımını gösterir |
| `docker diff`    | Dosya sistemindeki değişiklikleri gösterir |

---

## 📝 Ekstra Bilgi

- `docker logs` yalnızca `json-file` veya `local` log driver kullanan container’lar için geçerlidir.
- `docker stats`, uzun süreli container izleme için değil, anlık teşhis için uygundur.
- `docker diff` sadece *çalıştırılmış* (veya durdurulmuş) ama **silinmemiş** container’lar için kullanılabilir.

---

Hazırlayan: Fevzi Topcu  
Tarih: Mayıs 2025  
Konu: Docker İzleme ve Teşhis Komutları  
Düzey: Başlangıç / Orta Seviye

