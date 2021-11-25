# Azure NetApp Files Hands-on Session: Astra only

K8s cheatsheet(https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

ex)\
kubectl get node\
kubectl get node -o wide\
kubectl describe node\
kubectl get pod -o wide\
kubectl get pod -n {namaespace}

`git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01`

## 1. Create AKS cluster (anf-demo-aks-prework.azcli)
- Resource group: anftest-rg `az group create -n anftest-rg -l japaneast`
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

## 2. Create ANF subnet and delegate the subnet for ANF (anf-create.sh)
- Resource group for Nodes(VMs): MC_anftest-rg_AnfCluster01_japaneast
- Vnet inside MC_anftest-rg_AnfCluster01_japaneast: aks-vnet-xxxxxxxx
- ANF subnet: 10.0.0.0/26

## 3. Create ANF account, pool and volume (anf-create.sh)
- ANF account: anfac01
- Pool named mypool1: 4TB, Standard
- Volume named myvol1: 100GB, NGFSv3
*Running as shell is easier.*
*chmod 711 anf_demo_create_pool_volume.azcli*
*./anf_demo_create_pool_volume.azcli*

## 4. Configure CSI (csi-install.sh)
- Use this command to create a clone of this site locally `git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01`
- `cd ~/AnfDemo01/astra`
- `chmod 711 csi-install.sh`
- `./csi-install.sh`
- ~~`kubectl apply -f snapshot.storage.k8s.io_volumesnapshotclasses.yaml`~~
- ~~`kubectl apply -f snapshot.storage.k8s.io_volumesnapshotcontents.yaml`~~
- ~~`kubectl apply -f snapshot.storage.k8s.io_volumesnapshots.yaml`~~
- ~~`kubectl apply -f rbac-snapshot-controller.yaml`~~
- ~~`kubectl apply -f setup-snapshot-controller.yaml`~~

## 5. Create Astra account
- [Register Astra account](https://cloud.netapp.com/astra-register)    Note) Right-click and open link in a new tab
- [Create login password](https://astra.netapp.io/)    Note) Right-click and open link in a new tab, , and click **"Sign Up"**. (Do NOT click "LOGIN")
- [Login on Astra](https://astra.netapp.io/)   Clickc this link to login

## 6. Create Astra Service Principal
- Obtain the subscription ID  `az account show`
- Create a new Service Principal `az ad sp create-for-rbac --name http://sp-astra-service-principal001 --role contributor --scopes /subscriptions/{SUBSCRIPTION_ID}`
- Copy the outputed JSON\
*Example of JSON*\
{\
  "appId": "4b713e57-b68a-45f6-aac4-itsfakexxxx",\
  "displayName": "xxxxxxxxxxxxxxxxxxx",\
  "name": "4b713e57-b68a-45f6-aac4-itsfakexxxx",\
  "password": "kEb-3zXnxBa7blJNitsfakexxxxxxxxx",\
  "tenant": "588b175c-bf7e-491a-92e5-itsfakexxxxxx"\
}   

## 7. Install Help Chart Repository (anf-astra-helm.txt)
- `helm repo add bitnami https://charts.bitnami.com/bitnami`

## 8. Install MariaDB only
- Install `helm install astramaria bitnami/mariadb -n maria01 --create-namespace`
- Verify `kubectl get po -n maria01`
- Verify `kubectl get po -A`

## 9. Install PostgreSQL only
- Install `helm install astrapost bitnami/postgresql -n postgresql01 --create-namespace`
- Verify `kubectl get po -n postgresql01`
- Verify `kubectl get po -A`

## 10. Install WordPress
- Install `helm install astrawp bitnami/wordpress -n wp01 --create-namespace`
- Verify `kubectl get po -n wp01`
- Verify `kubectl get po -A`

---
