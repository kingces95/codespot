set -euf -o pipefail

readonly ARG_NAME_GLOB="--"* 
readonly ARG_ALIAS_GLOB="-"? 

function dsl::declare_enums() {
    declare -n enum=$1

    for i in "${!enum[@]}"; do
        declare -g "${enum[$i]}"="$i"
    done
}

readonly TOKENS=(
    'TOKEN_DEFAULT'
    'TOKEN_ALLOWED'
    'TOKEN_VALUES'
    'TOKEN_WORD'
    'TOKEN_ARG_VALUE'
    'TOKEN_ARG_NAME'
    'TOKEN_ARG_ALIAS'
    'TOKEN_COLON'
    'TOKEN_REQUIRED'
    'TOKEN_EOF' 
) && dsl::declare_enums TOKENS

readonly PRODUCTIONS=(
    'PRODUCTION_ARG_NAME'
    'PRODUCTION_ARG_ALIAS'
    'PRODUCTION_DEFAULT'
    'PRODUCTION_ARG_VALUE'
    'PRODUCTION_REQUIRED'
    'PRODUCTION_ALLOWED_VALUE'
    'PRODUCTION_ARG_POSITIONAL'
    'PRODUCTION_CMD_SOURCE'
    'PRODUCTION_CMD_DIR'
    'PRODUCTION_CMD_MISSING'
) && dsl::declare_enums PRODUCTIONS

dsl::log() {
    echo "$@" >&2
}

dsl::die() { 
    dsl::log "ERROR:" $@
    exit 1
}