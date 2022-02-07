# Azure NetApp Files Hands-on Session: ANF Dynamic Provisioning with Trident

> How to create Persistent Volune with ANF and Trident in Dynamic Provisioning.  

## Dynamic Provisioning

Dynamic volume provisioning allows storage volumes to be created on-demand. Without dynamic provisioning, cluster administrators have to manually make calls to their cloud or storage provider to create new storage volumes, and then create PersistentVolume objects to represent them in Kubernetes. The dynamic provisioning feature eliminates the need for cluster administrators to pre-provision storage. Instead, it automatically provisions storage when it is requested by users.

## Your reference

* **[K8s cheatsheet site](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)** *Kubeenetes offficial cheetsheet*
* **[Tridnet URL](https://netapp.io/persistent-storage-provisioner-for-kubernetes/)** *Trident Site and Github site*
* **[Today's hands-on diagram](https://github.com/maysay1999/anfdemo01/blob/main/diagram/211214_hands-on_diagram_aks_nfs.pdf)** *You can download the hands-on diagram here.*

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

### The source code will be executed in this recipe is available here. 

```bash
git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01
```


## 1. Create Ubuntu VM for Trident

- Create a new resource group: 

```bash
az group create -n anftest-rg -l japaneast
```

- Create Ubuntu VM [ARM for Ubuntu](https://github.com/maysay1999/anfdemo01/tree/main/trident) (right-click on this link)

## 2. Create AKS cluster

- Resource group: anftest-rg
- Cluster name: AnfCluster01
- Node count: 3

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

- ANF account: anfac01
- Pool named mypool1: 4TB, Standard
- Volume named myvol1: 100GB, NGFSv3

1. Open anf-create.sh with `vi`, `vim` or `code`. 

![anf-create.sh](https://github.com/maysay1999/anfdemo01/blob/main/images/anf-create_shell.jpg)

```bash
cd AnfDemo01/
vim anf-create.sh
```

2. Edit anf-create.sh.  aks-vnet-xxxxxxxx to be modified as your VNet name under Resource Group, *MC_anftest-rg_AnfCluster01_japaneast*. 

![anf-create2.sh](https://github.com/maysay1999/anfdemo01/blob/main/images/anf-create_shell2.jpg)

3. Run this shell. 

```bash
./anf-create.sh
```

## 4. Install kubectl, helm, az cli and git

- Install kubectl, helm, az cli and git on Ubuntu Jump Host

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

- Download Trident `curl -L -O -C - https://github.com/NetApp/trident/releases/download/v21.07.2/trident-installer-21.07.2.tar.gz`
- Extract tar `tar xzvf trident-installer-21.07.2.tar.gz`
- Copy tridentctl to /usr/bin/  `cd trident-installer`  `sudo cp tridentctl /usr/local/bin/`
- Create a Trident Namespace `kubectl create ns trident`
- Install trident with helm `cd helm` and then `helm install trident trident-operator-21.07.2.tgz -n trident`
- ~~Deploy Trident operator `kubectl apply -f trident-installer/deploy/bundle.yaml -n trident`~~
- ~~Create a TridentOrchestrator `kubectl apply -f trident-installer/deploy/crds/tridentorchestrator_cr.yaml` and `kubectl describe torc trident` to verify~~
- ~~Download codes `cd ~` `git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01`~~
- Verification  `kubectl get pod -n trident`

## 8. Configure CSI (csi-install.sh)

- Back to home directory: `cd`
- Use this command to create a clone of this site locally `git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01`
- `cd ~/AnfDemo01/astra`
- `chmod 711 csi-install.sh`
- `./csi-install.sh`
- ~~`kubectl apply -f snapshot.storage.k8s.io_volumesnapshotclasses.yaml`~~
- ~~`kubectl apply -f snapshot.storage.k8s.io_volumesnapshotcontents.yaml`~~
- ~~`kubectl apply -f snapshot.storage.k8s.io_volumesnapshots.yaml`~~
- ~~`kubectl apply -f rbac-snapshot-controller.yaml`~~
- ~~`kubectl apply -f setup-snapshot-controller.yaml`~~\
or\
~~`tridentctl install -n trident --csi`~~

## 9. Create Service Principal

- Creaete a new SP named "http://netapptridentxxx" `az ad sp create-for-rbac --name "http://netapptridentxxx" --role contributor --scopes /subscriptions/{SUBSCRIPTION_ID}`
- Take note of the output json. 
- Gain Subection ID `az account show`
- Take note of the output json. 

## 10. modify backend-azure-anf-advanced.json (backend-azure-anf-advanced.json)

- ~~path: trident-installer/sample-input/backends-samples/azure-netapp-files/backend-anf.yaml `cd ~/trident-installer/sample-input/backends-samples/azure-netapp-files/`~~
- `cd ~/AnfDemo01`
- Edit backend-anf.yaml `vim backend-azure-anf-advanced.json`
- Example
{
    "version": 1,
    "storageDriverName": "azure-netapp-files",
    "subscriptionID": "a9f075ef-390d-4cc4-8066-2896b4f0fake",
    "tenantID": "5da13186-1f6e-413c-953a-f5aff3c0fake",
    "clientID": "199275e0-d9ca-4142-92a1-771ff555fake",
    "clientSecret": "zONFD4o9zl7n9yLnya.T7hxVCaiBFfake",
    "location": "japaneast",
    "serviceLevel": "Standard",
    "virtualNetwork": "aks-vnet-xxxxxxxx",
    "subnet": "netapp-subnet",
    "nfsMountOptions": "vers=3,proto=tcp,timeo=600",
    "limitVolumeSize": "500Gi",
    "defaults": {
        "exportRule": "10.0.0.0/8,172.16.0.0/12",
        "size": "100Gi"
    }
}

## 11. Create backend

- ~~cd to Trident `cd ~/trident-installer`~~
- ~~`kubectl apply -f sample-input/backends-samples/azure-netapp-files/backend-anf.yaml -n trident`~~
- ~~Verify `tridentctl -n trident create backend -f trident-installer/sample-input/backends-samples/azure-netapp-files/backend-anf.yaml`~~
- Execute this command  `tridentctl create backend -f backend-azure-anf-advanced.json -n trident`

## 12. Create StorageClass (anf-storageclass.yaml)

- cd to AnfDemo01 `cd ~/AnfDemo01`
- `kubectl apply -f anf-storageclass.yaml`
- Name: azure-netapp-files
- NFS
- Verify `kubectl get sc`

## 13. Create PVC (anf-pvc.yaml)

- `kubectl apply -f anf-pvc.yaml`
- Name: anf-pvc
- SC name: azure-netapp-files
- Storage 1TiB. RWX
- Verify `kubectl get pvc anf-pvc`

## 14. Create a pod (anf-nginx-pod.yaml)

- `kubectl apply -f anf-nginx-pod.yaml`
- CPU 100m, Mem 128Mi
- Mount path: /mnt/data
- Storage 100GiB. RWX

## 15. Have access to the pods to view mounted status and Snapshot

- Have access with pod  `kubectl exec -it nginx-pod -- /bin/bash`
- `df -h` *view mount status*
- `mount` *view mount status*
- `apt update`
- `apt install -y vim` *Install vim*
- Open VIM and create test.txt or `echo "this is test" > test.txt`
- `dd if=/dev/zero of=5m.dat bs=1024 count=5120` *create 5MB test file*

~~## 16. Create a deployment (nginx-deployment.yaml)~~
~~- `kubectl apply -f nginx-deployment.yaml`~~
~~- Verification of ReplicaSet  `kubectl get rs`~~
~~- Verification of Deployment  `kubectl get deploy`~~
~~- To have access to deployment `curl {ip_address}`~~
~~- Login to pod  `kubectl exec -it nginx-pod -- /bin/bash`~~
~~- Install curl  `apt update && apt install curl -y`~~  

---