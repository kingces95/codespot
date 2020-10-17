#!/usr/bin/env bash

azBin=~/git/bin
azDockerHubName=kingces95

# sshd
azSshd=sshd
azSshdImage=$azSshd
azSshdDockerfile=dockerfile.$azSshd

# bridge
azBridge=azbridge
azBridgeImage=$azBridge
azBridgeDockerfile=dockerfile.$azBridge
azBridgePackage=$azBin/azbridge.0.2.9-rtm.debian.10-x64.deb

# azcli
azCli=azcli
azCliImage=$azCli
azBridgeDockerfile=dockerfile.$azCli

# vscs
azVscs=vscs
azVscsImage=$azVscs
azVscsDockerfile=dockerfile.$azVscs
azVscsCommit=93c2f0fbf16c5a4b10e4d5f89737d9c2c25488a3

# docker images
docker build -t $azSshdImage -t $azDockerHubName/$azSshdImage . -f $azSshdDockerfile
docker push $azDockerHubName/$azSshdImage

docker build -t $azCliImage -t $azDockerHubName/$azCliImage . -f $azCliDockerfile
docker push $azDockerHubName/$azCliImage

cp $azBin .
docker build -t $azBridgeImage -t $azDockerHubName/$azBridgeImage . -f $azBridgeDockerfile \
    --build-arg AZBRIDGE=$azBridgePackage
docker push $azDockerHubName/$azBridgeImage

docker build -t $azVscsImage -t $azDockerHubName/$azVscsImage . -f $azVscsDockerfile \
    --build-arg COMMIT=$azVscsCommit
docker push $azDockerHubName/$azVscsImage