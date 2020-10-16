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

# storage
azStorageAccount=myStorageAccount
azWeb=my-web

# container
azContainer=myContainer
azUser=vscode
azUserDir=/home/$azUser
azLogDir=/var/log

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
azSshdRootKey=$(cat id/root/rsa.pub)
azSshdVscodeKey=$(cat id/vscode/rsa.pub)

# vscode server
azVscs=my-vscs
azVscsImage=myvscs
azVscsDockerfile=dockerfile.vscs
azVscsImageBase=githubtainer-mysshd
azVscsImageBaseVariant=latest
azVscsCommit=2af051012b66169dde0c4dfae3f5ef48f787ff69

# azure cli
azCli=my-azcli
azCliImage=myazcli
azCliDockerfile=dockerfile.azcli
azCliImageBase=githubtainer-mysshd
azCliImageBaseVariant=latest

# create aws docker context
# https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-mac.html
docker context create ecs $awsContext \
    --profile $awsProfile \
    --region $awsRegion \
    --description "$awsDescription"

docker context use $awsContext
docker context inspect $awsContext
docker context rm $awsContext

# create azure docker context
docker context create aci $azContext \
    --subscription-id $azSubscriptionId \
    --description "$azDescription" \
    --resource-group $azResourceGroup \
    --location $azLocation

docker context show
docker context use $azContext
docker context list
docker context inspect $azContext
docker context rm $azContext
docker run -p 80:80 --name $azWeb mcr.microsoft.com/azuredocs/aci-helloworld
docker ps
docker logs $azWeb
docker rm -f $azWeb

# docker images
azEcho=my-echo
azEchoImage=myecho
azEchoDockerfile=dockerfile.echo
docker build -t $azEchoImage . \
    -f $azEchoDockerfile \
    --build-arg ARGUMENT=Oahu
docker tag $azEchoImage $azDockerHubName/githubtainer-$azEchoImage
docker push $azDockerHubName/githubtainer-$azEchoImage
docker run --rm $azEchoImage
docker run -e myVariable=World --rm $azEchoImage

docker build -t $azCliImage . \
    -f $azCliDockerfile \
    --build-arg IMAGE=$azCliImageBase \
    --build-arg VARIANT=$azCliImageBaseVariant
docker tag $azCliImage $azDockerHubName/githubtainer-$azCliImage
docker push $azDockerHubName/githubtainer-$azCliImage

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

# provision docker
docker rm $(docker ps -aq) -f
[ $(docker ps -a --filter name=$azContainer -q) ] && docker rm $azContainer --force

# start sshd
docker rm -f $azSshd
docker run -d \
    --name $azSshd \
    -p $azSshdDebugPort:22 \
    $azSshdImage

docker exec -it $azSshd bash
ssh-keyscan -p $azSshdDebugPort -t rsa localhost > known_hosts
ssh-copy-id -i id/root/rsa -p $azSshdDebugPort root@localhost -o UserKnownHostsFile=known_hosts
ssh -i id/root/rsa -o UserKnownHostsFile=known_hosts -p $azSshdDebugPort root@localhost
ssh -i id/vscode/rsa -o UserKnownHostsFile=known_hosts -p $azSshdDebugPort vscode@localhost
ssh -o ProxyCommand="bash -c ' \
    if ! test -z \$(docker ps -a --filter name=%h -q); then docker rm %h --force; fi && \
    docker run -d --name %h -p %p:22 %h && \
    sleep 2 && \
    nc localhost %p'" \
    -i id/root/rsa -o UserKnownHostsFile=known_hosts root@mysshd -p $azSshdDebugPort

# start vscs
docker rm -f $azVscs
docker run -d \
    --name $azVscs \
    -p $azSshdDebugPort:22 \
    --network myNetwork \
    $azVscsImage

ssh-keyscan -p $azSshdDebugPort -t rsa localhost >> known_hosts
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

# provision azure
azContainer=$azCli
azImage=$azCliImage
azPort=$azFirewallPort

time \
az container create \
    --resource-group $azResourceGroup \
    --name $azContainer \
    --image $azDockerHubName/githubtainer-$azImage

# create resource group
az group create --name $azResourceGroup --location $azLocation
az group delete --name $azResourceGroup

# create relay namespace
az relay namespace create --resource-group $azResourceGroup --name $azRelayNamespace
az relay namespace show   --resource-group $azResourceGroup --name $azRelayNamespace
az relay namespace delete --resource-group $azResourceGroup --name $azRelayNamespace

# create relay 
az relay hyco create --resource-group $azResourceGroup --namespace-name $azRelayNamespace --name $azRelay
az relay hyco show   --resource-group $azResourceGroup --namespace-name $azRelayNamespace --name $azRelay
az relay hyco list   --resource-group $azResourceGroup --namespace-name $azRelayNamespace --output table

# create relay authorization rules
az relay hyco authorization-rule create \
    --resource-group $azResourceGroup --namespace-name $azRelayNamespace --hybrid-connection-name $azRelay \
    --name $azRelayPolicySend \
    --rights Send

az relay hyco authorization-rule create \
    --resource-group $azResourceGroup --namespace-name $azRelayNamespace --hybrid-connection-name $azRelay \
    --name $azRelayPolicyListen \
    --rights Listen

az relay hyco authorization-rule create \
    --resource-group $azResourceGroup --namespace-name $azRelayNamespace --hybrid-connection-name $azRelay \
    --name $azRelayPolicyAll \
    --rights Listen Send Manage

# get relay authorization rule keys
azRelaySendPolicyKey=$(
    az relay hyco authorization-rule keys list \
    --resource-group $azResourceGroup \
    --namespace-name $azRelayNamespace \
    --hybrid-connection-name $azRelay \
    --name $azRelayPolicySend \
    --query primaryKey \
    --output tsv)

