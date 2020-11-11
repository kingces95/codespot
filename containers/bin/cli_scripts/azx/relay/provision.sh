#!/usr/bin/env bash
declareArgs $@

: ${name?}
: ${location?}
: ${timeout?}

echo Creating resource group \'$name\' at \'$location\' ...
id=$(az group create \
    --name $name \
    --location $location \
    --query id \
    --output tsv)
echo id=$id

function cleanup()
{
    echo Deleting resource group \'$name\' ...
    az group delete \
        --name $name \
        --yes
}

trap cleanup EXIT

echo Waiting for resource group deleted ...
az resource wait \
    --id "$id" \
    --deleted \
    --timeout $timeout