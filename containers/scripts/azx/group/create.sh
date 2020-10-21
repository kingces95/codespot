#!/usr/bin/env bash
help() (
cat << EndOfMessage
Command
    app group create : ${DocGroupCreate}

Arguments
    --name                  : Name of resource group.
    --location              : Location of resource group.
    --interval              : The polling interval in seconds. Default: 5.
EndOfMessage
)

declareArgs $@
    
: ${name:?}
: ${location:?}
: ${interval:=5}

tput clear
tput sc
while true
do
    tput rc
    uptime
    az group list \
        --output table \
        --query "[?name=='$name'].{ \
            name:name, \
            location:location, \
            status:properties.provisioningState
        }" 

    if ! azx resource test \
        --resource-group $name \
        --type $TypeResourceGroup \
        --query name \
        --value $name
    then
        azLog group create \
            --name $name \
            --location $location >&2
    fi

    sleep $interval
done