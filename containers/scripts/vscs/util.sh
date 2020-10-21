#!/usr/bin/env bash

declareDirs() {
    : ${commit:?}
    : ${build:?}

    if [[ $build == stable ]]
    then
        serverDir=$DirStable
    else
        serverDir=$DirInsider
    fi

    commitDir=$serverDir/bin/$commit
}

evalCmd() {
    cmd=${1:?}

    if $dryRun
    then 
        echo $(whoami) $ $cmd
    else
        eval $cmd >&2
    fi

    exit 0
}