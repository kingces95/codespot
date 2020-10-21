#!/usr/bin/env bash
help() (
cat << EndOfMessage
Command
    vscs install            : ${DocInstall}

Arguments
    --commit                : Name of resource group.
    --build                 : Specify 'stable' or 'insiders'. Default: 'stable'.
    --os                    : Target operating system. Default: 'linux'.
    --architecture          : Target architecture. Default: 'x64'.

Debug Arguments
    --dry-run               : Show the commands that would be run.
EndOfMessage
)

declareArgs $@
: ${commit:?}
: ${build:=stable}
: ${os:=linux}
: ${architecture:=x64}
: ${dryRun:=false}

declareDirs
: ${serverDir:?}
: ${commitDir:?}

url=$Host/commit:$commit/server-$os-$architecture
if [[ $build == stable ]]
then
    url=$url/stable
else
    url=$url/insider
fi

mkdir -p ${commitDir}
wget -nv $url -O ${TargzcTemp}
tar -x -f ${TargzcTemp} --strip-components 1 -C ${commitDir}
rm ${TargzcTemp}