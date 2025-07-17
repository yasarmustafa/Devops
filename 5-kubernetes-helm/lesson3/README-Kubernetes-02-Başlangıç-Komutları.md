# Hands-on Kubernetes-02 : Kubernetes

- Bu döküman, Kubernetes'e giriş yapan kullanıcılar için hazırlanmış ve temel kavramların uygulamalı örneklerle desteklendiği bir çalışmadır. Aşağıdaki dört ana başlık altında, temel kubectl komutlarından Pod yaşam döngüsüne, namespace yönetiminden label/selectors kullanımına kadar Kubernetes'in temel yapı taşları ele alınmaktadır:

    Temel Komutlar ve Pod ile İlgili Uygulamalar: Pod oluşturma, listeleme, silme ve detay görüntüleme gibi günlük operasyon komutlarını içerir.
    Pod Yaşam Döngüsü: Pod’ların çalıştırılması, yeniden başlatılması ve başarısız olma durumları gibi aşamalarına dair örneklerle desteklenir.
    Namespace Kullanımı: Kaynakların izole yönetimini sağlamak için namespace kavramı ve farklı namespace’lerde çalışma senaryoları ele alınır.
    Labels, Selector ve Annotations: Kubernetes bileşenlerini etiketleme, gruplama ve açıklama ekleme yöntemleri detaylandırılır.

Her bölümde teorik bilginin yanı sıra, doğrudan uygulanabilir YAML dosyaları ve terminal komutlarıyla öğrenme süreci desteklenmiştir. Bu sayede hem kavramlar netleşir hem de pratik beceriler geliştirilir.

## Outline

- Bölüm 0 - Hazırlık
- Bölüm 1 - Temel Komutlar ve POD ile ilgili hands-on çalışmaları
- Bölüm 2 - POD Yaşam Döngüsü
- Bölüm 3 - NameSpace
- Bölüm 4 - Labels, Selector ve Annotations

## Bölüm 0- Ortamın hazırlanması ve Minikube Cluster Başlatılması

- Cluster Başlat ve node ları kontrol et.

```bash
minikube start
kubectl cluster-info
kubectl get nodes
```

- `~/Bootcamp/Devops/Kubernestes` Çalışma dizini altına çalışma klasörünü oluşturalım. Bu derl ile alakalı tüm çalışmlarımızı bu klasörde yapalım.

```bash
mkdir k8s-02-hands-on
cd k8s-02-hands-on
```

## Bölüm 1- Temel Komutlar ve POD ile ilgili hands-on çalışmaları.

### kube config

- kubeconfig, Kubernetes komut satırı aracı olan kubectl’in bir Kubernetes kümesine nasıl bağlanacağını bildiği yapılandırma dosyasıdır. Bu dosya sayesinde, kubectl bir veya birden fazla Kubernetes kümesiyle iletişime geçebilir.

```bash
kubectl config
kubectl config get-contexts # config içindenki context leri listeler, yanında yıldız olan seçili olandır
kubectl config current-contexts
kubectl config use-context minikube # hangi context e geçmek istiyorsanız onu seçiyorsunuz
```

- Kubeconfig Dosyasının İçeriği Nelerden Oluşur?

```yaml
apiVersion: v1
kind: Config
clusters:
- name: my-cluster
  cluster:
    server: https://192.168.1.100:6443
    certificate-authority-data: ...

users:
- name: admin-user
  user:
    client-certificate-data: ...
    client-key-data: ...

contexts:
- name: my-context
  context:
    cluster: my-cluster
    user: admin-user
    namespace: default

current-context: my-context

```

🔹 clusters: Bağlanılacak Kubernetes kümelerinin listesi
🔹 users: Bu kümelere bağlanacak kullanıcıların bilgileri
🔹 contexts: Hangi kullanıcıyla hangi kümeye bağlanılacağını belirten kombinasyon
🔹 current-context: kubectl komutlarının hangi kümeye/bağlama çalışacağını gösterir


### kubectl kullanımı

- Kubernetes cluster ve nodes hazır mı kontrol edelim.

```bash
kubectl
kubectl cluster-info # cluster ile iligli temel bilgi
kubectl get node # clusterdaki çalışan nodes bilgisi
kubectl --help
kubectl komut_ismi --help # komut kullanımı hakkında yardım verir
kubectl cp --help
kubectl run --help 

kubectl action object_type object_name options
kubectl delete pods my_firstpod
kubectl edit deployment my_deployment
```

- kubectl komutunu ile kullanaılabilen kısaltmalar:

|NAME          |SHORTNAMES|
|--------------|----------|
|deployments   |deploy
|events        |ev
|endpoints     |ep
|nodes         |no
|pods          |po
|services      |svc

