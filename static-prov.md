# Azure NetApp Files Hands-on Session: ANF Static Provisioning

> How to create Persistent Volune with ANF in Static Provisioning.  

## Static Provisioning

Static provisioning is basically an upfront purchase of storage that will be used to serve all your cluster’s needs. When using static allocation, administrators need to pre-allocate all PVs. This can be tricky, because to optimize costs and avoid additional allocations, you need precise foreknowledge of how the cluster’s storage resources will be used.

### The source code will be executed in this recipe is available here

```bash
git clone https://github.com/maysay1999/anfdemo01.git AnfDemo01
```

## 1. Create AKS cluster

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

## 2. Create ANF account, pool and volume (anf-create.sh)

ANF account: anfac01

Pool named mypool1: 4TB, Standard

Volume named myvol1: 100GiB, NGFSv3

* Open anf-create.sh with `vi`, `vim` or `code`.

```bash
cd AnfDemo01/
vim anf-create.sh
```

* Edit anf-create.sh.  aks-vnet-xxxxxxxx to be modified as your VNet name under Resource Group, *MC_anftest-rg_AnfCluster01_japaneast*

* Run this shell

```bash
./anf-create.sh
```

## 3. Create PV (anf-pv-nfs.yaml)

* 100GiB, RWX

* NFS client: 10.0.0.4:/nfspath01

```Bash
cd ~/AnfDemo01
kubectl apply -f anf-pv-nfs.yaml
```

> **Verify** `kubectl get pv`

## 4. Create PVC (anf-pvc-nfs.yaml)

* Request storage 1GiB. RWX

```Bash
kubectl apply -f anf-pvc-nfs.yaml
```

> **Verify** `kubectl get pvc`

## 5. Create a pod (anf-nginx-nfs-pod.yaml)

* 0.1 CPU, 128MiB memory

* Mount point: /mnt/azure

* Mount name: disk01

```Bash
kubectl apply -f anf-nginx-nfs-pod.yaml
```

> **Verify** `kubectl get po`

## 6. View mounted status

* Have access with pod

```Bash
kubectl exec -it anf-nginx-nfs-pod -- /bin/bash
```

* View mount status

```Bash
df -h
```
