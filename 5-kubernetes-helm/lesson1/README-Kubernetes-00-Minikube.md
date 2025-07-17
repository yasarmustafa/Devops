# 🧪 Hands-on: Minikube Temel Komutları + Add-ons ve CNI

Bu çalışma, Minikube ile Kubernetes kümesi oluşturmak, yönetmek, temel bileşenleri aktifleştirmek ve CNI eklentisi kurmak isteyen kullanıcılar için hazırlanmıştır.

---

## 🎯 Amaçlar

- Minikube kurulumu sonrası ilk kümenin başlatılması  
- Yeni küme oluşturma  
- Worker node ekleme (çoklu node simülasyonu)  
- Kaynak durumu izleme  
- Minikube eklentilerini (dashboard, metrics-server) aktif etme  
- Calico CNI kurulumu  
- Küme içi uygulama çalıştırma

---

## 📌 Ön Gereksinimler

- Minikube yüklü bir sistem  
- Docker veya VirtualBox gibi bir sanallaştırma aracı yüklü  
- `kubectl` komutu erişilebilir olmalı

---

## 🚀 1. Minikube Başlatma

```bash
minikube start
```

> Varsayılan ayarlar ile tek node’lu bir cluster oluşturur.

---

## 🧩 2. Minikube Add-ons Listeleme ve Başlatma

```bash
minikube addons list
minikube addons enable dashboard
minikube addons enable metrics-server
```

> Dashboard ve metrics-server bileşenleri etkinleştirilir.

---

## 🏗️ 3. Belirli Kaynaklarla Cluster Başlatma

```bash
minikube start --cpus=2 --memory=4096 --driver=docker
```

> 2 CPU, 4GB RAM ile Docker driver üzerinden cluster başlatır.

---

## 📛 4. Cluster'a Özel İsim Verme

```bash
minikube start -p my-cluster
```

> `my-cluster` adında yeni bir küme oluşturur.

---

## 🔁 5. Farklı Cluster’lar Arasında Geçiş

```bash
minikube profile list
minikube profile my-cluster
```

> Mevcut profilleri listeler ve `my-cluster` profiline geçiş yapar.

---

## 🧑‍🤝‍🧑 6. Worker Node Ekleme (Multi-node Minikube)

```bash
minikube start --nodes=3 -p multi-node-demo
kubectl get nodes
```

> 3 node'lu küme başlatılır ve doğrulanır.

---

## 🔧 7. Mevcut Cluster'a Worker Node Ekleme

```bash
minikube node add
```

---

## 🌐 8. CNI Plugin (Calico) Kurulumu - network için

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml
kubectl get pods -n kube-system
```

> Calico CNI eklentisi yüklenir.

---

## 🛑 9. Cluster’ı Durdurma

```bash
minikube stop
```

---

## ❌ 10. Cluster’ı Silme

```bash
minikube delete -p my-cluster
```

---


## 📦 11b. Küme Üzerinde Uygulama Çalıştırma

```bash
kubectl create deployment hello-minikube --image=nginxdemos/hello
kubectl expose deployment hello-minikube --type=NodePort --port=80
minikube service hello-minikube
```

---

## 🔍 12. Dashboard Kullanımı

```bash
minikube dashboard
```

---

## 🔁 13. Pod’lara Ulaşım / Servis Testi

```bash
minikube service list
minikube service <servis-adı>
```

---

## 🐳 14. Docker İçin Minikube Docker Environment

```bash
eval $(minikube docker-env)
docker images
```

---

## 📂 15. Minikube Logları Görüntüleme

```bash
minikube logs
```

---

## 🔧 16. Versiyon Kontrol

```bash
minikube version
kubectl version --client
```
