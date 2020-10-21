#!/usr/bin/env bash
. $(dirname $BASH_SOURCE)/pkg/cli/index.sh
. $(thisDir)/constants.sh
. $(thisDir)/util.sh

# simplify making recursive calls
# self() (
#     $(thisFile) $@
# )

# selfAs() (
#     user=${1:?}
#     shift
#     sudo su $user -c "$(thisFile) $*"
# )

# log arguments
log $ vscs $*

help() (
cat << EndOfMessage
Group
    vscs            : ${DocVscs}

Subgroups:
    install         : ${DocInstall}
    server          : ${DocServer}
EndOfMessage
)

if [[ $# -eq 0 ]]; then helpAndExit; fi
command=$1; shift

case "$command" in
install) . $(thisDir)/install.sh $@ ;;
server) . $(thisDir)/server/index.sh $@ ;;
*) helpAndExit
esac