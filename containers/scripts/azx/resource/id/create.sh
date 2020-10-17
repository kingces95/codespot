#!/usr/bin/env bash
help() (
cat << EndOfMessage
Command
    app resource id create : ${DocResourceIdCreate}

Resource Id Arguments
    --id                    : Resource IDs. If provided, no other
                            "Resource Id" arguments should be specified.
    --resource-group        : Name of resource group.
    --type                  : The resource type (Ex: 'Microsoft.Provider/resC').
    --name                  : The resource name. (Ex: myC). If ommitted, type must 
                            be 'Microsoft.Resources/resourceGroups'.
EndOfMessage
)

. $prolog

: ${id=}
if [[ ! -z "$id" ]]
then
    echo $id
    return
fi

: ${resourceGroup:?}
: ${type:?}
: ${name=}

id=/subscriptions/$(azSubscriptionId)/resourceGroups/$resourceGroup

if [[ "$type" != "$TypeResourceGroup" || ! -z "$name" ]]
then
    : ${name:?}

    id=$id/providers/$type/$name
fi

echo $id