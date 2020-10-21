#!/usr/bin/env bash
test() {
    name="foo"
    declare -g foo=bar
    echo test.foo=$foo
    echo env=$(env | grep foo)
}
test
./index2.sh
echo index1.foo=$foo
