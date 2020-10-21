#!/usr/bin/env bash
help() (
cat << EndOfMessage
Group
    server          : ${DocServer}

Commands:
    start           : ${DocServerStart}
EndOfMessage
)

if [[ $# -eq 0 ]]; then helpAndExit; fi
command=$1; shift

case "$command" in
start) . $(thisDir)/start.sh $@ ;;
*) helpAndExit
esac