#!/usr/bin/env bash
help() (
cat << EndOfMessage
Group
    resourceGroup   : ${DocResourceGroup}

Commands:
    create          : ${DocResourceGroupCreate}
EndOfMessage
    exit 1
)

if [[ $# -eq 0 ]]; then help; fi
command=$1; shift

case "$command" in
create) . $dir/resourceGroup/create.sh $@ ;;
*) help
esac