```bash
kubectl get po
kubectl get pods -A # tüm namespace lerdeki podları listeler
kubectl get pods --all-namespaces # tüm namespace lerdeki podları listeler
kubectl get pods -n kube-system #kube-system namespace de çalışan podları listeler
kubectl get no
kubectl get deploy
```
- Kubernetes objeleri ile ilgili dokumantsayona ulaşmak için, objeler hakkında bilgi almak için

```bash
kubectl explain nodes
kubectl explain po
kubectl explain svc
kubectl explain deployment
```


- Kubectl Kubernetes api ile haberleşmeyi sağlayan CLI aracıdır. Kubectl temel komutları hakkında bilgi almak için aşağıdaki komutu girelim ve çıktıyı kontrol edelim.

```bash
kubectl
```
- Bazı temel komutlar

```bash
kubectl get nodes	# Kümedeki tüm node'ları listeler.
kubectl get pods	# Çalışan tüm pod’ları listeler (varsayılan namespace).
kubectl get all	  # Tüm temel objeleri listeler (pod, service, deployment vs).
kubectl describe pod POD_ADI	# Belirli bir pod’un detaylarını gösterir.
kubectl logs POD_ADI	# Pod’un loglarını gösterir.
kubectl get events	# Kümedeki olayları (event) listeler.
kubectl get namespaces	# Namespace'leri listeler.
```

## Kubernetes Objeleri

### Pod Oluşturma (Imperative):

- Kubernetes dünyasında oluşturulabilen en küçük obje pod'dur. Pod kubernetes in atamik birimidir.
- Her pod un eşsiz bir ID si vardır.
- Her pod un eşsiz bir IP si vardır.

- Aşağıdaki komutla `kubectl` aracı kullanılarak doğrudan komut satırından bir pod oluşturulur. `--restart=Never` parametresi, oluşturulan pod'un yeniden başlatılmaması gerektiğini belirtir. Bu genellikle tek seferlik pod'lar için kullanılır.

```bash
kubectl run myfirstpod --image=nginx --restart=Never
kubectl run mysecondpod --image=nginx:latest --restart=Never --port=80 --labels="name=frontend"
```
- Aşağıdaki komutları girerek pod ile ilgili detayları inceleyelim.

```bash
kubectl cluster-info
kubectl get pods # default namespace de bulunan podları listeler
kubectl get pods -o wide # default namespace de bulunan podlar hakkında detaylı bilgi verir
kubectl get pods -A # tüm namespacelerdeki podları listeler
kubectl get pods --all-namespaces # tüm namespacelerdeki podları listeler
kubectl get pods -n default -o wide # default namespace de detaylı çıktı verir
kubectl get pods -o yaml # pod ile alakalı yaml formatında  detaylı çıktı verir
kubectl get pods myfirstpod -o json # detaylı çıktı verir
kubectl explain k8s_object_name # obje hakkında bilgi verir
kubectl explain pods # obje yapısı hakkında hakkında bilgi verir

```

### K8s objesinin ayrıntılı özelliklerini inceleme:

- `describe` komutu bir Kubernetes objesi hakkında detaylı bilgi verir (event'ler, pod durumu, bağlı container'lar, vs.). Hataları anlamak ve debug yapmak için kullanışlıdır.

```bash
$ kubectl describe "nesne_tipi" "nesne_ismi"
$ kubectl describe pods "pod_ismi"
$ kubectl describe deployments "deployment_ismi"

kubectl describe pods myfirstpod
```

### POD logu inceleme

- Pod içindeki container'ların ürettiği log'ları görüntüler. `-f` parametresi ile log'ları anlık (follow) olarak izleyebilirsiniz.

```bash
$ kubectl logs "pod_ismi"

kubectl logs myfirstpod
kubectl logs -f myfirstpod # loglar canlı izlenebilir.
```

### POD üzerinde çalışma yapma

- `exec` komutu ile bir pod içerisinde belirli bir komut çalıştırılır. Eğer pod birden fazla container içeriyorsa `-c` ile hedef container belirtilmelidir.

```bash
kubectl exec "pod_ismi" -- "komut"

kubectl exec myfirstpod -- printenv
kubectl exec myfirstpod -- ls 
kubectl exec myfirstpod -- cat etc/os-release
kubectl exec myfirstpod -c <container_name> -- printenv # pod içinde birden fazla konteyner varsa

kubectl exec -it myfirstpod -- bin/sh # poda sh shell ile bağlanmak için kullanılır
kubectl exec -it myfirstpod -- bin/bash # poda bash shell bağlanmak için kullanılır
kubectl exec -it myfirstpod -c <container_name> -- bin/sh # pod içinde birden fazla konteyner varsa

```

### POD veya nesne silme

- Belirtilen objeyi siler. Obje türü ve ismi belirtilmelidir.

