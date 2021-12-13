# Azure NetApp Files Hands-on Session: Dynamic Provisioning with Trident interact Ubuntu VM

K8s cheatsheet(https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### **Procedure different between Static Provisioning and Dynamic Provisioning**
### **Static Provisioning** ==> 1) pv 2) pvc 3) pod
### **Dynamic Provisioning** ==> 1) sc 2) pvc 3) pod

[View hands-on diagram](https://github.com/maysay1999/anfdemo01/blob/main/diagram/211118_hands-on_diagram_aks_nfs.pdf)

Examples)\
kubectl get no\
kubectl get nodes -o wide\
kubectl describe node\
kubectl get po -o wide\
kubectl get namespaces -o wide\
kubectl get ns {name}\
kubectl get deploy\
kubectl get pv\
kubectl get pvc\
kubectl get sc\
kubectl get svc\
kubectl apply -f {name}.yaml\
kubectl delete -f {name}.yaml\

kubectl get po -n <namespace>\
kubectl get po --all-namespaces\ 
kubectl get po -A

Use this command to create a clone of this site locally\
`git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01`


## 1. Create Ubuntu VM for Trident
- Create a new resource group (anf-demo-aks-prework.azcli)  `az group create -n anftest-rg -l japaneast`
- Create Ubuntu VM [ARM for Ubuntu](https://github.com/maysay1999/anfdemo01/tree/main/trident)

## 2. Create AKS cluster (anf-demo-aks-prework.azcli)
- Resource group: anftest-rg
- Cluster name: AnfCluster01
<pre>
az aks create \
    -g anftest-rg \
    -n AnfCluster01 \
    -l japaneast \
    --node-count 2 \
    --generate-ssh-keys \
    --node-vm-size Standard_B2s \
    --enable-managed-identity
</pre>

## 3. Create ANF subnet and delegate the subnet for ANF (anf-create.sh)
- Resource group for Nodes(VMs): MC_anftest-rg_AnfCluster01_japaneast
- Vnet inside MC_anftest-rg_AnfCluster01_japaneast: aks-vnet-xxxxxxxx
- ANF subnet: 10.0.0.0/26

## 4. Create ANF account, pool and volume (anf-create.sh)
- ANF account: anfac01
- Pool named mypool1: 4TB, Standard
- Volume named myvol1: 100GB, NGFSv3
*Running as shell is easier.*
*chmod 711 anf_demo_create_pool_volume.azcli*
*./anf_demo_create_pool_volume.azcli*

## 5. Install kubectl, helm, az cli and git
- ~~Install kubectl `sudo snap install kubectl --classic`~~
- ~~Install helm `sudo snap install helm --classic`~~
- ~~Install Azure CLI `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`~~
- ~~Install git `sudo apt install git-all -y`~~
- Install kubectl, helm, az cli and git
<pre>
sudo apt update && 
sudo snap install kubectl --classic && \
sudo snap install helm --classic && \
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
sudo apt install git-all -y
</pre>

## 6. az login to Azure on Trident VM
- `az login --use-device-code`
- `https://microsoft.com/devicelogin`
- Verify with this command `kubectl get deployments --all-namespaces=true`
- Set as default account `az account set -s SUBSCRIPTION_ID`

## 7. Connect AKS cluster to Trident VM
Copy 'az aks get-credentials…' on Azure Portal and paste to Trident VM

## 8. Install Trident 
- Download Trident `curl -L -O -C - https://github.com/NetApp/trident/releases/download/v21.07.2/trident-installer-21.07.2.tar.gz`
- Extract tar `tar xzvf trident-installer-21.07.2.tar.gz`
- Copy tridentctl to /usr/bin/  `cd trident-installer`  `sudo cp tridentctl /usr/local/bin/`
- Create a Trident Namespace `kubectl create ns trident`
- Install trident with helm `cd helm` and then `helm install trident trident-operator-21.07.2.tgz -n trident`
- ~~Deploy Trident operator `kubectl apply -f trident-installer/deploy/bundle.yaml -n trident`~~
- ~~Create a TridentOrchestrator `kubectl apply -f trident-installer/deploy/crds/tridentorchestrator_cr.yaml` and `kubectl describe torc trident` to verify~~
- ~~Download codes `cd ~` `git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01`~~
- Verification  `kubectl get pod -n trident`

## 9. Configure CSI (csi-install.sh)
- Use this command to create a clone of this site locally `git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01`
- `cd ~/AnfDemo01/astra`
- `chmod 711 csi-install.sh`
- `./csi-install.sh`
- ~~`kubectl apply -f snapshot.storage.k8s.io_volumesnapshotclasses.yaml`~~
- ~~`kubectl apply -f snapshot.storage.k8s.io_volumesnapshotcontents.yaml`~~
- ~~`kubectl apply -f snapshot.storage.k8s.io_volumesnapshots.yaml`~~
- ~~`kubectl apply -f rbac-snapshot-controller.yaml`~~
- ~~`kubectl apply -f setup-snapshot-controller.yaml`~~

## 10. Create Service Principal
- Creaete a new SP named "http://netapptridentxxx" `az ad sp create-for-rbac --name "http://netapptridentxxx"`
- Take note of the output json. 
- Gain Subection ID `az account show`
- Take note of the output json. 

## 11. modify backend-azure-anf-advanced.json (backend-azure-anf-advanced.json)
- ~~path: trident-installer/sample-input/backends-samples/azure-netapp-files/backend-anf.yaml `cd ~/trident-installer/sample-input/backends-samples/azure-netapp-files/`~~
- `cd ~/AnfDemo01`
- Edit backend-anf.yaml `vim backend-azure-anf-advanced.json`
- Example
<pre>
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
</pre>

## 12. Create backend
- ~~cd to Trident `cd ~/trident-installer`~~
- ~~`kubectl apply -f sample-input/backends-samples/azure-netapp-files/backend-anf.yaml -n trident`~~
- ~~Verify `tridentctl -n trident create backend -f trident-installer/sample-input/backends-samples/azure-netapp-files/backend-anf.yaml`~~
- Execute this command  `tridentctl create backend -f backend-azure-anf-advanced.json -n trident`

## 13. Create StorageClass (anf-storageclass.yaml)
- cd to AnfDemo01 `cd ~/AnfDemo01`
- `kubectl apply -f anf-storageclass.yaml`
- Name: azure-netapp-files
- NFS
- Verify `kubectl get sc`

## 14. Create PVC (anf-pvc.yaml)
- `kubectl apply -f anf-pvc.yaml`
- Name: anf-pvc
- SC name: azure-netapp-files
- Storage 1TiB. RWX
- Verify `kubectl get pvc anf-pvc`

## 15. Create a pod (anf-nginx-pod.yaml)
- `kubectl apply -f anf-nginx-pod.yaml`
- CPU 100m, Mem 128Mi
- Mount path: /mnt/data
- Storage 1TiB. RWX

## 16. Have access to the pods to view mounted status and Snapshot
- Have access with pod  `kubectl exec -it nginx-pod -- /bin/bash`
- `df -h` *view mount status*
- `mount` *view mount status*
- `apt update`
- `apt install -y wget` *Install wget*
- `dd if=/dev/zero of=5m.dat bs=1024 count=5120` *create 5MB test file*

## 17. Create a deployment (nginx-deployment.yaml)
- `kubectl apply -f nginx-deployment.yaml`
- Verification of ReplicaSet  `kubectl get rs`
- Verification of Deployment  `kubectl get deploy`
- To have access to deployment `curl {ip_address}`
- Login to pod  `kubectl exec -it nginx-pod -- /bin/bash`
- Install curl  `apt update && apt install curl -y`  

---