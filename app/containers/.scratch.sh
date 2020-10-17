#!/usr/bin/env bash

ssh-keygen
ssh-keygen -f id_rsa -t rsa -N "" -q
ssh-copy-id -i ~/.ssh/id_rsa.pub vscode@localhost -p 2222
ssh-copy-id -i mykey.rsa.pub -o "IdentityFile hostkey.rsa" user@target
ssh -p 2222 vscode@localhost
cat .ssh/authorized_keys
ssh -o "IdentitiesOnly=yes" -i <private key filename> <hostname>
azKeyRegenerateCmd="cd /etc/ssh && \
    rm *key* && \
    ssh-keygen -A"
    
ngrok tcp 22 --log=stdout > ngrok.log &
netstat -p tcp -lna
lsof -iTCP -sTCP:LISTEN
ss

/etc/init.d/ssh
/usr/sbin/sshd -Ddddp 22
/etc/default/ssh
cat /var/log/auth.log | head -n 20
sshd -T
sshd -De
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# azure relay shared
azRelayPortName=ssh
azRelayName=azrelay-githubtainer-com
cnxstring=Endpoint="\
sb://kingces95.servicebus.windows.net/;\
SharedAccessKeyName=all-access;\
SharedAccessKey=zi+jJ9xn3Zn/gnLohq9z8pVfHb3j4jGYaMiSvu1Qh3Y=;\
EntityPath=azrelay-githubtainer-com"

# azure relay local
azRelayLocalPort=2233
azRelayLocalIp=127.0.0.1
azbridge -L $azRelayLocalIp:$azRelayLocalPort/$azRelayPortName:$azRelayName -x $cnxstring
netstat -p tcp -lna | grep $azRelayLocalPort

# azure relay remote
azRelayRemotePort=2244
azbridge -R $azRelayHybridRemote:$azRelayPortName/$azRelayRemotePort -x $cnxstring &
azbridge -R $azRelayHybridRemote:$azRelayPortName/$azRelayRemotePort \
    -E $azEndpoint \
    -K $azRelayHybridRemote \
    -k $azRelayHybridRemoteKey
/usr/sbin/sshd -Ddddp $azRelayRemotePort

getent passwd
docker rm $(docker ps -aq) -f

docker run -d -it --rm --name debian -e TERM=xterm debian bash -c /usr/bin/status.sh
docker run -d -it --rm --name debian debian bash
docker run -d -it --rm --name debian top
docker attach --detach-keys="ctrl-d" debian

azProvisionSshdCmd="\
        echo root:password | chpasswd && \
        mkdir /run/sshd && \
        chmod 0755 /run/sshd && \
        cd /etc/ssh && \
        rm *key* && \
        ssh-keygen -A && \
        $(which sshd) -De"
echo $azProvisionSshdCmd

azProvisionGatewayCmd="azbridge -R \$relay:$azSshd:$azBridgePortName/$azBridgeRemotePort \
    -e sb://\$relayNamespace.servicebus.windows.net/ \
    -K $azRelayPolicyAll \
    -k \$(cat /mnt/secrets/relay_key)"
echo $azProvisionGatewayCmd

ssh-keygen
nat-traverse