```bash
kubectl delete "nesne_tipi" "nesne_ismi"
kubectl delete pods myfirstpod
```

### YAML ile Decleretive yöntem ile kubernetes POD oluşturma ve silme

- Kubenetes ders çalışmalrını bir arada tutmak için `Kubernetes` isimli bir klasör oluşturalım. Bu klasör içine test.yaml dosyasını boş olarak oluşturalım.

```bash
mkdir Kubernetes
cd Kubernetes

touch test.yaml
```
- Şimdi VS Code ile oluşturduğumuz bu dosyayı inceleyelim. Bu dosyasyı doldurmak için gerekli olan bilgileri `kubectl explain "obje_ismi"` komutu ile dokumantasyona bakarak öğrene biliriz.


- Kubernetes objeleri ile ilgili dokumantsayona ulaşmak için, objeler hakkında bilgi almak için

```bash
kubectl explain pods
kubectl explain nodes
kubectl explain po
kubectl explain svc
kubectl explain deployment
```

```yaml
apiVersion:         # Objenin hangi kubernetes api de tanımlandığını bildirir. Objenin hangi api de olduğunu dokumantasyondan öğreniyoruz
kind:               # oluştururlacak olan nesne tipi
metadata:           # obje ile ilgili eşsiz bilgilerin tanımlandığı alandır. Objeyi betimleyen bilgiler bulunur.
spec:               # obje tipine göre değişir. objenin özelliklerini tanımlarız
```
- Yaml anahtarları ile ilgili açıklamalar:

```yaml
apiVersion:
# Ne işe yarar=Bu alan, YAML dosyasında tanımlanan Kubernetes objesinin hangi API versiyonunda çalıştığını belirtir.
# Neden önemlidir= Kubernetes API sürekli evrilir. Her kaynak türü (örneğin Pod, Deployment, Service) belirli bir API sürümüne bağlıdır. Yanlış apiVersion kullanırsan YAML dosyan hata verir veya eski sürümle uyumsuzluk yaşanır.

apiVersion: v1      # pod için
apiVersion: apps/v1 # deployment için
```

```yaml
metadata:
# Ne işe yarar: Obje ile ilgili kimlik ve etiket bilgilerini içerir. İsim (name), etiketler (labels), açıklamalar (annotations), namespace gibi alanlar buraya yazılır.

# Neden önemlidir: Obje yönetiminde benzersiz tanımlama ve sınıflandırma yapabilmek için metadata bilgileri şarttır. Özellikle etiketler, objeleri gruplamak ve üzerinde işlem yapmak için çok kullanılır.

metadata:
  name: my-first-pod
  labels:
    app: frontend
    env: production
```

```yaml
spec:
# Ne işe yarar: Kubernetes objesinin "nasıl" çalışacağını ve hangi özelliklere sahip olacağını tanımlar.
# Örneğin: bir Pod ise hangi container’ları çalıştıracağı, bir Service ise hangi port’lara yönlendirme yapacağı buraya yazılır.
# Neden önemlidir: spec, objenin davranış modelini tanımlar. Kubernetes spec alanındaki talimata göre obje oluşturur ve yönetir.

spec:
  containers:
  - name: nginx-container
    image: nginx:latest
    ports:
    - containerPort: 80
```


- `yaml` uzantılı konfigurasyon dosyası ile pod oluşturabiliriz. Aşağıdaki örnekte pod.yaml dosaysını oluşturalım ve declerative şekilde pod oluşturalım.

- `1-pod` isimli çalışma klasörü oluştularım.

```bash
mkdir 1-pod
cd 1-pod

```
- `echo` komutu ile `pod.yaml` oluşturma. Bu dosyasyı isterseniz manuel olarak da oluşturabilirsiniz. Buna Geçmeden once isterseniz yaml dosyasının içeriğini biraz inceleyelim. 

```bash

echo 'apiVersion: v1
kind: Pod
metadata:
  name: myfirstpod
  labels:
    name: frontend
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
      requests:
        memory: "256Mi"
        cpu: "0.2"  
    ports:
      - containerPort: 80' > pod.yaml
```

- Aşağıdaki komutu çalıştıralım, pod oluşturalım ve silelim.

```bash
kubectl apply -f "dosya_yolu/dosya_ismi"
kubectl apply -f ./pod.yaml
kubectl describe pods myfirstpod # oluşturulan podun özellikleirni incele
kubectl delete -f ./pod.yaml
```

#### Multicontainer pods

- Echo komotu ile aşağıdaki `multicontainerpod.yaml` isimşi dosyayı oluşturalım ve çalıştıralım.

