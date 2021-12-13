MCRG=MC_anftest-rg_AnfCluster01_japaneast
MCVNET=aks-vnet-xxxxxxxx
az network vnet subnet create \
    --resource-group $MCRG \
    --vnet-name $MCVNET \
    --name netapp-subnet \
    --delegations "Microsoft.NetApp/volumes" \
    --address-prefixes 10.0.0.0/26