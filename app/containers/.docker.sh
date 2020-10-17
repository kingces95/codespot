#!/usr/bin/env bash

commit=228973889bc0e352f7cd11cc14755893f8d81864
dockerHubName=kingces95
azbridge=azbridge.0.2.9-rtm.debian.10-x64.deb

build() (
    name=$1
    container=$2
    variant=$3
    user=$4
    commit=$5
    port=$6

    docker build -t $name . \
        --build-arg CONTAINER=$container \
        --build-arg VARIANT=$variant \
        --build-arg AZBRIDGE=$azbridge

    docker tag $name $dockerHubName/githubtainer-$name
    docker push $dockerHubName/githubtainer-$name

    test() (
        [ $(docker ps --filter name=$name -q) ] && docker rm $name --force

        docker run -dit \
            -p $port:22 \
            -v $(pwd)/ssh:/mnt/secrets \
            -v $(pwd)/
            --name $name \
            $name \
            bash

        serverDir=/home/$user/.vscode-server-insiders
        startServerCmd="$serverDir/bin/$commit/server.sh \
            --host=127.0.0.1 \
            --enable-remote-auto-shutdown \
            --port=0 \
            &> $serverDir/.$commit.log \
            < /dev/null &"

        docker exec $name bash -c " \
            echo root:debugme | chpasswd && \
            echo $user:debugme | chpasswd && \
            install -m 644 -o root -g root \
                /mnt/secrets/id_rsa.pub /etc/authorized_keys && \
            service rsyslog start && \
            service ssh start && \
            echo su -c \"/usr/bin/get_vscs.sh $commit\" $user && \
            echo su -c \"$startServerCmd\" $user && \
            sleep 1 && \
            lsof -iTCP -sTCP:LISTEN && \
            su -c \"lsof -iTCP -sTCP:LISTEN\" $user
        "

        docker exec $name bash -c "ssh-keyscan -t rsa localhost" \
            | sed s/localhost/\[localhost\]\:$port/g \
            > known_host

        userPublicKey=$(cat ~/.ssh/id_rsa.pub)
        userSshDir=/home/$user/.ssh
        ssh \
            -o UserKnownHostsFile=known_host \
            -i ssh/id_rsa \
            -o "IdentitiesOnly=yes" \
            -p $port \
            -t root@localhost "bash -c \" \
                mkdir -p $userSshDir && \
                echo $userPublicKey > $userSshDir/authorized_keys \
            \""
       
        # ssh -p $port -o UserKnownHostsFile=known_host $user@localhost
        ssh -p $port -o UserKnownHostsFile=known_host root@localhost
        # docker attach --detach-keys="ctrl-d" debian
    )

    test
)

# addhost 127.0.0.22 azrelay.githubtainer.com
# removehost azrelay.githubtainer.com
# 
# 
# azbridge -L 127.0.0.22:22:azrelay-githubtainer-com -x $cnxstring

# azbridge -R azrelay-githubtainer-com:2233 -x "Endpoint=sb://kingces95.servicebus.windows.net/;SharedAccessKeyName=all-access;SharedAccessKey=zi+jJ9xn3Zn/gnLohq9z8pVfHb3j4jGYaMiSvu1Qh3Y=;EntityPath=azrelay-githubtainer-com" &

# https://github.com/microsoft/vscode-dev-containers/tree/master/containers/debian
build debian base buster vscode $commit 2222

# https://github.com/microsoft/vscode-dev-containers/tree/master/containers/javascript-node
# build node javascript-node 14 node $commit 2223