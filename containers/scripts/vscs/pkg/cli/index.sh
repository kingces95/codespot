#!/usr/bin/env bash
. $(dirname $BASH_SOURCE)/util.sh
. $(thisDir)/constants.sh
. $(thisDir)/shell.sh

prolog=$(thisDir)/prolog.sh

# https://stackoverflow.com/questions/64398060/expect-test-of-exit-code-in-exit-trap-to-be-non-zero-if-exit-due-to-variable-che
# function exiting {
#     echo DONE result=$?
# }
# trap exiting EXIT