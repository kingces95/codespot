#!/usr/bin/env bash

commit=$1
os=${2-linux}
arch=${3-x64}

# construct vscode server url
constructUrl() (
   host=https://update.code.visualstudio.com
   segCommit=commit:$commit
   segPlatform=server-$os-$arch
   segBuild=$1
   echo $host/$segCommit/$segPlatform/$segBuild
)
insiderUrl=$(constructUrl insider)
stableUrl=$(constructUrl stable)

# test commit is stable or insiders
if wget -q --spider $insiderUrl; then {
   url=$insiderUrl
   dirName=.vscode-server-insiders
} elif wget -q --spider $stableUrl; then {
   url=$stableUrl
   dirName=.vscode-server
} else {
   echo Bad insider url $insiderUrl
   echo Bad stable url $stableUrl
   echo Failed to download VSCode server.
   exit 1
} fi

# construct directory hosting vscode server
commitDir=$dirName/bin/$commit

# impersonate user to install vscode server
pushd ~ > /dev/null

# create vscode server directory
mkdir -p $commitDir

# download and extract vscode server
targz=$commitDir/vscode.tar.gzc
wget $url -q -O $targz && \
   tar -xf $targz --strip-components 1 -C $commitDir

# start server
$(pwd)/$commitDir/server.sh \
   --host=127.0.0.1 \
   --enable-remote-auto-shutdown \
   --port=0 \
&> $dirName/.$commit.log \
< /dev/null &

popd > /dev/null
