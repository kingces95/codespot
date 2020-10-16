#!/usr/bin/env bash
function pad() (
    printf "%02d" $1
)

log() {
    echo $* >&2
}

function uptime() (
    duration=SECONDS
    seconds=$(($duration % 60))
    minutes=$(($duration / 60))
    hours=$(($duration / (60 * 60)))
    echo "T+$(pad $hours):$(pad $minutes):$(pad $seconds)"
)

azLog() {
    log $ az $*
    az $@
}

azTsv() (
    azLog $@ --output tsv
)

azx() (
    $dir/.index.sh $@
)

azSubscriptionId() (
    azTsv account show --query id
)