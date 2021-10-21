# Azure NetApp Files Hands-on Session: Astra only

K8s cheatsheet(https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

ex)\
kubectl get node\
kubectl get node -o wide\
kubectl describe node\
kubectl get pod -o wide\
kubectl get pod -n {namaespace}

git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01

## 1. Create AKS cluster (anf-demo-aks-prework.azcli)
- Resource group: anftest-rg `az group create -n anftest-rg -l japaneast`
- Cluster name: AnfCluster01

## 2. Create ANF subnet and delegate the subnet for ANF (anf_demo_create_subnet.azcli)
- Resource group for Nodes(VMs): MC_anftest-rg_AnfCluster01_japaneast
- Vnet inside MC_anftest-rg_AnfCluster01_japaneast: aks-vnet-xxxxxxxx
- ANF subnet: 10.0.0.0/26

## 3. Create ANF account, pool and volume (anf_demo_create_pool_volume.azcli)
- ANF account: anfac01
- Pool named mypool1: 4TB, Standard
- Volume named myvol1: 100GB, NGFSv3
*Running as shell is easier.*
*chmod 711 anf_demo_create_pool_volume.azcli*
*./anf_demo_create_pool_volume.azcli*

## 4. Configure CSI (container storage interface)
- `cd ~/AnfDemo01/astra`
- `kubectl apply -f snapshot.storage.k8s.io_volumesnapshotclasses.yaml`
- `kubectl apply -f snapshot.storage.k8s.io_volumesnapshotcontents.yaml`
- `kubectl apply -f snapshot.storage.k8s.io_volumesnapshots.yaml`
- `kubectl apply -f rbac-snapshot-controller.yaml`
- `kubectl apply -f setup-snapshot-controller.yaml`

## 9. Create Astra Service Principal
- Obtain the subscription ID  `az account show`
- Create a new Service Principal namaed http://sp-astra-service-principal  `az ad sp create-for-rbac --name http://sp-astra-service-principal --role contributor --scopes /subscriptions/{SUBSCRIPTION_ID}`
- Copy the outputed JSON
It's an example of JSON.\
`{\
  "appId": "4b713e57-b68a-45f6-aac4-itsfakexxxx",\
  "displayName": "http://sp-astra-service-principal",\
  "name": "4b713e57-b68a-45f6-aac4-itsfakexxxx",\
  "password": "kEb-3zXnxBa7blJNitsfakexxxxxxxxx",\
  "tenant": "588b175c-bf7e-491a-92e5-itsfakexxxxxx"\
}`   

## 10. Install Apps (anf-astra-helm.txt)
- Install WordPress with MariaDB
- Install MySQL
- Install PostgreSQL 

## 11. Useful command for Astra
kubectl get sc\
K8s cheatsheet(https://kubernetes.io/docs/reference/kubectl/cheatsheet/)