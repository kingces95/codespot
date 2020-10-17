#!/usr/bin/env bash
commit=$1
os=linux
arch=x64

host=https://update.code.visualstudio.com
url=$host/commit:$commit/server-$os-$arch/insider

./get.sh $commit $url .vscode-server-insiders