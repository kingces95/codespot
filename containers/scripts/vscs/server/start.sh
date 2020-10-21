
#!/usr/bin/env bash
help() (
cat << EndOfMessage
Command
    vscs server start : ${DocServerStart}

Arguments
    --commit                : Name of resource group.
    --build                 : Specify 'stable' or 'insiders'. Default: 'stable'.
    --run-as                : Name of user to use to launch server. 

Debug Arguments
    --dry-run               : Show the commands that would be run.
EndOfMessage
)

declareArgs $@
: ${commit:?}
: ${user=}
: ${build:=stable}
: ${dryRun:=false}

if [[ -n $user ]]
then
    selfAs $user server start --commit 1234 --dry-run
    exit
fi

declareDirs
: ${serverDir:?}
: ${commitDir:?}

evalCmd "$serverDir/bin/$commit/server.sh \
    --host=127.0.0.1 \
    --enable-remote-auto-shutdown \
    --port=0 \
    &> $serverDir/.$commit.log \
    < /dev/null &"