azRelayPolicyListenKey=$(
    az relay hyco authorization-rule keys list \
    --resource-group $azResourceGroup \
    --namespace-name $azRelayNamespace \
    --hybrid-connection-name $azRelay \
    --name $azRelayPolicyListen \
    --query primaryKey \
    --output tsv)

azRelayPolicyAllKey=$(
    az relay hyco authorization-rule keys list \
    --resource-group $azResourceGroup \
    --namespace-name $azRelayNamespace \
    --hybrid-connection-name $azRelay \
    --name $azRelayPolicyAll \
    --query primaryKey \
    --output tsv)

# see also: https://portal.azure.com/
az container list --resource-group $azResourceGroup --output table
az container logs --resource-group $azResourceGroup --name $azContainer
az container exec --resource-group $azResourceGroup --name $azContainer --exec-command "/bin/sh"
az container restart --resource-group $azResourceGroup --name $azContainer
az container delete --resource-group $azResourceGroup --name $azContainer --yes

# service gets container IP address
azIp=$(az container show \
    --resource-group $azResourceGroup \
    --name $azContainer \
    --query ipAddress.ip \
    --output tsv) && \
    echo $azIp

azIp=$(az network public-ip show \
    --resource-group $azResourceGroup \
    --name $azFirewallIp \
    --query ipAddress \
    --output tsv)
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

# scratch
az container attach \
    --resource-group $azResourceGroup \
    --name $azContainer

# managed identity
appResourceGroup=myAppResourceGroup
appLocation=westus2
appKeyVault=myKeyVault42
appSecretName=mySecret
appSecretValue="My Secret"
appSecretDescription="My Secret Description"
appIdentity=myIdentity
appContainer=my-app-container
appImage=myazcli
appContainerImage=$azDockerHubName/githubtainer-$appImage
# appContainerImage=kingces95/githubtainer-mysshd
# appContainerImage=kingces95/githubtainer-azure-cli
# appContainerImage=mcr.microsoft.com/vscode/devcontainers/azure-cli
# appContainerImage=mcr.microsoft.com/azure-cli

docker build . -t $appImage
docker tag azure-cli $azDockerHubName/githubtainer-$appImage
docker push $azDockerHubName/githubtainer-$appImage

az group create \
    --name $appResourceGroup \
    --location $appLocation

az group delete \
    --name $appResourceGroup \
    --location $appLocation \
    --yes

az keyvault create \
    --name $appKeyVault \
    --resource-group $appResourceGroup \
    --location $appLocation

az keyvault secret set \
    --vault-name $appKeyVault \
    --name $appSecretName \
    --value "$appSecretValue" \
    --description "$appSecretDescription"

az identity create \
    --resource-group $appResourceGroup \
    --name $appIdentity

az identity delete \
    --resource-group $appResourceGroup \
    --name $appIdentity

# Get service principal ID of the user-assigned identity
appServicePrincipalId=$(az identity show \
    --resource-group $appResourceGroup \
    --name $appIdentity \
    --query principalId \
    --output tsv)
echo $appServicePrincipalId

# Get resource ID of the user-assigned identity
appIdentityId=$(az identity show \
    --resource-group $appResourceGroup \
    --name $appIdentity \
    --query id \
    --output tsv)
echo $appIdentityId

az keyvault set-policy \
    --name $appKeyVault \
    --resource-group $appResourceGroup \
    --object-id $appServicePrincipalId \
    --secret-permissions get

time \
az container create \
    --resource-group $appResourceGroup \
    --name $appContainer \
    --ip-address public \
    --ports 22 \
    --assign-identity $appIdentityId \
    --image $appContainerImage

appIp=$(az container show --resource-group $appResourceGroup --name $appContainer --query ipAddress.ip --output tsv)
ssh-keyscan -t rsa $appIp > known_hosts
ssh -o UserKnownHostsFile=known_hosts -i id/root/rsa -o "IdentitiesOnly=yes" root@$appIp
az keyvault secret show --name $appSecretName --vault-name $appKeyVault --query value

docker run --rm -it --name azCli $appContainerImage
az container show --resource-group $appResourceGroup --name $appContainer
az container logs --resource-group $appResourceGroup --name $appContainer
az container attach --resource-group $appResourceGroup --name $appContainer
az container delete --resource-group $appResourceGroup --name $appContainer --yes
az container exec \
    --resource-group $appResourceGroup \
    --name $appContainer \
    --exec-command "/bin/bash"

time \
az container create \
    --resource-group $azResourceGroup \
    --ip-address public \
    --ports 22 \
    --name $azCli \
    --image $azDockerHubName/githubtainer-$azCliImage
az container exec --resource-group $azResourceGroup --name $azCli --exec-command "/bin/sh"
az container delete --resource-group $azResourceGroup --name $azCli --yes
az container logs --resource-group $azResourceGroup --name $azCli
azIp=$(az container show --resource-group $azResourceGroup --name $azCli --query ipAddress.ip --output tsv)
ssh-keyscan -t rsa $azIp > known_hosts
ssh \
    -o UserKnownHostsFile=known_hosts \
    -i id/root/rsa \
    -o "IdentitiesOnly=yes" \
    root@$azIp

time \
az container create \
    --resource-group $azResourceGroup \
    --name $azVscs \
    --image $azDockerHubName/githubtainer-$azVscsImage \
    --command-line "tail -f /dev/null"
az container exec --resource-group $azResourceGroup --name $azVscs --exec-command "/bin/sh"
az container delete --resource-group $azResourceGroup --name $azVscs --yes