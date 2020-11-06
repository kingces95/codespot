#!/usr/bin/env bash

fs::entries() {
    local dir=${1:-'.'}

    for entry in "${dir}"/*; do
        echo "${entry}"
    done
}

fs::dirs() {
    local dir=${1:-'.'}
    local entries

    readarray -t entries < <(fs::entries "$dir")

    for entry in "${entries[@]}"; do
        if [[ -d "${entry}" ]]; then 
            echo "${entry}"
        fi
    done
}

fs::files() {
    local dir=${1:-'.'}
    local entries

    readarray -t entries < <(fs::entries "$dir")

    for entry in "${entries[@]}"; do
        if [[ -f "${entry}" ]]; then 
            echo "${entry}"
        fi
    done
}