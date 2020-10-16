#!/usr/bin/env bash
commit=$1
serverDir=/home/$(whoami)/.vscode-server
$serverDir/bin/$commit/server.sh \
    --host=127.0.0.1 \
    --enable-remote-auto-shutdown \
    --port=0 \
    &> $serverDir/.$commit.log \
    < /dev/null &