```bash
echo 'apiVersion: v1
kind: Pod
metadata:
  name: multi-container-example
spec:
  containers:
  - name: nginx
    image: nginx:stable-alpine
    ports:
    - containerPort: 80
    volumeMounts:
    - name: html
      mountPath: /usr/share/nginx/html
  - name: content
    image: alpine:latest
    volumeMounts:
    - name: html
      mountPath: /html
    command: ["/bin/sh", "-c"]
    args:
      - while true; do
          echo $(date)"<br />" >> /html/index.html;
          sleep 5;
        done
  volumes:
  - name: html
    emptyDir: {}' > pod-multi-container-example.yaml
```

```bash
kubectl apply -f ./pod-multi-container-example.yaml
kubectl describe pods multi-container-example # oluşturulan podun özellikleirni incele
kubectl exec -it multi-container-example -c nginx -- bin/sh
kubectl exec -it multi-container-example -c content -- bin/sh
kubectl proxy
http://127.0.0.1:8001/api/v1/namespaces/default/pods/multi-container-example/proxy/
kubectl delete -f ./pod-multi-container-example.yaml
```

### Label ve port ayarlarıyla pod oluşturma

- Pod oluştururken etiketler ve port bilgisi tanımlayarak pod'u daha detaylı yapılandırabilirsiniz. `--labels` kısmında birden fazla etiket tanımlanabilir.

```bash
kubectl run "pod_ismi" --image="image_ismi" --port="port_numarası" --labels="key:value" --restart=Never

kubectl run mysecondpod --image=nginx --port=80 --labels="app=front-end,team=developer" --restart=Never
```

### Bir objeyi düzenlemek için varsayılan editörle açma:

- Kubernetes objesini canlı olarak düzenlemek için kullanılır. Varsayılan olarak `vi` ya da `nano` editörü açılır. Değişiklik yapılır ve kaydedilir.

```bash
kubectl edit "nesne_tipi" "nesne_ismi"
kubectl edit pods myfirstpod # çok sık kullanılan bir yöntem değildir. Nesne üzerinde değişiklik yapma imkanı verir.

$ kubectl edit pods myfirstpod
pod/myfirstpod edited
```

### Nesneler üzerinde yapılan işlemleri detaylı izlemek için

- Kubernetes çıktılarında canlı değişiklikleri gözlemlemek için `-w` (watch) parametresi kullanılır.

```bash
kubectl "komut" -w
kubectl get pods -w # -w ile komutun nesne üzerindeki yaşam döngüsünü canlı takip edebilirsiniz.
```

### Pod'lara Port yönlendirmesi

- Pod içindeki servise yerel bilgisayarınız üzerinden erişmek için port yönlendirmesi sağlar.

```bash
kubectl port-forward "nesne_tipi"/"nesne_ismi" "local_port":"hedef_port"
kubectl port-forward pod/mysecondpod 8080:80

127.0.0.1:8080 # browserdan çalışan nginx uygulamasını görebilirsiniz

kubectl delete pods mysecondpod
```

## Bölüm 2- Pod Yaşam Döngüsü

- Pod yaşam döngüsünü incelemk için iki tane yan yana terminal açalım.
- Sağdaki terminale `kubectl get pods -w` komutunu çalıştalım ve podun durumu canlı olarak takip edelim, alternatif olarak uniz işletim sisteminde `watch kubectl get pods` komutu ile canlı izleme yapılabilir.

- `kubernetes/1-pod` klasörü içinde çalışmalara devm edeceğiz.


### `restartPolicy: Always` ErrImagePull

- Şimdi aşağıdaki komutu terminale yapıştırarak `podlifecycle1.yaml` dosyasını `restartPolicy: Always` olacak şekilde oluşturalım. Ancak pod için çekilecek olan imaj ismi yanlış yazılmış. 

```bash

echo 'apiVersion: v1
kind: Pod
metadata:
  name: myfirstpod
  labels:
    name: frontend
spec:
  restartPolicy: Always
  containers:
  - name: ubuntu
    image: ubu
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
      requests:
        memory: "128Mi"
        cpu: "0.2"  
    ports:
      - containerPort: 80' > podlifecycle1.yaml

```
- Podu oluşturalım.

```bash
kubectl apply -f podlifecycle1.yaml
kubectl delete -f podlifecycle1.yaml
```

```bash
NAME         READY   STATUS             RESTARTS   AGE
myfirstpod   0/1     Pending             0          0s
myfirstpod   0/1     Pending             0          0s
myfirstpod   0/1     ContainerCreating   0          0s
myfirstpod   1/1     Running             0          4s
myfirstpod   1/1     Running             0          48s
myfirstpod   0/1     ErrImagePull        0          50s
myfirstpod   0/1     ImagePullBackOff    0          61s
myfirstpod   0/1     ErrImagePull        0          74s
```

