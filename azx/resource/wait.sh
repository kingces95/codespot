#!/usr/bin/env bash
help() (
cat << EndOfMessage
Command
    app resource wait : ${DocResourceWait}

Resource Id Arguments
    --ids                   : Resource IDs. If provided, no other
                            "Resource Id" arguments should be specified.
    --resource-group        : Name of resource group.
    --type                  : The resource type (Ex: 'Microsoft.Provider/resC').
    --name                  : The resource name. (Ex: myC). If ommitted, type must 
                            be 'Microsoft.Resources/ResourceGroups'.

Arguments
    --query                 : The query to make against the resource's properties.
    --value                 : The value to compare against the query result.
    --interval              : The polling interval in seconds. Default: 5.
EndOfMessage
)

. $dir/.prolog.sh

: ${value:?}
: ${query:?}
: ${interval=5}

id=$(azx resource id create \
    --ids $ids \
    --resource-group $resourceGroup \
    --type $type \
    --name $name)

tput sc
while true
do
    current=$(azTsv resource show --ids $id --query $query)

    tput rc
    log $current

    if [[ ! $? -eq 0 || "$value" != "$current" ]]
    then
        sleep $interval
        continue
    fi

    exit 0
done