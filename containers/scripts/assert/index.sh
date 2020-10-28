#!/usr/bin/env bash
#https://github.com/torokmark/assert.sh/blob/master/assert.sh

if command -v tput &>/dev/null && tty -s; then
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  MAGENTA=$(tput setaf 5)
  NORMAL=$(tput sgr0)
  BOLD=$(tput bold)
else
  RED=$(echo -en "\e[31m")
  GREEN=$(echo -en "\e[32m")
  MAGENTA=$(echo -en "\e[35m")
  NORMAL=$(echo -en "\e[00m")
  BOLD=$(echo -en "\e[01m")
fi

assert::fail() {
  printf "${RED}✖ %s${NORMAL}\n" "$@" >&2
}

assert::pipe_eq() (
  while read line; do
    assert::eq "$line" "$1" "value from pipe != arg"
    shift
  done

  if (( $# != 0 )); then
    assert::fail "Unexpected end of pipe at '$1'"
  fi
)

assert::pipe_eq_exact() (
  IFS= assert::pipe_fields_eq "$@"
)

assert::fails() {
  local statement="$1"
  local msg=${2:-''}

  if (eval $statement); then
    assert::fail "\"$1\" succeeded, expected failure :: ${msg}"
  fi
}

assert::file_does_not_exist() {
  ! test -f "$1"
  assert::ok "$2"
}

assert::non_empty_file_exists() {
  test -s "$1"
  assert::ok "$2"
}

assert::empty_file_exists() {
  test -f "$1" && ! test -s "$1"
  assert::ok "$2"
}

assert::file_exists() {
  test -f "$1"
  assert::ok "$2"
}

assert::ok() {
  local exit_code=$?
  local msg=${1:-''}

  if (( exit_code != 0 )); then
    assert::fail "Exited with ${exit_code} :: ${msg}"
  fi
}

assert::returns() {
  local statement="$1"
  local expected_exit_code="$2"
  local msg=${3:-''}

  (eval $statement)
  assert::ok
}

assert::eq() {
  local expected="$1"
  local actual="$2"
  local msg=${3:-''}

  if [[ "${expected}" != "${actual}" ]]; then
    assert::fail "'${expected}' != '${actual}' :: ${msg}"
    return 1
  fi
}

assert::match() {
  local value="$1"
  local regex="$2"
  local msg=${3:-''}

  if [[ ! "${value}" =~ ${regex} ]]; then
    assert::fail "${value} =~ ${regex} :: ${msg}"
    return 1
  fi
}

assert::not_eq() {
  local expected="$1"
  local actual="$2"
  local msg=${3:-''}

  if [[ "${expected}" == "${actual}" ]]; then
    assert::fail "${expected} != ${actual} :: ${msg}"
    return 1
  fi
}

assert::array_eq() {
  declare -n __expected=$1
  declare -n __actual=$2

  local msg=${3:-''}

  local expected_length=${#__expected[@]}
  local actual_length=${#__actual[@]}
  if (( expected_length != actual_length )); then
    assert::fail "array lengths differ :: ${expected_length} != ${actual_length} :: $msg"
    return 1
  fi

  for i in "${!__expected[@]}"; do 
    if [[ "${__expected[$i]}" != "${__actual[$i]}" ]]; then
      assert::fail "array values differ at index $i :: '${__expected[$i]}' != '${__actual[$i]}' :: $msg"
      return 1
    fi
  done
}

assert::empty() {
  local actual
  local msg

  actual="$1"

  if [ "$#" -ge 2 ]; then
    msg="$2"
  fi

  assert::eq "" "$actual" "$msg"
  return "$?"
}

assert::not_empty() {
  local actual
  local msg

  actual="$1"

  if [ "$#" -ge 2 ]; then
    msg="$2"
  fi

  assert::not_eq "" "$actual" "$msg"
  return "$?"
}

assert::contain() {
  local haystack="$1"
  local needle="$2"
  local msg

  if [ "$#" -ge 3 ]; then
    msg="$3"
  fi

  if [ -z "${needle:+x}" ]; then
    return 0;
  fi

  if [ -z "${haystack##*$needle*}" ]; then
    return 0
  else
    [ "${#msg}" -gt 0 ] && assert::fail "$haystack doesn't contain $needle :: $msg" || true
    return 1
  fi
}

assert::not_contain() {
  local haystack="$1"
  local needle="$2"
  local msg

  if [ "$#" -ge 3 ]; then
    msg="$3"
  fi

  if [ -z "${needle:+x}" ]; then
    return 0;
  fi

  if [ "${haystack##*$needle*}" ]; then
    return 0
  else
    [ "${#msg}" -gt 0 ] && assert::fail "$haystack contains $needle :: $msg" || true
    return 1
  fi
}

assert::gt() {
  local first="$1"
  local second="$2"
  local msg

  if [ "$#" -ge 3 ]; then
    msg="$3"
  fi

  if [[ "$first" -gt  "$second" ]]; then
    return 0
  else
    [ "${#msg}" -gt 0 ] && assert::fail "$first > $second :: $msg" || true
    return 1
  fi
}

assert::ge() {
  local first="$1"
  local second="$2"
  local msg

  if [ "$#" -ge 3 ]; then
    msg="$3"
  fi

  if [[ "$first" -ge  "$second" ]]; then
    return 0
  else
    [ "${#msg}" -gt 0 ] && assert::fail "$first >= $second :: $msg" || true
    return 1
  fi
}

assert::lt() {
  local first="$1"
  local second="$2"
  local msg

  if [ "$#" -ge 3 ]; then
    msg="$3"
  fi

  if [[ "$first" -lt  "$second" ]]; then
    return 0
  else
    [ "${#msg}" -gt 0 ] && assert::fail "$first < $second :: $msg" || true
    return 1
  fi
}

assert::le() {
  local first="$1"
  local second="$2"
  local msg

  if [ "$#" -ge 3 ]; then
    msg="$3"
  fi

  if [[ "$first" -le  "$second" ]]; then
    return 0
  else
    [ "${#msg}" -gt 0 ] && assert::fail "$first <= $second :: $msg" || true
    return 1
  fi
}
