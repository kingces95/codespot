#!/usr/bin/env bash
# standing order, remove any/all duplication!
set -a

# nat traverse
azNatTraverse=nat-traverse
azNatTraverseImage=mynattraverse
azNatTraverseDockerfile=dockerfile.nat-traverse
azLeftIp=172.18.0.2
azRightIp=172.18.0.3
nat-traverse 40000:$azRightIp:40001
nat-traverse 40001:$azLeftIp:40000
azLeftPpppCmd="pppd updetach noauth passive notty ipparam vpn 10.0.0.1:10.0.0.2"
azRightPpppCmd="pppd nodetach notty noauth"
nat-traverse --cmd="$azLeftPpppCmd" 40000:$azRightIp:40001
nat-traverse --cmd="$azRightPpppCmd" 40001:$azLeftIp:40000
nat-traverse --cmd="pppd updetach noauth passive notty ipparam vpn 10.0.0.1:10.0.0.2" 40000:172.18.0.2:40001
mknod /dev/ppp c 108 0
pppd

#
# create docker images
docker build -t $azNatTraverseImage -f $azNatTraverseDockerfile .
docker run --rm -it --network $azNetwork --name left $azNatImage
docker run --rm -it --network $azNetwork --name right $azNatImage