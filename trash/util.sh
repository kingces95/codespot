# supress background processes from displaying their exit status upon completion.
# see https://mywiki.wooledge.org/BashFAQ/024
set +m

# run the last segment of a pipeline in the current execution process, not a subshell.
# see https://mywiki.wooledge.org/BashFAQ/024
shopt -s lastpipe

set -e
set -u 
# set -o pipefail

# If set, the pattern ‘**’ used in a filename expansion context will match all 
# files and zero or more directories and subdirectories. If the pattern is followed 
# by a ‘/’, only directories and subdirectories match.
shopt -s globstar

# If the extglob shell option is enabled using the shopt builtin, 
# several extended pattern matching operators are recognized. 
shopt -s extglob

# If set, Bash allows filename patterns which match 
# no files to expand to a null string, rather than themselves.
#shopt -s nullglob 

# loader reflection
util::this_dir() { echo $(dirname ${BASH_SOURCE[1]}); }
util::this_file() { echo "${BASH_SOURCE[1]}"; }
util::this_function() { echo "${FUNCNAME[1]}"; }
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
    local minutes=$((duration / 60 % 60))
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
util::indent() ( sed 's/^/    /'; )
util::unindent() ( sed 's/^    //'; )
util::skip() ( tail -n $(( $1 + 1 )); )

# invocation
util::yield_args() (
    while (( $# > 0 )); do
        echo "$1"
        shift
    done
)

# dry run support
util::source() {
    if [[ "${arg_dry_run:=}" == "true" ]]; then 
        # removes extra spaces which is typically what we want
        while read; do echo ${REPLY}; done
    else
        if [[ "${arg_debug:=}" == "true" ]]; then set -x; fi
        source /dev/stdin
        if [[ "${arg_debug:=}" == "true" ]]; then set +x; fi
    fi
}

cli::assert() {
    local variable=$1
    local blob=$2
    local message=$3

    if [[ ! "${variable}" == $blob ]]; then
        error "${message}"
    fi
}
