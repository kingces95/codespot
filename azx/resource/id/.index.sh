#!/usr/bin/env bash
help() (
cat << EndOfMessage
Group
    create          : ${DocResourceId}

Commands:
    create          : ${DocResourceIdCreate}
EndOfMessage
    exit 1
)

if [[ $# -eq 0 ]]; then help; fi
command=$1; shift

case "$command" in
create) . $dir/resource/id/create.sh $@ ;;
*) help
esac