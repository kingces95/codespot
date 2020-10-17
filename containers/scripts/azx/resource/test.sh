#!/usr/bin/env bash
help() (
cat << EndOfMessage
Command
    app resource test : ${DocResourceTest}

Resource Id Arguments
    --id                    : Resource IDs. If provided, no other
                            "Resource Id" arguments should be specified.
    --resource-group        : Name of resource group.
    --type                  : The resource type (Ex: 'Microsoft.Provider/resC').
    --name                  : The resource name. (Ex: myC). If ommitted, type must 
                            be 'Microsoft.Resources/resourceGroups'.

Arguments
    --query                 : The query to make against the resource's properties.
    --value                 : The value to compare against the query result.
EndOfMessage
)

. $prolog

: ${name=}
: ${resourceGroup=}
: ${type=}
: ${id:=$(azx resource id create \
    --resource-group $resourceGroup \
    --type $type \
    --name $name)}

: ${value:?}
: ${query:?}
test "$(azTsv resource show \
    --id $id \
    --query $query)" = \
    "$value"