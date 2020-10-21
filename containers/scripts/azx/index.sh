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
cat << END
Group
  app             : ${DocApp}

Subgroups:
  resource        : ${DocResource}
END
)

if [[ $# -eq 0 ]]; then 
  set -- '--help'
fi

command=$1
shift

case "$command" in
  resource) . $(thisDir)/resource/index.sh $@ ;;
  group) . $(thisDir)/group/index.sh $@ ;;
  *) helpAndExit
esac