# AND Hands-on Session: ASK version

K8s cheatsheet(https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
ex)
kubectl get node
kubectl get node -o wide
kubectl describe node
kubectl get pod -o wide

git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01

## 1. Create AKS cluster (anf-demo-aks-prework.azcli)
- Resource group: anftest-rg
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

## 4. Create PV (anf-pv-nfs.yaml)
- 100GiB, RWX
- NFS client: 10.0.0.4:/nfspath01

## 4. Create PVC (anf-pvc-nfs.yaml)
- Request storage 1GiB. RWX

## 5. Create a pod (anf-nginx-nfs-pod.yaml)
- 0.1 CPU, 128MiB memory
- Mount point: /mnt/azure:/disk01

## 6. View mounted status and Snapshot
- df -h
- mount

## 7. Preparation for Astra 1 (CSI)
- astra/snapshot.storage.k8s.io_volumesnapshotclasses.yaml
- astra/snapshot.storage.k8s.io_volumesnapshotcontents.yaml
- astra/snapshot.storage.k8s.io_volumesnapshots.yaml
- astra/rbac-snapshot-controller.yaml
- astra/setup-snapshot-controller.yaml

## 8. Preparation for Astra 2 (SP)
`az ad sp create-for-rbac --name http://sp-astra-service-principal --role contributor --scopes /subscriptions/SUBSCRIPTION_ID`

## 9. Install Apps (anf-astra-helm.txt)
- Install WordPress with MariaDB
- Install MySQL
- Install PostgreSQL 

## 10. Useful command for Astra
kubectl get sc\
K8s cheatsheet(https://kubernetes.io/docs/reference/kubectl/cheatsheet/)