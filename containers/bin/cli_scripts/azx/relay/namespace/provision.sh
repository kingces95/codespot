#!/usr/bin/env bash
declareArgs $@

: ${resourceGroup?}
: ${name?}

resource/wait.sh \
    --resource-group $resourceGroup \
    --type "Microsoft.Resources/ResourceGroups" \
    --query properties.provisioningState \
    --value Succeeded

cmd="az relay namespace create \
    --resource-group $resourceGroup \
    --name $name"

echo \$ $cmd
eval $cmd