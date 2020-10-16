#!/usr/bin/env bash
commit=$1
url=$2
serverDir=$3

targzc=/tmp/vscode.tar.gzc
commitDir=~/$serverDir/bin/$commit
mkdir -p $commitDir && \
    wget -q $url -O $targzc && \
    tar -x \
        -f $targzc \
        --strip-components 1 \
        -C $commitDir && \
    rm $targzc