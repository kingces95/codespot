#!/usr/bin/env bash
dir=$(dirname $BASH_SOURCE)
. $dir/index.sh
. $dir/pkg/assert/index.sh

testDir="${dir}/test"

expected=("${testDir}/my dir" "${testDir}/my file")
readarray -t actual < <(fs::entries "${testDir}")
assert::array_eq expected actual \
    'dirs'

expected=("${testDir}/my file")
readarray -t actual < <(fs::files "${testDir}")
assert::array_eq expected actual \
    'files'

expected=("${testDir}/my dir")
readarray -t actual < <(fs::dirs "${testDir}")
assert::array_eq expected actual \
    'dirs'
