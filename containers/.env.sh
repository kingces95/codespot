#!/usr/bin/env bash
# standing order, remove any/all duplication!
set -a

# amazon
awsContext=myAwsContext
awsDescription="My Amazon Web Services Context"
awsProfile=default
awsRegion=us-west-1

# azure
azContext=myAzureContext
azSubscriptionId=54941adf-86af-44df-8048-60d8a3f53188
azResourceGroup=myResourceGroup
azLocation=westus2
azDescription="My Azure Context"

# azure network
azVirtualSubnet=mySubnet
azVirtualNetwork=myVirtualNetwork
azFirewall=myFirewall
azFirewallIp=myPublicIp
azFirewallPort=2233
azNatRuleCollection=myNatRuleCollection
azNatRule=myNatRule

# storage
azStorageAccount=myStorageAccount
azWeb=my-web

# container
azContainer=myContainer
azUser=vscode
azUserDir=/home/$azUser
azLogDir=/var/log

# network
azNetwork=myNetwork

# monolith
azDockerHubName=kingces95
azDockerImage=myimage
azDockerImageBase=base
azDockerImageVariant=buster

# relay
azRelayNamespace=myRelayNamespace
azRelay=myRelay
azRelayPolicySend=myRelayPolicySend
azRelayPolicyListen=myRelayPolicyListen
azRelayPolicyAll=myRelayPolicyAll

# bridge
azBridge=my-bridge
azBridgeImage=mybridge
azBridgeDockerfile=dockerfile.bridge
azBridgeImageBase=mcr.microsoft.com/vscode/devcontainers/base
azBridgeImageBaseVariant=buster
azBridgePackage=azbridge.0.2.9-rtm.debian.10-x64.deb
azBridgePortName=ssh
azBridgeRemotePort=22

# bridge cli
azBridgeRepoDir=/Users/Setup/git/azure-relay-bridge
azBridgeRepoReleaseOsx64Dir=$azBridgeRepoDir/src/azbridge/bin/Release/AnyCPU/netcoreapp3.0/osx-x64
alias azbridge="dotnet $azBridgeRepoReleaseOsx64Dir/azbridge.dll $*"
azBridgeLocalIp=127.0.0.1
azBridgeLocalPort=2233

# sshd
azSshd=my-sshd
azSshdImage=mysshd
azSshdDockerfile=dockerfile.sshd
azSshdImageBase=mcr.microsoft.com/vscode/devcontainers/base
azSshdImageBaseVariant=buster
azSshdDebugPort=2222
# ssh-keygen -f id_rsa -t rsa -N "" -q
azSshdRootKey=$(cat id/root/rsa.pub)
azSshdVscodeKey=$(cat id/vscode/rsa.pub)
azKeyRegenerateCmd="cd /etc/ssh && \
    rm *key* && \
    ssh-keygen -A"

# vscode server
azVscs=my-vscs
azVscsImage=myvscs
azVscsDockerfile=dockerfile.vscs
azVscsImageBase=githubtainer-mysshd
azVscsImageBaseVariant=latest

azVscsCommit=2af051012b66169dde0c4dfae3f5ef48f787ff69

#
# create docker images
azEcho=my-echo
azEchoImage=myecho
azEchoDockerfile=dockerfile.echo
docker build -t $azEchoImage -f $azEchoDockerfile --build-arg ARGUMENT=Oahu .

docker tag $azEchoImage $azDockerHubName/githubtainer-$azEchoImage
docker push $azDockerHubName/githubtainer-$azEchoImage
docker run --rm $azEchoImage
docker run -e myVariable=World --rm $azEchoImage

docker build -t $azBridgeImage . \
    -f $azBridgeDockerfile \
    --build-arg IMAGE=$azBridgeImageBase \
    --build-arg VARIANT=$azBridgeImageBaseVariant \
    --build-arg AZBRIDGE=$azBridgePackage

docker tag $azBridgeImage $azDockerHubName/githubtainer-$azBridgeImage
docker push $azDockerHubName/githubtainer-$azBridgeImage

docker build -t $azSshdImage . \
    -f $azSshdDockerfile \
    --build-arg IMAGE=$azSshdImageBase \
    --build-arg VARIANT=$azSshdImageBaseVariant \
    --build-arg ROOT_KEY="$azSshdRootKey" \
    --build-arg VSCODE_KEY="$azSshdVscodeKey"

docker tag $azSshdImage $azDockerHubName/githubtainer-$azSshdImage
docker push $azDockerHubName/githubtainer-$azSshdImage

docker build -t $azVscsImage . \
    -f $azVscsDockerfile \
    --build-arg IMAGE=$azVscsImageBase \
    --build-arg VARIANT=$azVscsImageBaseVariant \
    --build-arg COMMIT=$azVscsCommit

docker tag $azVscsImage $azDockerHubName/githubtainer-$azVscsImage
docker push $azDockerHubName/githubtainer-$azVscsImage

#
# provision docker
docker rm $(docker ps -aq) -f
[ $(docker ps -a --filter name=$azContainer -q) ] && docker rm $azContainer --force

# start nicolaka/netshoot
docker network create $azNetwork
docker run -it --rm \
    --name myNetshoot
    --network $azNetwork \
    nicolaka/netshoot

