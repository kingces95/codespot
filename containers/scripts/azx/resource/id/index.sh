#!/usr/bin/env bash
help() (
cat << EndOfMessage
Group
    create          : ${DocResourceId}

Commands:
    create          : ${DocResourceIdCreate}
EndOfMessage
)

if [[ $# -eq 0 ]]; then helpAndExit; fi
command=$1; shift

case "$command" in
create) . $(thisDir)/create.sh $@ ;;
*) helpAndExit
esac