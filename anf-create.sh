#!/bin/bash

MCRG=MC_anftest-rg_AnfCluster01_japaneast
MCVNET=aks-vnet-xxxxxxxx
az network vnet subnet create \
    --resource-group $MCRG \
    --vnet-name $MCVNET \
    --name netapp-subnet \
    --delegations "Microsoft.NetApp/volumes" \
    --address-prefixes 10.0.0.0/26

# create anf account
az netappfiles account create \
    -g $MCRG \
    --name anfac01 -l japaneast \
    --tags owner=anfdemo location="office A"

# create a pool
az netappfiles pool create \
    --resource-group $MCRG \
    --location japaneast \
    --account-name anfac01 \
    --pool-name mypool1 \
    --size 4 \
    --service-level Standard

# create a volume
az netappfiles volume create \
    --resource-group $MCRG \
    --location japaneast \
    --account-name anfac01 \
    --pool-name mypool1 \
    --name myvol1 \
    --service-level Standard \
    --vnet $MCVNET \
    --subnet netapp-subnet \
    --allowed-clients 0.0.0.0/0 \
    --rule-index 1 \
    --usage-threshold 100 \
    --file-path nfspath01 \
    --protocol-types NFSv3