#!/usr/bin/env bash
test() {
    declare foo=bar
    echo env=$(env | grep foo)
}
test
echo index2.foo=$foo