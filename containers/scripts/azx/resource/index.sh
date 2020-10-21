#!/usr/bin/env bash
help() (
cat << EndOfMessage
Group
    resource        : ${DocResource}

Subgroups:
    id              : ${DocResourceId}

Commands:
    wait            : ${DocResourceWait}
    test            : ${DocResourceTest}
EndOfMessage
)

if [[ $# -eq 0 ]]; then helpAndExit; fi
command=${1=}; shift

case "$command" in
id) . $(thisDir)/id/index.sh $@ ;;
test) . $(thisDir)/test.sh $@ ;;
wait) . $(thisDir)/wait.sh $@ ;;
*) helpAndExit
esac