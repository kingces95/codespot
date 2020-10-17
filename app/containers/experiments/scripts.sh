azResourceGroup=myResourceGroup

azNat=nat
azNatImage=mynat
azNatDockerfile=dockerfile.nat

# nat image
docker build -t $azNatImage -f $azNatDockerfile .
docker run --rm -it --network $azNetwork --name left $azNatImage
docker run --rm -it --network $azNetwork --name right $azNatImage

# nat experiment
azNatLeftIp=172.18.0.2
azNatRightIp=172.18.0.3
nat-traverse 40000:$azNatRightIp:40001
nat-traverse 40001:$azNatLeftIp:40000
azNatLeftPpppCmd="pppd updetach noauth passive notty ipparam vpn 10.0.0.1:10.0.0.2"
azNatRightPpppCmd="pppd nodetach notty noauth"
nat-traverse --cmd="$azNatLeftPpppCmd" 40000:$azNatRightIp:40001
nat-traverse --cmd="$azNatRightPpppCmd" 40001:$azNatLeftIp:40000
nat-traverse --cmd="pppd updetach noauth passive notty ipparam vpn 10.0.0.1:10.0.0.2" 40000:172.18.0.2:40001
mknod /dev/ppp c 108 0
pppd

# fractional cpu
azFractionalCpu=my-fractional-cpu

time \
az container create -g $azResourceGroup -n $azFractionalCpu --image debian --ip-address public --cpu 0.05
az container exec   -g $azResourceGroup -n $azFractionalCpu --exec-command "/bin/bash"
az container delete -g $azResourceGroup -n $azFractionalCpu --yes

# firewall
azNetwork=myNetwork
azVirtualNetwork=myVirtualNetwork
azFirewall=myFirewall
azFirewallIp=myPublicIp
azFirewallPort=2233
azNatRuleCollection=myNatRuleCollection
azNatRule=myNatRule

az network public-ip list \
--resource-group $azResourceGroup \
    --output table

az network firewall list \
    --resource-group $azResourceGroup \
    --output table

az network firewall nat-rule collection list \
    --resource-group $azResourceGroup \
    --firewall-name $azFirewall \
    --output table

az network firewall nat-rule list \
    --resource-group $azResourceGroup \
    --firewall-name $azFirewall \
    --collection-name $azNatRuleCollection \
    --output table \
    --query "rules[].{ \
        name:name, \
        source:sourceAddresses[0], \
        destination:destinationAddresses[0], \
        DestinationPort:destinationPorts[0], \
        target:translatedAddress, \
        targetPort:translatedPort \
    }"

time \
az network firewall nat-rule create \
    --resource-group $azResourceGroup \
    --firewall-name $azFirewall \
    --collection-name $azNatRuleCollection \
    --name $azNatRule \
    --protocols TCP \
    --destination-addresses 51.143.50.230 \
    --destination-ports 2233 \
    --translated-port 22 \
    --source-addresses 141.239.208.198 \
    --translated-address 10.0.2.4 

time \
az network firewall nat-rule delete \
    --resource-group $azResourceGroup \
    --firewall-name $azFirewall \
    --collection-name $azNatRuleCollection \
    --name $azNatRule

azVirtualSubnet=mySubnet
azPort=$azFirewallPort

time \
az container create \
    --resource-group $azResourceGroup \
    --name $azContainer \
    --ip-address public \
    --vnet $azVirtualNetwork \
    --subnet $azVirtualSubnet \
    --image $azDockerHubName/githubtainer-$azImage

ssh-keyscan -p $azPort -t rsa $azIp > known_hosts
ssh \
    -o UserKnownHostsFile=known_hosts \
    -i id/root/rsa \
    -o "IdentitiesOnly=yes" \
    -p $azPort \
    root@$azIp

# start nicolaka/netshoot
docker network create $azNetwork
docker run -it --rm \
    --name myNetshoot
    --network $azNetwork \
    nicolaka/netshoot


# tags
azResourceId=$(az container show \
    --resource-group $azResourceGroup \
    --name $azContainer \
    --query id \
    --output tsv) && \
    echo $azResourceId
    
# serialize host public key
azSshRsaBase64=$(echo $azSshRsa | base64)
azSshRsaBase64_0=$(echo $azSshRsaBase64 | cut -c 1-250)
azSshRsaBase64_250=$(echo $azSshRsaBase64 | cut -c 251-500)
azSshRsaBase64_500=$(echo $azSshRsaBase64 | cut -c 501-528)

# tag commit, user, ip, host public key
az tag create \
    --resource-id $azResourceId \
    --tags user=$azUser \
           vscode_server_commit=$azVscsCommit \
           sshRsaBase64_0=$azSshRsaBase64_0 \
           sshRsaBase64_250=$azSshRsaBase64_250 \
           sshRsaBase64_500=$azSshRsaBase64_500

# get host public key
az tag list \
    --resource-id $azResourceId

# deserialize host public key
azSshRsaBase64_0=$(az tag list --resource-id $azResourceId --query properties.tags.sshRsaBase64_0)
azSshRsaBase64_250=$(az tag list --resource-id $azResourceId --query properties.tags.sshRsaBase64_250)
azSshRsaBase64_500=$(az tag list --resource-id $azResourceId --query properties.tags.sshRsaBase64_500)
azSshRsaBase64=$(echo $azSshRsaBase64_0$azSshRsaBase64_250$azSshRsaBase64_500 | sed s/\"//g)
azSshRsa=$(echo $azSshRsaBase64 | base64 -d)
echo $azSshRsa

# scratch
azStorageAccount=kingces95storage
azStorageShare=kingces95share

azStorageAccountKey=$( \
    az storage account keys list \
        --resource-group $azResourceGroup \
        --account-name $azStorageAccount \
        --query "[0].value" | tr -d '"' \
)

az storage account create \
    --resource-group $azResourceGroup \
    --name $azStorageAccount \
    --location $azLocation \
    --kind StorageV2 \
    --sku Standard_LRS

az storage share create \
    --account-name $azStorageAccount \
    --account-key $storageAccountKey \
    --name $azStorageShare \
    --quota 1024

az storage file upload \
    --account-name $azStorageAccount \
    --account-key $storageAccountKey \
    --share-name $azStorageShare \
    --source "~/.ssh/id_rsa.pub"