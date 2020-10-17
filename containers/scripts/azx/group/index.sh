#!/usr/bin/env bash
help() (
cat << EndOfMessage
Group
    group   : ${DocGroup}

Commands:
    create          : ${DocGroupCreate}
EndOfMessage
    exit 1
)

if [[ $# -eq 0 ]]; then help; fi
command=$1; shift

case "$command" in
create) . $(thisDir)/create.sh $@ ;;
*) help
esac