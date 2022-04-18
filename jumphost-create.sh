#!/bin/bash

az network vnet create -g anftest-rg -n aksdemo-vnet \
    --address-prefix 192.168.64.0/22 \
    --subnet-name aksvm-sub --subnet-prefix 192.168.65.0/24

az network vnet subnet create \
    --resource-group anftest-rg \
    --vnet-name aksdemo-vnet \
    --name aksanf-sub \
    --delegations "Microsoft.NetApp/volumes" \
    --address-prefixes 192.168.64.0/26

### Bastion
az network vnet subnet create \
    -g anftest-rg \
    -n AzureBastionSubnet \
    --vnet-name aksdemo-vnet \
    --address-prefixes 192.168.64.64/26

az network public-ip create --resource-group anftest-rg \
    --name anftest-rg-ip \
    --sku Standard

az network bastion create --name AnfBastion \
  --public-ip-address anftest-rg-ip \
  -g anftest-rg --vnet-name aksdemo-vnet \
  -l japaneast

## Ubuntu VM
az vm create -g  anftest-rg \
  --name aksubuntu \
  --size Standard_D2ds_v4  \
  --vnet-name aksdemo-vnet \
  --subnet aksvm-sub \
  --image UbuntuLTS \
  --public-ip-address "" \
  --admin-username anfadmin \
  --admin-password ""