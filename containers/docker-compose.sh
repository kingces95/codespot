#!/usr/bin/env bash

echo "version: \"3.7\""
echo 
echo "services:"
echo "  my-vscs:"
echo "    image: kingces95/githubtainer-myvscs"
echo 
echo "  my-bridge:"
echo "    image: kingces95/githubtainer-mybridge"
echo "    environment:"
echo "      - name=$azRelay"
echo "      - namespace=$azRelayNamespace"
echo "      - host=$azVscs"
echo "      - port=$azBridgeRemotePort"
echo "      - portName=$azBridgePortName"
echo "      - policy=$azRelayPolicyAll"
echo "      - key=$azRelayPolicyAllKey"