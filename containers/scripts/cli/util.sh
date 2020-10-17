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

function thisFile() {
    echo ${BASH_SOURCE[1]}
}

function thisDir() {
    echo $(dirname ${BASH_SOURCE[1]})
}