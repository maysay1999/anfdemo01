# Azure NetApp Files Hands-on Session: Dynamic Provisioning with Trident interact Ubuntu VM

K8s cheatsheet(https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### **Procedure different between Static Provisioning and Dynamic Provisioning**
### **Static Provisioning** ==> 1) pv 2) pvc 3) pod
### **Dynamic Provisioning** ==> 1) sc 2) pvc 3) pod

Examples)\
kubectl get no\
kubectl get nodes -o wide\
kubectl describe node\
kubectl get po -o wide\
kubectl get namespaces -o wide
kubectl get ns {name}\
kubectl get deploy\
kubectl get pv\
kubectl get pvc\
kubectl get sc\
kubectl get svc\
kubectl apply -f {name}.yaml\
kubectl delete -f {name}.yaml

Use this command to create a clone of this site locally\
`git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01`


## 1. Create Ubuntu VM for Trident
- Create a new resource group (anf-demo-aks-prework.azcli)  `az group create -n anftest-rg -l japaneast`
- Create Ubuntu VM [ARM for Ubuntu](https://github.com/maysay1999/anfdemo01/tree/main/trident)

## 2. Create AKS cluster (anf-demo-aks-prework.azcli)
- Resource group: anftest-rg
- Cluster name: AnfCluster01

## 3. Create ANF subnet and delegate the subnet for ANF (anf_demo_create_subnet.azcli)
- Resource group for Nodes(VMs): MC_anftest-rg_AnfCluster01_japaneast
- Vnet inside MC_anftest-rg_AnfCluster01_japaneast: aks-vnet-xxxxxxxx
- ANF subnet: 10.0.0.0/26

## 4. Create ANF account, pool and volume (anf_demo_create_pool_volume.azcli)
- ANF account: anfac01
- Pool named mypool1: 4TB, Standard
- Volume named myvol1: 100GB, NGFSv3
*Running as shell is easier.*
*chmod 711 anf_demo_create_pool_volume.azcli*
*./anf_demo_create_pool_volume.azcli*

## 5. Install kubectl, helm, az cli and git
- Install kubectl `sudo snap install kubectl --classic`
- Install helm `sudo snap install helm --classic`
- Install Azure CLI `curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash`
- Install git `sudo apt install git-all -y`

## 6. Connect AKS cluster to Trident VM
Copy 'az aks get-credentials…' on Azure Portal and paste to Trident VM

## 7. az login to Azure on Trident VM
- `az login --use-device-code`
- `https://microsoft.com/devicelogin`
- Verify with this command `kubectl get deployments --all-namespaces=true`
- Set as default account `az account set -s SUBSCRIPTION_ID`

## 8. Install Trident 
- Download Trident `curl -L -O -C - https://github.com/NetApp/trident/releases/download/v21.07.2/trident-installer-21.07.2.tar.gz`
- Extract tar `tar xzvf trident-installer-21.07.2.tar.gz`
- ~~Copy tridentctl to bin  `cd trident-installer`  `sudo cp tridentctl /usr/local/bin`~~
- Create a Trident Namespace `kubectl create ns trident`
- ~~Install trident with helm `cd helm` `helm install trident trident-operator-21.07.2.tgz - trident`~~
- Deploy Trident operator `kubectl apply -f trident-installer/deploy/bundle.yaml -n trident`
- Create a TridentOrchestrator `kubectl apply -f trident-installer/deploy/crds/tridentorchestrator_cr.yaml` and `kubectl describe torc trident` to verify
- Download codes `cd ~` `git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01`

## 9. Configure CSI
- `cd ~/AnfDemo01/astra`
- `kubectl apply -f snapshot.storage.k8s.io_volumesnapshotclasses.yaml`
- `kubectl apply -f snapshot.storage.k8s.io_volumesnapshotcontents.yaml`
- `kubectl apply -f snapshot.storage.k8s.io_volumesnapshots.yaml`
- `kubectl apply -f rbac-snapshot-controller.yaml`
- `kubectl apply -f setup-snapshot-controller.yaml`

## 10. Create Service Principal
- Creaete a new SP named "http://netapptrident" `az ad sp create-for-rbac --name "http://netapptrident"`
- Gain Subection ID `az acounnt show`

## 11. modify backend-anf.yaml (backend-anf.yaml)
- path: trident-installer/sample-input/backends-samples/azure-netapp-files/backend-anf.yaml `cd ~/trident-installer/sample-input/backends-samples/azure-netapp-files/`
- Edit backend-anf.yaml `vim backend-anf.yaml`
- Note that  ClientID is the same as appID. location: **japaneast**, serviceLevel: **Standard**

## 12. Create backend
- cd to AnfDemo01 `cd ~/trident-installer`
- `kubectl apply -f sample-input/backends-samples/azure-netapp-files/backend-anf.yaml -n trident`
- ~~Verify `tridentctl -n trident create backend -f trident-installer/sample-input/backends-samples/azure-netapp-files/backend-anf.yaml`~~

## 13. Create StorageClass (anf-storageclass.yaml)
- cd to AnfDemo01 `cd ~/AnfDemo01`
- `kubectl apply -f anf-storageclass.yaml`
- Name: azure-netapp-files
- NFS
- Verify `kubectl get sc azure-netapp-files`

## 14. Create PVC (anf-pvc.yaml)
- `kubectl apply -f anf-pvc.yaml`
- Name: anf-pvc
- SC name: azure-netapp-files
- Storage 1TiB. RWX
- Verify `kubectl get pvc -n trident`

## 15. Create a pod (anf-nginx-pod.yaml)
- `kubectl apply -f anf-nginx-pod.yaml`
- CPU 100m, Mem 128Mi
- Mount path: /mnt/data
- Storage 1TiB. RWX

## 16. View mounted status and Snapshot
- df -h
- mount
- dd if=/dev/zero of=5m.dat bs=1024 count=5120

## 17. Create a deployment (nginx-deployment.yaml) --> optional
- `kubectl apply -f nginx_deployment.yaml`
- `kubectl expose deployment nginx-anf-trident --port=80 --type=LoadBalancer`
- `kubectl exec -it nginx-anf-trident -- chmod 755 /usr/share/nginx/html`
- `kubectl cp ./index.html nginx-anf-trident:/usr/share/nginx/html/`

---