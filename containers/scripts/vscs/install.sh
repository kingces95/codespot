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

. $prolog
    
: ${commit:?}
: ${build:=stable}
: ${os:=linux}
: ${architecture:=x64}
: ${dryRun:=false}

host=https://update.code.visualstudio.com
url=$host/commit:$commit/server-$os-$architecture/stable

if [[ $build == stable ]]
then
    url=$url/stable
    serverDir=.vscode-server
else
    url=$url/insider
    serverDir=.vscode-server-insiders
fi

targzc=/tmp/vscode.tar.gzc
commitDir=~/$serverDir/bin/$commit
cmd="mkdir -p $commitDir && \
    wget -q $url -O $targzc && \
    tar -x \
        -f $targzc \
        --strip-components 1 \
        -C $commitDir && \
    rm $targzc"

if $dryRun; then echo $cmd; exit 0; fi