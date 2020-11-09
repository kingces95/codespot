# supress background processes from displaying their exit status upon completion.
# see https://mywiki.wooledge.org/BashFAQ/024
set +m

# run the last segment of a pipeline in the current execution process, not a subshell.
# see https://mywiki.wooledge.org/BashFAQ/024
shopt -s lastpipe

set -e
set -u 
# set -o pipefail

shopt -s globstar
shopt -s extglob

# loader reflection
util::this_dir() { echo $(dirname ${BASH_SOURCE[1]}); }
util::this_file() { echo "${BASH_SOURCE[1]}"; }
util::caller_file() { echo "${BASH_SOURCE[2]}"; }
util::caller_dir() { echo $(dirname ${BASH_SOURCE[2]}); }
util::callstack() (
    i=0
    while caller $i; do 
        i=$(( i + 1 ))
    done 2>&1
)

# reflection
util::is_set() {
    declare -p $1 >/dev/null 2>&1
}
util::is_true() {
    if util::is_set $1 && [[ ${!1} == 'true' ]]; then
        return 0
    else
        return 1
    fi
}

# profiling
util::pad() { printf "%02d" "$1"; }
util::time_up() {
    local duration=SECONDS
    local seconds=$((duration % 60))
    local minutes=$((duration / 60))
    local hours=$((duration / (60 * 60)))
    echo "T+$(util::pad ${hours}):$(util::pad ${minutes}):$(util::pad ${seconds})"
}

# declarations
util::declare_enums() {
    declare -n enum=$1

    for i in "${!enum[@]}"; do
        declare -g "${enum[$i]}"="$i"
    done
}

# streaming
cli::indent() ( sed 's/^/    /'; )
cli::unindent() ( sed 's/^    //'; )
cli::skip() ( tail -n $(( $1 + 1 )); )

# invocation
util::yield_args() (
    while (( $# > 0 )); do
        echo "$1"
        shift
    done
)

# default implementations
help() { 
    echo "Unexpected failure to provide implementation of 'help'."
}
test() { 
    echo "Unexpected failure to provide implementation of 'test'."
}

# shim
util::arg_to_variable_name() {
    name=$1
    name="${name#--}"
    name="${name^^}"
    name="ARG_${name/-/_}"
    echo "${name}"
}
util::escape_args_then_call_as() {
    local user=$1
    shift

    local -a args
    for i in "$@"; do
        args+=( $(printf %q "${i}") )
    done

    sudo su "${user}" -c "${args[*]}"
}
util::main() {

    # declare well known variables
    : ${ARG_HELP:=false}
    : ${ARG_SELF_TEST:=false}
    : ${ARG_RUN_AS:=}

    # resolve well known aliases
    if [[ "${1-}" == '-h' ]]; then
        set -- '--help'
    fi

    # declare variables passed via the command line    
    local name
    local value
    local args=( "$@" )
    until (( $# == 0 )); do
        name="$1"; shift

        # support flags; e.g. This '--help true' is the same '--help' 
        if (( $# == 0 )) || [[ "$1" == --* ]]; then
            value="true"
        else
            value="$1"; shift
        fi

        # map argument names to bash names; e.g. '--foo' ==> 'ARG_FOO'
        name=$(util::arg_to_variable_name ${name})
        
        # declare non-exported, but global, bash variables
        declare -g "${name}"="${value}"
    done

    # implement well known features
    if [[ -n "${ARG_RUN_AS}" ]] && [[ ! "${ARG_RUN_AS}" == "$(whoami)" ]]; then
        util::escape_args_then_call_as "${ARG_RUN_AS}" "$0" "${args[@]}"
    elif ${ARG_HELP}; then 
        help
    elif ${ARG_SELF_TEST}; then 
        test
    else
        # *really* clean up
        unset name
        unset value
        unset args
        unset ARG_RUN_AS
        unset ARG_HELP
        unset ARG_SELF_TEST
        main
    fi
}