- Yukarıdaki çıktıdan da gördüğümüz gibi kubernetes hatalı imajı bulamıyor ve ancak `restartPolicy: Always` olduğu için belli aralıklarla çekmeye devam ediyor. Ancan imaj ismini yanlış yazıdığımı için böyle bir imaj yok ve bulamayacak.


### `restartPolicy: Never` Running&Completed 

- Şimdi aşağıdaki komutu terminale yapıştırarak `podlifecycle1.yaml` dosyasını `restartPolicy: Never` olacak şekilde oluşturalım. Ancak pod için çekilecek olan imaj ismi yanlış yazılmış. 

```bash

echo 'apiVersion: v1
kind: Pod
metadata:
  name: myfirstpod
  labels:
    name: frontend
spec:
  restartPolicy: Never
  containers:
  - name: ubuntu
    image: ubuntu
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
      requests:
        memory: "128Mi"
        cpu: "0.2"  
    command: ['sh', '-c', 'sleep 10']
    ports:
      - containerPort: 80' > podlifecycle2.yaml

```
- Podu oluşturalım.

```bash
kubectl apply -f podlifecycle2.yaml
kubectl delete -f podlifecycle2.yaml
```

```bash
NAME         READY   STATUS             RESTARTS   AGE
myfirstpod   0/1     Pending             0          0s
myfirstpod   0/1     Pending             0          0s
myfirstpod   0/1     ContainerCreating   0          0s
myfirstpod   1/1     Running             0          3s
myfirstpod   0/1     Completed           0          21s
```

- Yukarıdaki çıktıdan da gördüğümüz gibi kubernetes imajı buldu container çalıştı 20sn bekledi görevini tamamladı ve kapandı. 


### `restartPolicy: Always` Command Eror

- Şimdi aşağıdaki komutu terminale yapıştırarak `podlifecycle3.yaml` dosyasını `restartPolicy: Never` olacak şekilde oluşturalım. Pod için çekilecek olan imaj ismi doğru ancak çalıştırlacak kod yanlış yazılmış. 

```bash

echo 'apiVersion: v1
kind: Pod
metadata:
  name: myfirstpod
  labels:
    name: frontend
spec:
  restartPolicy: Never
  containers:
  - name: ubuntu
    image: ubuntu
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
      requests:
        memory: "128Mi"
        cpu: "0.2"  
    command: ['sh', '-c', 'test_command']
    ports:
      - containerPort: 80' > podlifecycle3.yaml

```
- Podu oluşturalım.

```bash
kubectl apply -f podlifecycle3.yaml
kubectl delete -f podlifecycle3.yaml
```

```bash
NAME         READY   STATUS             RESTARTS   AGE
myfirstpod   0/1     Pending             0          0s
myfirstpod   0/1     Pending             0          0s
myfirstpod   0/1     ContainerCreating   0          0s
myfirstpod   0/1     Error               0          3s
myfirstpod   0/1     Error               0          4s
```

- Yukarıdaki çıktıdan da gördüğümüz gibi kubernetes podu oluşturdu ancak container içinde çalışması istenilen komut hatalı olduğu için ststus Error olarak oluştu..

### `restartPolicy: Never` CrashLoopBackOff

- Şimdi aşağıdaki komutu terminale yapıştırarak `podlifecycle4.yaml` dosyasını `restartPolicy: Always` olacak şekilde oluşturalım. 

```bash

echo 'apiVersion: v1
kind: Pod
metadata:
  name: myfirstpod
  labels:
    name: frontend
spec:
  restartPolicy: Always
  containers:
  - name: ubuntu
    image: ubuntu
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
      requests:
        memory: "128Mi"
        cpu: "0.2"  
    command: ['sh', '-c', 'sleep 10']
    ports:
      - containerPort: 80' > podlifecycle4.yaml

```
- Podu oluşturalım.

```bash
kubectl apply -f podlifecycle4.yaml
kubectl delete -f podlifecycle4.yaml
```

```bash
NAME         READY   STATUS             RESTARTS   AGE
myfirstpod   0/1     Pending             0          0s
myfirstpod   0/1     Pending             0          0s
myfirstpod   0/1     ContainerCreating   0          1s
myfirstpod   1/1     Running             0          4s
myfirstpod   0/1     Completed           0          14s
myfirstpod   1/1     Running             1 (3s ago)   16s
myfirstpod   0/1     Completed           1 (13s ago)   26s
myfirstpod   0/1     CrashLoopBackOff    1 (12s ago)   37s
myfirstpod   1/1     Running             2 (14s ago)   39s
```

