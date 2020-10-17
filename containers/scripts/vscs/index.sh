#!/usr/bin/env bash
. $(dirname $BASH_SOURCE)/pkg/cli/index.sh
. $(thisDir)/constants.sh
. $(thisDir)/util.sh

# simplify making recursive calls
azx() (
    $(thisFile) $@
)

# log arguments
log $ azx $*

help() (
cat << EndOfMessage
Group
    vscs            : ${DocVscs}

Subgroups:
    install         : ${DocInstall}
    server          : ${DocServer}
EndOfMessage
    exit 1
)

if [[ $# -eq 0 ]]; then help; fi
command=$1; shift

case "$command" in
install) . $(thisDir)/install.sh $@ ;;
server) . $(thisDir)/server/index.sh $@ ;;
*) help; exit 1
esac