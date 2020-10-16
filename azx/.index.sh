#!/usr/bin/env bash
dir=$(dirname $0)

. $dir/.constants.sh
. $dir/.shell.sh
. $dir/.util.sh
. $dir/.context.sh


log $ azx $*

help() (
cat << EndOfMessage
Group
    app             : ${DocApp}

Subgroups:
    resource        : ${DocResource}
EndOfMessage
    exit 1
)

if [[ $# -eq 0 ]]; then help; fi
command=$1; shift

case "$command" in
resource) . $dir/resource/.index.sh $@ ;;
resourceGroup) . $dir/resourceGroup/.index.sh $@ ;;
*) help; exit 1
esac