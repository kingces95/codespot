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
    exit 1
)

if [[ $# -eq 0 ]]; then help; fi
command=${1=}; shift

case "$command" in
id) . $dir/resource/id/.index.sh $@ ;;
test) . $dir/resource/test.sh $@ ;;
wait) . $dir/resource/wait.sh $@ ;;
*) help
esac