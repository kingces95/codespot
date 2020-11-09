#!/usr/bin/env bash

g() {
    echo g
    declare -p foo
}

f() {
    declare  foo=BAR

    g
    echo f
    declare -p foo
}

f
declare -p foo