- Yukarıdaki çıktıdan da gördüğümüz gibi kubernetes imajı buldu container çalıştı 10sn bekledi görevini tamamladı ve kapandı. Ancak `restartPolicy: Always` olduğu için aynı işlem tekrar tekrar devam edecektir. Sonnunda Kubernetes bunun problem olabileceğini düşünüp state i `CrashLoopBackOff` a alır ve işelme devam eder. Burada incelenmesi gereken bir durum olabilir.



## Bölüm 3- Namespace

- Bu kısımda NameSpace kavramı hakkında çalışmalar bulunmaktadır.

###  Linux Namespace Nedir?

Linux Namespace, işletim sistemi kaynaklarını birbirinden izole etmek için kullanılan bir teknolojidir.
Her process grubu kendi görüş alanına (resource view) sahip olur. Böylece bir process diğerinin kaynaklarını göremez veya müdahale edemez.

Namespace'ler sayesinde:

Her container kendi IP adresine sahip olur.

Her container kendi dosya sistemine sahip olur.

Her container kendi process ağacını görür.

🧩 Başlıca Namespace Türleri:

Namespace Türü	Açıklama
PID Namespace	Process ID'leri izole eder. Her container içinde PID 1'den başlar.
NET Namespace	Ağ kaynaklarını (IP adresi, portlar, network interface'leri) izole eder.
IPC Namespace	Processler arası iletişim (semaphore, shared memory) kaynaklarını ayırır.
MNT Namespace	Dosya sistemlerini (mount points) izole eder. Her container kendi dosya yapısına sahiptir.
UTS Namespace	Hostname ve domain name gibi sistem adlandırmalarını ayırır.
USER Namespace	Kullanıcı ve grup kimliklerini izole eder (UID/GID).
CGROUP Namespace	cgroup hiyerarşilerini izole eder.

### cgroup (Control Groups) Nedir?

cgroup, Linux çekirdeğinde bulunan bir özellik olup, processlerin sistem kaynaklarını sınırlamak, önceliklendirmek, izlemek ve izole etmek için kullanılır.

cgroup'lar sayesinde:

CPU kullanımını sınırlarız.

RAM kullanımını sınırlayabiliriz.

I/O (disk erişimi) kısıtlaması yapabiliriz.

Ağ trafiğini kontrol edebiliriz.

Container teknolojileri (Docker, LXC, Kubernetes) cgroup'ları kullanarak:

Bir container'ın fazla kaynak tüketmesini engeller.

İstenilen kaynak garantilerini sağlar (örn: CPU 1 core'dan fazla kullanamasın).


### 📚 Kubernetes Namespace Nedir?

Namespace, Kubernetes cluster'ı içinde kaynakları (podlar, servisler, configmap'ler, secret'lar vs.) mantıksal olarak ayırmak için kullanılan bir yapıdır.

Cluster'ı küçük sanal cluster'lara bölmek gibi düşünebilirsin.

Bir namespace içindeki kaynaklar, başka bir namespace'deki kaynaklarla doğrudan etkileşemez (bazı istisnalar dışında).

İsim çakışmalarını önler (aynı isimde iki pod farklı namespace'lerde var olabilir).

Kaynak yönetimi, yetkilendirme ve organizasyon kolaylığı sağlar.

Özet
Namespace = Cluster içinde mantıksal bölme/ayırma sistemi.

Kullanım amacı: İzolasyon, yetkilendirme, kaynak yönetimi, düzen.

İyi bir cluster yönetimi için namespace'ler mutlaka kullanılmalıdır.


### Neden Namespace Kullanırız?

Amaç	                      Açıklama
İzolasyon	                  Farklı uygulamalar veya ekipler birbirinden izole çalışabilir.
İsim Çakışmasını Önlemek	  Aynı isimli pod, service gibi kaynaklar farklı namespace'lerde olabilir.
Yetkilendirme (RBAC)	      Namespace bazlı kullanıcı yetkilendirmesi yapılabilir. (Örn: Bir ekip sadece kendi namespace'ini yönetir.)
Kaynak Yönetimi	            Namespace'lere CPU, Memory gibi kaynak limitleri tanımlanabilir (ResourceQuota).
Organizasyon	              Cluster'ın daha düzenli ve yönetilebilir olmasını sağlar.

### Kubernetes de bulunan default namespace ler ve görevleri:

default         : Kullanıcı tanımlı kaynakların, özel bir namespace belirtilmediğinde yer aldığı genel çalışma alanıdır.
kube-system     : Kubernetes tarafından yönetilen sistem bileşenlerinin (kube-apiserver, kube-controller-manager vb.) bulunduğu namespace'tir.
kube-public     : Tüm kullanıcılar tarafından erişilebilen, genellikle küme hakkında genel bilgiler içeren kaynakların bulunduğu namespace’tir.
kube-node-lease : Her node’un durumunu izlemek için periyodik olarak güncellenen "lease" nesnelerinin tutulduğu namespace’tir, node erişilebilirliğini optimize eder.

- Kubernetes Namespace konusu daha iyi anlamak için birkaç çalışma yapaılım. Aşağıdaki komut ile `multi-namespaces.yaml` dosyasını oluşturlaım ve çalıştıralım. Not: Belirtilmediği sürece podlar default ns içinde oluşturulur.

```bash 
kubectl get namespaces
kubectl get pods 
kubectl get pods --namespace kube-system
kubectl get pods --all-namespaces # tüm ns deki podları leri listeler
kubectl get pods -A # tüm ns deki podları leri listeler
``` 


```bash

echo 'apiVersion: v1
# frontend-namespace.yaml
kind: Namespace
metadata:
  name: frontend
---
# backend-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: backend' > multi-namespaces.yaml

```

- Şimdi oluşturduğumuz bu namespaceler içinde pod oluşturralım.

```bash
echo '# frontend-pod.yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-frontend
  namespace: frontend # podun hangi ns oluşacağını bu şekilde belirleriz.
spec:
  containers:
  - name: nginx
    image: nginx
    ports:
    - containerPort: 80
---
# backend-pod
apiVersion: v1
kind: Pod
metadata:
  name: postgres-backend
  namespace: backend
spec:
  containers:
  - name: postgres
    image: postgres:15
    env:
    - name: POSTGRES_USER
      value: myuser
    - name: POSTGRES_PASSWORD
      value: mypass
    - name: POSTGRES_DB
      value: mydb
    ports:
    - containerPort: 5432' > multi-ns-pods.yaml

```

- Oluşturduğumuz `multi-namespaces.yaml` ve `multi-ns-pods.yaml` dosyalarını çalıştralım

```bash
kubectl apply -f multi-namespaces.yaml # namspace leri oluştur.
kubectl apply -f multi-ns-pods.yaml # namspaceler içeine podları yerleştir.
kubectl get pods -n frontend
kubectl get pods -n backend
kubectl get pods -o wide --all-namespaces | grep -vE 'kube-system|kube-public|kube-node-lease' # oluşturduğumuz podları ekrana basar
kubectl get pods --all-namespaces -w | grep -vE 'kube-system|kube-public|kube-node-lease' # oluşturduğumuz podları canlı ekrana basar

kubectl delete -f multi-ns-pods.yaml # 
kubectl delete -f multi-namespaces.yaml # 
```

- NOT!!!!!!!! çalıştığımız clusterda default namespace değiştirmk istiyorsak. Örnek olarak n`amespace-prod.yaml` dosası ile prod isimli bir namespace oluşturalım.

```bash
echo 'apiVersion: v1
kind: Namespace
metadata:
  name: prod' > namespace-prod.yaml
```



```bash
kubectl apply -f namespace-prod.yaml # prod isimli bir ns oluşturduk
kubectl get namespaces
kubectl config set-context --current --namespace=prod # yeni ns i default olarak ayarladık
kubectl config set-context --current --namespace=default # yeni ns i default olarak ayarladık

kubectl delete namespaces prod
```

## Bölüm 4- Labels, Selector ve Annotations

- Labels ve selector kavramları nesneleri etiketlemek ve bu etiketler yardımı ile nesneleri daha kolay filitrelemek için kullanılmaktadır. Pod tanımında metadata olarak girilir.

###  Labels?

- Örnek olarak `labes.yaml` dosyasını oluşturalım ve çalıştıralım.

```bash

echo 'apiVersion: v1
kind: Pod
metadata:
  name: myfirstpod
  labels:
    name: frontend
    env: prod
    team: devops
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
      requests:
        memory: "128Mi"
        cpu: "0.2"  
    ports:
      - containerPort: 80' > labels.yaml
```


```bash
kubectl apply -f labels.yaml
kubectl get pods --show-labels
```
- imperative olarak podlara label ekleyebilirz.

```bash
Kubectl label pods myfirstpod app=thirdapp # label ekleme
Kubectl label pods myfirstpod app- # label silme
Kubectl label --overwrite pods myfirstpod app=team3 # label ekleme
Kubectl label pods --all foo=bar # tüm podlara aynı anda label ekleme

```
### Selector

- Selector (seçici), Kubernetes kaynakları (örneğin Podlar) üzerinde label'lara göre seçim yapabilmemizi sağlayan bir mekanizmadır.
Yani: Sistemde yüzlerce obje olsa bile sadece istediğimiz label'lara sahip olanları bulabiliriz.

İki temel selector tipi vardır:


Tür	                                                  Açıklama
Equality-based Selector (Eşitlik Temelli Seçici)	    key=value veya key!=value şeklinde çalışır.
Set-based Selector (Küme Temelli Seçici)	            in, notin, exists gibi ifadelerle daha esnek seçimler yapılır.


#### Equality-based Selector (Eşitlik Temelli Seçici)
```bash
Kubectl get pods -l name --show-labels # name anahtarı atanmış podları listele
Kubectl get pods -l name=frontend --show-labels # name=frontend  atanmış podları listele
Kubectl get pods -l name=frontend,env=prod --show-labels  # name=frontend ve env=prod  atanmış podları listele
Kubectl get pods -l name=frontend,env!=prod--show-labels  # name=frontend ve env=prod olmayan podları listele

```
#### Set-based Selector (Küme Temelli Seçici)	   
```bash
Kubectl get pods -l 'name in (frontend)' --show-labels # name anahtarına frontend atanmışları listele
Kubectl get pods -l 'name in (frontend,backend)' --show-labels # name anahtarına frontend ve backend atanmışları listele
Kubectl get pods -l 'name notin (backend)' --show-labels # name anahtarına backend atanmamışları listele

```

###  NodeSelector

- Aşağıdaki komut ile nodeselector.yaml dosyasını oluşturalım. Bu pod un tanımına baktığımızda nodeSelector isimli bir bolum var. Bunun anlamı; bu podu `gpu: nvidia` yanı gpu tipi nvidia olan bir noda atanmasını belirtiyoruz. Normal şartlarda Kube-schedular kendi alagoritmasına göre bir podu uygun bir node üzerinde oluşturur ancak nodeselector tanımı yapıldıysa bu sefer Kube-schedular node selectorde atanmış değere sahip nodu arar ve nulursa podu arada oluştutur bulamazsa pod oluşturulamaz ve pending de kalır.

```bash

echo 'apiVersion: v1
kind: Pod
metadata:
  name: nodeselectorpod
  labels:
    name: frontend
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
      requests:
        memory: "128Mi"
        cpu: "0.2"  
    ports:
      - containerPort: 80
  nodeSelector:
    gpu: nvidia' > nodeselector.yaml
```

```bash
kubectl apply -f nodeselector.yaml
```

```bash
$ kubectl get pod -w

NAME         READY   STATUS    RESTARTS   AGE
nodeselectorpod   0/1     Pending   0          0s
nodeselectorpod   0/1     Pending   0          0s
```
- Kube-Schedular podu oluşturabileceği bir node bulamadı. Şimdi noda label ataması yaparak sonucu izleyelim. minikube isimli node a `gpu=nvidia` etiketini ekleyince schedular nodu yakalıyor ve podu bu node üzerinde oluşturuyor.

```bash
kubectl get nodes --show-labels
kubectl label nodes minikube gpu=nvidia # minikube isismli noda labet ataması yapıyoruz
kubectl delete -f nodeselector.yaml
```

### Kubernetes Annotations Nedir?

Annotations, Kubernetes objelerine ekstra, detaylı, açıklayıcı bilgi eklemek için kullanılır.
Label'lar gibi key-value çiftleri şeklindedirler, fakat kullanımları farklıdır:

Labels, kaynakları gruplamak ve seçim yapmak için kullanılır.

Annotations ise seçim yapılmaz, sadece bilgi eklemek amacıyla kullanılır.

Başka bir deyişle:
🔹 Label = Objeleri bulmak ve gruplamak için kullanılır.
🔹 Annotation = Objeye açıklayıcı meta veri (ek bilgi) eklemek için kullanılır.


### ✨ Annotations Kullanım Amaçları

Annotations, objeler hakkında ek bilgi tutmak için idealdir. Örneğin:

Sürüm bilgileri (version: v1.0.2)
Build numaraları (build: 20250427)
Dış sistemlerle entegrasyon bilgileri
Monitoring araçları için özel metadata
Deploy eden kişi bilgisi, açıklamalar
Otomasyon sistemleri için özel yönergeler
Audit (denetim) bilgileri

```bash

echo 'apiVersion: v1
kind: Pod
metadata:
  name: annotated-pod
  labels:
    name: frontend
  annotations:
    createdBy: "Fevzi Topcu"
    email: "fevzi@gmail.com"
    purpose: "Örnek eğitim podu"
spec:
  containers:
  - name: nginx
    image: nginx:latest
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
      requests:
        memory: "128Mi"
        cpu: "0.2"  
    ports:
      - containerPort: 80
  nodeSelector:
    gpu: nvidia' > annotaions.yaml
```

```bash
kubectl apply -f annotaions.yaml
kubectl get pod annotated-pod --show-labels
Kubectl annotate pods annotated-pod class=bootcamp  # annotaion ekleme
Kubectl annotate pods annotated-pod class=bootcamp- # annotaion silme
kubectl describe pod annotated-pod
kubectl delete -f annotaions.yaml
```