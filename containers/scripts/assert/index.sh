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

assert::log() {
  printf "${RED}✖ %s${NORMAL}\n" "$@" >&2
}

assert::eq() {
  local expected="$1"
  local actual="$2"
  local msg=${3:-''}

  if [[ "${expected}" != "${actual}" ]]; then
    assert::log "${expected} == ${actual} :: ${msg}"
    return 1
  fi
}

assert::match() {
  local value="$1"
  local regex="$2"
  local msg=${3:-''}

  if [[ ! "${value}" =~ ${regex} ]]; then
    assert::log "${value} =~ ${regex} :: ${msg}"
    return 1
  fi
}

assert::not_eq() {
  local expected="$1"
  local actual="$2"
  local msg=${3:-''}

  if [[ "${expected}" == "${actual}" ]]; then
    assert::log "${expected} != ${actual} :: ${msg}"
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
    assert::log "array lengths differ :: ${expected_length} != ${actual_length} :: $msg"
    return 1
  fi

  for i in "${!__expected[@]}"; do 
    if [[ "${__expected[$i]}" != "${__actual[$i]}" ]]; then
      assert::log "array values differ at index $i :: '${__expected[$i]}' != '${__actual[$i]}' :: $msg"
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
    [ "${#msg}" -gt 0 ] && assert::log "$haystack doesn't contain $needle :: $msg" || true
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
    [ "${#msg}" -gt 0 ] && assert::log "$haystack contains $needle :: $msg" || true
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
    [ "${#msg}" -gt 0 ] && assert::log "$first > $second :: $msg" || true
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
    [ "${#msg}" -gt 0 ] && assert::log "$first >= $second :: $msg" || true
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
    [ "${#msg}" -gt 0 ] && assert::log "$first < $second :: $msg" || true
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
    [ "${#msg}" -gt 0 ] && assert::log "$first <= $second :: $msg" || true
    return 1
  fi
}
