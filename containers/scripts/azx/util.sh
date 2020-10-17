#!/usr/bin/env bash

azLog() {
    log $ az $*
    az $@
}

azTsv() (
    azLog $@ --output tsv
)

azSubscriptionId() (
    azTsv account show --query id
)