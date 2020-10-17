#!/usr/bin/env bash
if [[ -$# -eq 0 ]]
then
    help
    exit 1
fi

while [[ $# -gt 0 ]]
do
    if [[ $1 == "--"* ]]
    then
        param="${1/--/}"
        shift

        # foo-bar -> fooBar
        param=$(echo $param | awk -F"-" '{for(i=2;i<=NF;i++){$i=toupper(substr($i,1,1)) substr($i,2)}} 1' OFS="")

        if [[ $# -eq 0 || $1 == "--"* ]]
        then
            export $param=true
        else        
            export $param="$1"
            shift 
        fi

        # echo $param=${!param}
    else
        echo Expected named argument, but got \'$1\' 1>&2
        exit 1
    fi
done