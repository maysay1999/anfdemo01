# Azure NetApp Files Hands-on Session: ANF and Astra Control Service

> Explore what Astra Control can bring to your Kubernetes Applications

**Architecture and components**
![Architecture and components](https://docs.netapp.com/us-en/astra-control-service/media/learn/astra-ads-architecture-diagram-v2.png)\

## With Astra Control, you are able to

* Automatically provision persistent storage
* Manage data protection operations at application level
* Automate policy-driven snapshot and backup operations
* Migrate applications with data across Kubernetes clusters

## Your reference

* **[Quick Start](https://docs.netapp.com/us-en/astra-control-service/get-started/quick-start.html)** *Quick start for Astra Control Service*
* **[Official manual](https://docs.netapp.com/us-en/astra-control-service/pdfs/fullsite-sidebar/Astra_Control_Service_documentation.pdf)** *Download Official Astra (ACS) manual here*
* **[Portal login site](https://astra.netapp.io/)** *You can login your permanent Astra Control Service here.*

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

## 2. Create ANF subnet and delegate the subnet for ANF (anf-create.sh)

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

## 3. Get access credentials for a managed Kubernetes cluster

On [Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/overview), execute [az aks get-credentials](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az-aks-get-credentials) command for a managed Kubernetes cluster.

```bash
az aks get-credentials -n AnfCluster01 -g anftest-rg
```

## 4. Register a new Astra account

* Please refer to this video for procedure of Astra registration : [How to register Astra](https://nam06.safelinks.protection.outlook.com/?url=https%3A%2F%2Fnetapp-my.sharepoint.com%2F%3Av%3A%2Fp%2Flrico%2FEUE9QwNiNAJKo07M9xIW3eIBsnaqdOiVybF0R4RCknUmdA&data=04%7C01%7Cb-mtakemoto%40microsoft.com%7Cd4492be000004031ce0c08d9b9a7ed08%7C72f988bf86f141af91ab2d7cd011db47%7C1%7C0%7C637744953221706976%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C3000&sdata=u8diaB6J0wqmQkP6X4Kr2x%2FX1HDiicl7mFeHQ%2FnRYDk%3D&reserved=0)

1. Right-click [Register Cloud Central site](https://cloud.netapp.com/) as "open link in a new tab "and click **SIGN UP** on right top corner
2. Reply to verification request email (Usually he verificaiton request mail is stored in **Spam Folder**)
3. **In a new tab**, go to [Register Astra account](https://cloud.netapp.com/astra) and click "Get Started with Astra Control"
4. Fill out the form on **"fully-managed service FREE PLAN"**
5. In a few seconds, send you to Astra User Interface
6. On the next time, you can have access to [https://astra.netapp.io](https://astra.netapp.io) to have access to [Astra Control Service](https://astra.netapp.io)

## 5. Create Service Principal

* Creaete a new SP named "http://sp-astra-service-principalxxx".  Output such as AppID and Password shall be written on notepad.  

```Bash
az ad sp create-for-rbac --name "http://sp-astra-service-principalxxx" \
  --role contributor \
  --scopes /subscriptions/{your_SUBSCRIPTION_ID}
```

> **Note**  'az ad sp list --display-name "http://sp-astra-service-principal" -o table' command shows you the SP created.  

## 6. Ensure that ANF is set as default storage service

* Set ANF Standard as default StorageClass (CLI)

CLI

```Bash
kubectl patch storageclass netapp-anf-perf-standard -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'`
```

* Set ANF Standard as default StorageClass (GUI)

On Astra --> Clusters --> Storage --> Storage Class --> Choose "netapp-anf-perf-standard" --> Actions --> Set as default

![Set as default sc](https://github.com/maysay1999/anfdemo01/blob/main/images/sc_set_as_default.jpg)

> **Note**   Ensure that ANF is set default of StorageClass with `kubectl get sc` command

## 9. Install Helm Chart Bitnami Repository (anf-astra-helm.txt)

Install Helm Chart Bitnami repository

```Bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

You can find the names of the charts in repositories you have already added.  Installation of MariaDB, PostgreSQL and WordPress is ready.  

```Bash
helm search repo bitnami
```

## 10. Install MariaDB only

* Install

```Bash
kubectl create ns maria01
helm install astramaria bitnami/mariadb -n maria01
```

or 

```Bash
helm install astramaria bitnami/mariadb -n maria01 --create-namespace
```

> **Verify** `kubectl get po -n maria01` or `kubectl get po -A`
> **Note** In case of uninstallation, use *helm uninstall*. `helm uninstall astramaria -n maria01`

## 11. Install PostgreSQL only

- Install `helm install astrapost bitnami/postgresql -n postgresql01 --create-namespace`
- Verify `kubectl get po -n postgresql01`
- Verify `kubectl get po -A`

Note) In case of uninstallation, use *helm uninstall*. `helm uninstall astrapost -n postgresql01`

## 12. Install WordPress

- Install `helm install astrawp bitnami/wordpress -n wp01 --create-namespace`
- Verify `kubectl get po -n wp01`
- Verify `kubectl get po -A`

Note) In case of uninstallation, use *helm uninstall*. `helm uninstall astrawp -n wp01`

## 13. View status of created PV
`kubectl get pv -A`

## 14. Backup maria01 and restore from Astra Backup

- Delete command `kubectl delete ns maria01`
- Verify after restoration `kubectl get po -A`

## 15. Create one more Bucket for Disaster Recovery

```bash
az storage account create \
    -n astrabuckets002 \
    -g astra-backup-rg \
    --kind BlockBlobStorage \
    -l southeastasia  \
    --sku Premium_ZRS
az storage account keys list  --resource-group astra-backup-rg  --account-name astrabuckets002
az storage container create  --name astrafastbucket \
    --account-name astrabuckets002 \
    --account-key s4c6u21XzELk83cjN0pMpTsbJWP1XMv+kSbynitmENMMHDnjhYktIbwvCMJAZK1/W+F/z8fJjvbVyvlgnRFYFAKE
```

## 16. Understand Define feature

To be continued

---
