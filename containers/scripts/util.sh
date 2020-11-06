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

# default implementations
help() { 
    echo "Unexpected failure to provide implementation of 'help'."
}
test() { 
    echo "Unexpected failure to provide implementation of 'test'."
}

# shim
util::main() {
    : ${ARG_HELP:=false}

    if ${ARG_HELP}; then 
        help
    else
        case "${@:-}" in
            "-h") help ;;
            "--help") help ;;
            "--self-test") test ;;
            *) main "$@" ;;
        esac
    fi
}