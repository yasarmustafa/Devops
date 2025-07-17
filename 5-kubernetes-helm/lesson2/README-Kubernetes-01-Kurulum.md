# Hands-on Kubernetes-01 : Kubernetes Kurulum

Bu dökümanda Docker kurulumu ve basit operasyonların uygulanması ile ilgili yönergeler bulunmaktadır.

## Outline

- Bölüm 1 - Minikube Kurulumu

- Bölüm 2 - Kubeadm ile Kubernetes Cluster Kurulumu 

- Bölüm 3 - Kuberbetes VS Code Eklentisi 

- Bölüm 4 - Kuberbetes Play Labs Kullanımı (https://labs.play-with-Kuberbetes.com/)


## Bölüm 1- Minikube Kurulumu

- MiniKube için Ön Gereksinimler:

```text
2 CPUs or more
2GB of free memory
20GB of free disk space

Container or virtual machine manager, such as: Docker, QEMU, Hyperkit, Hyper-V, KVM, Parallels, Podman, VirtualBox, or VMware Fusion/Workstation

Sanallaştırma olarak Docker veya hperv veya Virtualbox tavsiye edilir. Bilgisayarlarımızda docker desktop kurulu olsuğu için sanallaştırma katmanı olarak kullanılacaktır.

```

- Minikube yüklemek için  şu web adresine gidelim `https://minikube.sigs.k8s.io/docs/start/`

- Windows Choco Paket Manager ile Kurulumu:

```bash
choco install minikube
```

- MacOS Homebrew Paket Manager ile Kurulumu:

```bash
brew install minikube
```

- Linux Homebrew Paket Manager ile Kurulumu:

```bash
https://minikube.sigs.k8s.io/docs/start/

```

## Bölüm 2- Kubeadm ile Kubernetes Cluster Kurulumu

- On-prem ortamındaki kurulumu yapmak için iki tane sanal makina açıyoruz. Bu makinaları AWS ortamında EC2 olarak veya multipass ile localimizde oluşturuyoruz.



### Multipass ile localde sanal makina oluşturma

- "https://canonical.com/multipass/install" adresine giderek kullandığımız İşletim sistemine (macos veya Windows) göre kurulum dosyasını indiriyoruz.

### Multipass Kurduktan Aşağıdaki işlemleri yapıyoruz.

#### Sanal Makine Oluşturma 
- Kubernetes cluster kurulumu yapmak için multipass ile master ve worker adında iki sanal makine oluşturuyoruz.

```bash
$ multipass launch --name master -c 2 -m 2G -d 10G
$ multipass launch --name worker -c 2 -m 2G -d 10G
```

```bash
$ multipass delete master # master inscatace siler
$ multipass delete worker 
$ multipass purge # silinen tüm dosyaları temizler

```
- Master node'a bağlanıp ağaıdaki komutla hostname tanımlanır:

```bash
multipass shell master
sudo hostnamectl set-hostname master
bash
```
- Başka bir terminalde Worker node'a bağlanıp ağaıdaki komutla hostname tanımlanır:

```bash
multipass shell node
sudo hostnamectl set-hostname node
bash
```


### 0- Sanal Makine Oluşturma - AWS ortamında sanal makina oluşturma

- iki tane EC2 makinayı konsoldan oluşturuyoryuz ve vscode ile makinalara uzaktan bağlanıyoruz. Ubuntu makina konfigurasyonu aşağıdaki gibi olmalı

```bash
- master-nodes ve worker nodes için iki makina ayağa kaldırıyoruz.
- image: ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-20250610
- instance type: t2.medium (2vCPU 4GiB Memory)
- Security Group Inbound Rules Ports: ( 22, 2379-2380, 10250, 10259, 6443, 10257, 30000-32767)
- Storage: 20 GiB gp3
- KeyPem: Kendinize ait keypem seçin
```


- Master node'a bağlanıp ağaıdaki komutla hostname tanımlanır:

```bash
$ sudo hostnamectl set-hostname master
$ bash
```
- Başka bir terminalde Worker node'a bağlanıp ağaıdaki komutla hostname tanımlanır:

```bash
$ sudo hostnamectl set-hostname node
$ bash
```

---

### Aşağıdaki işlemleri Her iki Makina için Yapıyoruz:

#### 1- Kernel Modül Aktifleştirme ve Swap Kapatma
- Kubernetes'in ağa erişim ve forwarding ayarlarını yapabilmesi için gerekli kernel modülleri yükleniyor.
- Swap devre dışı bırakılıyor çünkü Kubernetes swap alanını desteklemez.

```bash
$ sudo modprobe overlay
$ sudo modprobe br_netfilter
```

- Modüllerin her yeniden başlatmada yüklenmesini sağlamak için:

```bash
$ cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
```

- Sistem ağ ayarları tanımlanıyor:

```bash
$ cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
```

- Değişikliklerin uygulanması:

```bash
$ sudo sysctl --system
```

- Swap kapatılıyor:

```bash
$ sudo swapoff -a
$ free -m
$ sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
```

---

#### 2- Containerd Kurulumu
- Kubernetes tarafından container çalıştırmak için kullanılan container runtime'larından biri olan containerd kuruluyor ve sistemd ile entegre hale getiriliyor.

```bash
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
$ echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
$ sudo apt update
$ sudo apt install containerd.io
$ sudo systemctl daemon-reload
$ sudo systemctl enable --now containerd
$ sudo systemctl start containerd
$ sudo mkdir -p /etc/containerd
$ sudo su -
$ containerd config default | tee /etc/containerd/config.toml
$ exit
$ sudo sed -i 's/            SystemdCgroup = false/            SystemdCgroup = true/' /etc/containerd/config.toml
$ sudo systemctl restart containerd
```

---

#### 3- Kubeadm, Kubelet, Kubectl Kurulumu
- Kubernetes bileşenleri kuruluyor. `kubeadm` cluster kurmak için, `kubelet` node üzerindeki servisleri yönetmek için ve `kubectl` cluster ile iletişime geçmek için kullanılır.
- Güvenlik duvarı portları açılıyor.

```bash
komut satırı haline getirilmiş komutlar ec2 için geçerli değildir. Multipass sanal makina kurduysanız kullanmanı zgerekir.
# $ sudo ufw allow 6443/tcp
# $ sudo ufw allow 2379:2380/tcp
# $ sudo ufw allow 10250/tcp
# $ sudo ufw allow 10259/tcp
# $ sudo ufw allow 10257/tcp
$ sudo apt-get update
$ sudo apt-get install -y apt-transport-https ca-certificates curl
$ sudo mkdir -p -m 755 /etc/apt/keyrings
$ curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
$ echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
$ sudo apt-get update
$ sudo apt-get install -y kubelet kubeadm kubectl
$ sudo apt-mark hold kubelet kubeadm kubectl
```

---

#### 4- Kubernetes Cluster Kurulumu - (Bu aşamadan sonra MAsTER NODE da uyguluyoruz)
- Master node, `kubeadm` ile initialize ediliyor.
- Pod network aralığı belirleniyor. Komutta <MASTER_IP_ADRESS> belirtilen alana master node IP adresini yazın.

```bash
$ sudo kubeadm config images pull
$ sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=<MASTER_IP_ADRESS> --control-plane-endpoint=<MASTER_IP_ADRESS>
$ sudo kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.31.80.214 --control-plane-endpoint=172.31.80.214
```

- Not:

 Kubeadm init işlemi tammalandıktan sonra master makina da aşağıdaki gibi bir çıktı alacaksınız.

 ```bash
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

You can now join any number of control-plane nodes by copying certificate authorities        
and service account keys on each node and then running the following as root:

  kubeadm join 172.31.80.214:6443 --token dygwwc.d6savw9lqg7yezpl \
        --discovery-token-ca-cert-hash sha256:af6d26ba89d3fccdef62dd809068094d184d3718bda83e581b9f1e81b7990ac1 \
        --control-plane

Then you can join any number of worker nodes by running the following on each as root:       

kubeadm join 172.31.80.214:6443 --token dygwwc.d6savw9lqg7yezpl \
        --discovery-token-ca-cert-hash sha256:af6d26ba89d3fccdef62dd809068094d184d3718bda83e581b9f1e81b7990ac1
ubuntu@master:~$ 
 ```




- Kubectl konfigürasyonu yapılıyor:

```bash
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
- masternode kurulduktan sonra çıkan komutulara dikkat edelim. 

- Calico network plugin'i kuruluyor, bu şekilde networking alt yapısını yönetecek bir plug-in kuruyoruz.

```bash
$ kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/tigera-operator.yaml
$ kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.1/manifests/custom-resources.yaml
```

- Kubernetes çalışıp çalışmadığını ve node ları kontrol edelim.

```bash
kubectl cluster-info
kubectl get node
kubectl help
```

## Bölüm 3- VS Code Kubernetes ve YAML Eklentisini ekliyoruz.

- VS code ekranımızda Extentions Kısmına Giriyoruz. (CRTL+SHIFT+X)
- Arama çubuğuba "Kubernetes" yazıyoruz.
- İlk çıkan Microsoft tarafında sunulan eklentiyi install diyerek yüklüyoruz.
- YAML eklentisini yüklüyoruz.

## Bölüm 4- Kubernetes Play Labs Kullanımı (https://labs.play-with-k8s.com/)

- Not: Bu browser tabanlı Kubernetes oyun alanı Docker oyun alanı kadar stabil değil, ondan dolayı çok tavsiye etmiyoruz ancak bilgi amaçlı burad abulunmaktadır.

- Bilgisayarnıza Kubernetes yüklemeden Kubernetes deneyimleyebileceğimiz ve browser üzerinden çalışan bir ortam bulunuyor. Aşağıdaki linke tıklanayarak Docker hub veya github bilgileri ile giriş yapıyoruz ve oluşturduğumuz cluster ı dört saat boyunca kullanıyoruz.

https://labs.play-with-k8s.com/


