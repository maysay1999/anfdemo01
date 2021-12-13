# Azure NetApp Files Hands-on Session: Astra only

**Architecture and components**
![Architecture and components](https://docs.netapp.com/us-en/astra-control-service/media/learn/astra-cc-arch2.png)

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

## 4. Get access credentials for a managed Kubernetes cluster
`az aks get-credentials -n AnfCluster01 -g anftest-rg`

## 5. Configure CSI (csi-install.sh)
- Use this command to create a clone of this site locally `git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01`
- `cd ~/AnfDemo01/astra`
- `chmod 711 csi-install.sh`
- `./csi-install.sh`
- ~~`kubectl apply -f snapshot.storage.k8s.io_volumesnapshotclasses.yaml`~~
- ~~`kubectl apply -f snapshot.storage.k8s.io_volumesnapshotcontents.yaml`~~
- ~~`kubectl apply -f snapshot.storage.k8s.io_volumesnapshots.yaml`~~
- ~~`kubectl apply -f rbac-snapshot-controller.yaml`~~
- ~~`kubectl apply -f setup-snapshot-controller.yaml`~~

## 6. Create Astra account
- How-to register video: [How to register Astra](https://nam06.safelinks.protection.outlook.com/?url=https%3A%2F%2Fnetapp-my.sharepoint.com%2F%3Av%3A%2Fp%2Flrico%2FEUE9QwNiNAJKo07M9xIW3eIBsnaqdOiVybF0R4RCknUmdA&data=04%7C01%7Cb-mtakemoto%40microsoft.com%7Cd4492be000004031ce0c08d9b9a7ed08%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C637744953221706976%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000&sdata=u8diaB6J0wqmQkP6X4Kr2x%2FX1HDiicl7mFeHQ%2FnRYDk%3D&reserved=0)
1. [Register Cloud Central](https://cloud.netapp.com/)    Note) Right-click and open link in a new tab and click **SIGN UP** on right top
2. [Register Astra account](https://cloud.netapp.com/astra-register)    Note) Right-click and open link in a new tab
3. [Login on Astra](https://astra.netapp.io/)   Click this link to login

## 7. Create Astra Service Principal
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

## 8. Install Help Chart Repository (anf-astra-helm.txt)
- `helm repo add bitnami https://charts.bitnami.com/bitnami`

## 9. Install MariaDB only
- Install `helm install astramaria bitnami/mariadb -n maria01 --create-namespace`
- Verify `kubectl get po -n maria01`
- Verify `kubectl get po -A`

## 10. Install PostgreSQL only
- Install `helm install astrapost bitnami/postgresql -n postgresql01 --create-namespace`
- Verify `kubectl get po -n postgresql01`
- Verify `kubectl get po -A`

## 11. Install WordPress
- Install `helm install astrawp bitnami/wordpress -n wp01 --create-namespace`
- Verify `kubectl get po -n wp01`
- Verify `kubectl get po -A`

## 12. View status of created PV
`kubectl get pv -A`

## 13. Backup maria01 and restore from Astra Backup
- Delete command `kubectl delete ns maria01`
- Verify after restoration `kubectl get po -A`

---
