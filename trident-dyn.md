# Azure NetApp Files Hands-on Session: ANF Dynamic Provisioning with Trident

> How to create Persistent Volune with ANF and Trident in Dynamic Provisioning.  

## Dynamic Provisioning

Dynamic volume provisioning allows storage volumes to be created on-demand. Without dynamic provisioning, cluster administrators have to manually make calls to their cloud or storage provider to create new storage volumes, and then create PersistentVolume objects to represent them in Kubernetes. The dynamic provisioning feature eliminates the need for cluster administrators to pre-provision storage. Instead, it automatically provisions storage when it is requested by users.

## Your reference

* **[K8s cheatsheet site](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)** *Kubeenetes offficial cheetsheet*
* **[Tridnet URL](https://netapp.io/persistent-storage-provisioner-for-kubernetes/)** *Trident Site and Github site*
* **[Today's hands-on diagram](https://github.com/maysay1999/anfdemo01/blob/main/diagram/220123_hands-on_diagram_aks_nfs.pdf)** *You can download the hands-on diagram here.*

### Commands that we use this hands-on session

* **kubectl get no** *nodes*
* **kubectl get po -o** wide *Output format wide*
* **kubectl get po -w** *After listing/getting the requested object, watch for changes.*
* **kubectl describe po {pod_name}** *Show details of a specific resource or group of resources*
* **kubectl get po** *pods*
* **kubectl get ns** *namespaces*
* **kubectl get deploy** *deployments*
* **kubectl get pv** *PersisetentVolume*
* **kubectl get pvc** *PersisetentVolumeClaim*
* **kubectl get sc** *StorageClass*
* **kubectl get svc** *Service*
* **kubectl apply -f {name}.yaml** *Apply a configuration to a resource by file name*
* **kubectl create -f {name}.yaml** *Create a resource from a file*
* **kubectl delete -f {name}.yaml** *Delete resources by file names*
* **kubectl get po -n {namespace}** *-n : namespace*
* **kubectl get po --all-namespaces** *List all pods in all namespaces*
* **kubectl get po -A** *List all pods in all namespaces*

### The source code will be executed in this recipe is available here

```bash
git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01
```

## 1. Create Ubuntu VM for Trident

* Create a new resource group:

```bash
az group create -n anftest-rg -l japaneast
```

* Create Ubuntu VM [ARM for Ubuntu](https://github.com/maysay1999/anfdemo01/tree/main/trident) (right-click on this link).  After deploying Ubuntu VM, remotely log in via public IP address with your favorite SSH Agent software, [Windows Terminal](https://docs.microsoft.com/en-us/windows/terminal/install), [WSL](https://docs.microsoft.com/en-us/windows/wsl/install) or [Tera Term](https://osdn.net/projects/ttssh2/releases/).

```Bash
ssh {your_public_ip_address} -l aksadmin
```

## 2. Create AKS cluster

* Resource group: anftest-rg
* Cluster name: AnfCluster01
* Node count: 3

```bash
az aks create \
    -g anftest-rg \
    -n AnfCluster01 \
    -l japaneast \
    --node-count 3 \
    --generate-ssh-keys \
    --node-vm-size Standard_B2s \
    --enable-managed-identity
```

## 3. Create ANF account, pool and volume (anf-create.sh)

ANF account: anfac01

Pool named mypool1: 4TB, Standard

Volume named myvol1: 100GiB, NGFSv3

* Open anf-create.sh with `vi`, `vim` or `code`.

![anf-create.sh](https://github.com/maysay1999/anfdemo01/blob/main/images/anf-create_shell.jpg)

```bash
cd AnfDemo01/
vim anf-create.sh
```

* Edit anf-create.sh.  aks-vnet-xxxxxxxx to be modified as your VNet name under Resource Group, *MC_anftest-rg_AnfCluster01_japaneast*

![anf-create2.sh](https://github.com/maysay1999/anfdemo01/blob/main/images/anf-create_shell2.jpg)

* Run this shell

```bash
./anf-create.sh
```

## 4. Install kubectl, helm, az cli and git

* Install kubectl, helm, az cli and git on Ubuntu Jump Host

```bash
sudo apt update && \
sudo snap install kubectl --classic && \
sudo snap install helm --classic && \
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
sudo apt install git-all -y
```

## 5. az login to Azure on Trident VM

```bash
az login --tenant {your_tenant_name}
```

> **Note**: In most of the cases, *'--tenant'* can be omitted.  Tenant name can be viiew with `az account show`.  

## 6. Connect AKS cluster to Trident VM

Kubernetes service --> AnfCluster01 and click "Connect".  And copy and paste two command lines line by line on Ubuntu jump host.

![Connect to AKS](https://github.com/maysay1999/anfdemo01/blob/main/images/connect_to_aks.jpg)

```Bash
az account set -s {your_subscriptionID}
az aks get-credentials --resource-group anftest-rg --name AnfCluster01
```

## 7. Install Trident

The latest Trident is avaialable [here](https://github.com/NetApp/trident/releases).

* Download Trident

```Bash
curl -L -O -C - https://github.com/NetApp/trident/releases/download/v22.01.0/trident-installer-22.01.0.tar.gz`
```

* Extract tar.gz file

```Bash
tar xzvf trident-installer-22.01.0.tar.gz`
```

* Copy tridentctl to /usr/local/bin/ ($PATH directory)

```Bash
cd trident-installer
sudo cp tridentctl /usr/local/bin/
```

* Create a new namespace, trident

```Bash
kubectl create ns trident
```

* Install trident with helm

```Bash
cd helm
helm install trident trident-operator-22.01.0.tgz -n trident
```

* Verify trident oprator and CSI pods are running in *trident* namespace

```Bash
kubectl get po -A
```

## 8. Create an alias, k=kubectl

* Edit `.bashrc`.  Add a new alias, `alias k=kubectl`

```Bash
vim ~/.bashrc
source ~/.bashrc
```

![add alias](https://github.com/maysay1999/anfdemo01/blob/main/images/alias.jpg)

## 9. Create Service Principal

* Creaete a new SP named "http://netapptridentxxx".  Output such as AppID and Password shall be written on notepad.  

```Bash
az ad sp create-for-rbac --name "http://netapptridentxxx" \
  --role contributor \
  --scopes /subscriptions/{your_SUBSCRIPTION_ID}
```

## 10. Modify backend-azure-anf-advanced.json as preparation to create Tridnet Backend

* Edit `backend-azure-anf-advanced.json` file under AnfDemo01 directory. The values of "subscriptionID", "tenantID", "clientID", "clientSecret" and "virtualNetwork" shall be changed

```Bash
vim ~/AnfDemo01/backend-azure-anf-advanced.json
```

![json file to create Tridnet Backend](https://github.com/maysay1999/anfdemo01/blob/main/images/json-backend.jpg)

## 11. Create backend with tridentctl

* Using [tridentctl command](https://netapp-trident.readthedocs.io/en/stable-v18.07/reference/tridentctl.html), create Trident Backend

```Bash
tridentctl create backend -f backend-azure-anf-advanced.json -n trident
```

> **Note** Please refer to [this site](https://netapp-trident.readthedocs.io/en/stable-v18.07/reference/tridentctl.html) for tridentctl command.

## 12. Create StorageClass (anf-storageclass.yaml)

SC name: azure-netapp-files

FS type: NFS

```Bash
cd ~/AnfDemo01
kubectl apply -f anf-storageclass.yaml
```

> **Verify** `k get sc`

## 13. Create PVC (anf-pvc.yaml)

Name: anf-pvc

SC name: azure-netapp-files

Storage 100MiB, RWX

```Bash
kubectl apply -f anf-pvc.yaml
```

> **Verify**  k get pvc

## 14. Create a pod (anf-nginx-pod.yaml)

Pod image: NGINX

CPU: 100m, Mem:  128Mi

Mount path: /mnt/data

```Bash
kubectl apply -f anf-nginx-pod.yaml
```

> **Verify**  k get po

## 15. Have access to the pods to view mounted status and Snapshot

* Have access with pod

```Bash
kubectl exec -it nginx-pod -- /bin/bash
```

* View mount status

```Bash
df -h
```

* Install wget

```Bash
cd /mnt/data/
apt update
apt install -y wget
wget https://releases.hashicorp.com/terraform/1.1.5/terraform_1.1.5_windows_amd64.zip
```

* Change to /mnt/data and create two files

```Bash
cd /mnt/data/
echo "Azure is awesome" > test.txt
dd if=/dev/zero of=5m.dat bs=1024 count=5120
cat test.txt
ls -lah 5m.dat
```

## History

CHANGELOG.md will be created soon.

~~## 16. Create a deployment (nginx-deployment.yaml)~~
~~- `kubectl apply -f nginx-deployment.yaml`~~
~~- Verification of ReplicaSet  `kubectl get rs`~~
~~- Verification of Deployment  `kubectl get deploy`~~
~~- To have access to deployment `curl {ip_address}`~~
~~- Login to pod  `kubectl exec -it nginx-pod -- /bin/bash`~~
~~- Install curl  `apt update && apt install curl -y`~~  

---