# start sshd
docker rm -f $azSshd
docker run -d \
    --name $azSshd \
    -p $azSshdDebugPort:22 \
    $azSshdImage

docker exec -it $azSshd bash
ssh-keyscan -p $azSshdDebugPort -t rsa localhost >> known_hosts
ssh-copy-id -i id/root/rsa -p $azSshdDebugPort root@localhost -o UserKnownHostsFile=known_hosts
ssh -i id/root/rsa -o UserKnownHostsFile=known_hosts -p $azSshdDebugPort root@localhost
ssh -i id/vscode/rsa -o UserKnownHostsFile=known_hosts -p $azSshdDebugPort vscode@localhost

# start vscs
docker rm -f $azVscs
docker run -d \
    --name $azVscs \
    -p $azSshdDebugPort:22 \
    --network myNetwork \
    $azVscsImage

ssh-keyscan -p $azSshdDebugPort -t rsa localhost > known_hosts
ssh -i id/vscode/rsa -o UserKnownHostsFile=known_hosts -p $azSshdDebugPort vscode@localhost

# start bridge
echo $azRelayPolicyAllKey > relay_key
docker rm -f $azBridge
docker run -d \
    --name $azBridge \
    --network myNetwork \
    --env name=$azRelay \
    --env namespace=$azRelayNamespace \
    --env host=$azVscs \
    --env port=$azBridgeRemotePort \
    --env portName=$azBridgePortName \
    --env policy=$azRelayPolicyAll \
    --env key=$azRelayPolicyAllKey \
    $azBridgeImage

docker logs $azBridge
docker attach $azContainer --detach-keys="ctrl-e"

azbridge \
    -L $azBridgeLocalIp:$azBridgeLocalPort/$azBridgePortName:$azRelay \
    -e sb://$azRelayNamespace.servicebus.windows.net/ \
    -K $azRelayPolicyAll \
    -k $azRelayPolicyAllKey &

ssh-keyscan -p $azBridgeLocalPort -t rsa 127.0.0.1 >> known_hosts
ssh -i id/root/rsa -o UserKnownHostsFile=known_hosts -p $azBridgeLocalPort root@127.0.0.1
ssh -i id/vscode/rsa -o UserKnownHostsFile=known_hosts -p $azBridgeLocalPort vscode@127.0.0.1

#
# provision azure
azContainer=$azVscs
azImage=$azVscsImage
azPort=$azFirewallPort

time \
az container create \
    --resource-group $azResourceGroup \
    --name $azContainer \
    --vnet $azVirtualNetwork \
    --subnet $azVirtualSubnet \
    --image $azDockerHubName/githubtainer-$azImage

# see also: https://portal.azure.com/
az container list \
    --resource-group $azResourceGroup \
    --output table

az container logs \
    --resource-group $azResourceGroup \
    --name $azContainer

az container exec \
    --resource-group $azResourceGroup \
    --name $azContainer \
    --exec-command "/bin/sh"

# service gets container IP address
azIp=$(az container show \
    --resource-group $azResourceGroup \
    --name $azContainer \
    --query ipAddress.ip \
    | sed s/\"//g) && \
    echo $azIp

azIp=$(az network public-ip show \
    --resource-group $azResourceGroup \
    --name $azFirewallIp \
    --query ipAddress \
    | sed s/\"//g)
    echo $azIp

ssh-keyscan -p $azPort -t rsa $azIp > known_hosts
ssh \
    -o UserKnownHostsFile=known_hosts \
    -i id/root/rsa \
    -o "IdentitiesOnly=yes" \
    -p $azPort \
    root@$azIp

# received user request to login...
azUserPublicKey=$(cat ~/.ssh/id_rsa.pub)
azRepo=https://github.com/kingces95/githubtainer.git

# user installs host public key specific to IP address
mkdir -p ~/.ssh/known_host && \
    echo $azSshRsa > ~/.ssh/known_host/$azIp

# service installs user's public key
azUserSshDir=/home/$azUser/.ssh
ssh \
    -o UserKnownHostsFile=~/.ssh/known_host/$azIp \
    -i ssh/id_rsa \
    -o "IdentitiesOnly=yes" \
    -t root@$azIp "bash -c \" \
        mkdir -p $azUserSshDir && \
        echo $azUserPublicKey > $azUserSshDir/authorized_keys \
    \""

# user can authenticate over ssh
ssh \
    -o UserKnownHostsFile=~/.ssh/known_host/$azIp \
    $azUser@$azIp

# service clones github repo as user
ssh \
    -o UserKnownHostsFile=~/.ssh/known_host/$azIp \
    -i ssh/id_rsa \
    -o "IdentitiesOnly=yes" \
    -t root@$azIp "bash -c \" \
        su -c \\\" \
            git clone $azRepo \
                /home/$azUser/repo \
        \\\" $azUser
    \""

time \
az container restart \
    --resource-group $azResourceGroup \
    --name $azContainer

az container delete \
    --resource-group $azResourceGroup \
    --name $azContainer

az group delete \
    --name $azResourceGroup

# firewall
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

# tags
azResourceId=$(az container show \
    --resource-group $azResourceGroup \
    --name $azContainer \
    --query id \
    | sed s/\"//g) && \
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



# scratch
az container attach \
    --resource-group $azResourceGroup \
    --name $azContainer
