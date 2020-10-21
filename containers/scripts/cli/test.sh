#!/usr/bin/env bash
. $(dirname $BASH_SOURCE)/index.sh
. $(cli::this_dir)/pkg/assert/index.sh

assert::eq "$@" "--help" \
    "implicit '--help' when no args passed"

set -- "--foo" "bar baz"
cli::declare_args "$@"
assert::eq "$ARG_FOO" "bar baz" \
    "named string argument"
unset ARG_FOO

set -- "--foo"
cli::declare_args "$@"
assert::eq "$ARG_FOO" "true" \
    "named boolean argument"
unset ARG_FOO

set -- "--foo-bar"
cli::declare_args "$@"
assert::eq "$ARG_FOO_BAR" "true" \
    "replace dash with underbar"
unset ARG_FOO_BAR

assert::eq "$(cli::this_file)" "${BASH_SOURCE[0]}" \
    "cli::this_file"

assert::eq "$(cli::this_dir)" "$(dirname ${BASH_SOURCE[0]})" \
    "cli::this_dir"

assert::match $(cli::up_time) "T\+[0-9][0-9]:[0-9][0-9]:[0-9][0-9]" \
    "cli::up_time format"

test/test