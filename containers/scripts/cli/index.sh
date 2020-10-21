readonly HERE_DOC="eval sed 's/^\ \ \ \ //g'"

readonly CLI_CMD_NAME="${0##*/}"
readonly CLI_CMD_FILE="${BASH_SOURCE[1]}"
readonly CLI_CMD_DIR=$(dirname ${CLI_CMD_FILE})
readonly CLI_HELP_EXIT_CODE=1
readonly CLI_LOG_TAIL=5
readonly CLI_LOG_FILE='log.txt'

# reflection
cli::this_dir() { echo $(dirname ${BASH_SOURCE[1]}); }
cli::this_file() { echo "${BASH_SOURCE[1]}"; }
cli::caller_file() { echo "${BASH_SOURCE[2]}"; }
cli::caller_dir() { echo $(dirname ${BASH_SOURCE[2]}); }

# string formatting
cli::pad() { printf "%02d" "$1"; }

# set opts
cli::set_fail_if_command_fails() { set -e; }
cli::set_fail_on_unset_expansion() { set -u; }
cli::set_debugging() { set -x; }
cli::clear_debugging() { set +x; }

# eval
cli::echo_and_eval() { echo \$ $1; eval "$1"; }

# exiting
cli::die() { cli::log "Fatal:" $@; exit 1; }
cli::exit() { echo "$@"; exit; }

# profiling
cli::up_time() {
    local duration=SECONDS
    local seconds=$((duration % 60))
    local minutes=$((duration / 60))
    local hours=$((duration / (60 * 60)))
    echo "T+$(cli::pad ${hours}):$(cli::pad ${minutes}):$(cli::pad ${seconds})"
}

# logging
cli::log() { >&2 echo $@; }

cli::if_stderr_is_tty_then_log_stderr_to_file() {
    local file="${1?}"

    if [[ -t 2 ]]; then
        # clear log
        : > "${file}"

        # make echos to stderr append the log
        exec 2>> "${file}"
    fi
}

cli::dump_log_tail() {
    local log="${1?}"
    local lines="${2?}"

    echo "$ cat ${log} | tail -n ${lines}"

    cat "${log}" \
        | tail -n "${lines}" \
        | sed 's/^/    /'
}

# arguments
cli::declare_args() {
    declare -ga ARG_POSITIONAL=()

    while (( $# > 0 )); do
        if [[ "$1" == "--"* ]]; then
            break
        fi
        
        ARG_POSITIONAL+=( "${1/-/_}" )
        shift
    done

    local name
    local value

    while (( $# > 0 )); do

        if [[ $1 == "--"* ]]; then
            name="${1/--/}"
            name="${name^^}"
            name="${name/-/_}"
            shift

            if (( $# == 0 )) || [[ $1 == "--"* ]]; then
                value=true
            else
                value="$1"
                shift 
            fi

            declare -g "ARG_${name}"="${value}"

            # echo ${name}=${!name}
        else
            cli::die "Expected named argument, but got \'$1\'"
        fi
    done
}


cli::probe_for_script() {
    local parts=( "$@" )

    local path='.'
    for i in "${parts[@]}"; do
        next_path="${path}/${i}"

        if [[ -d "${next_path}" ]]; then
            path="${next_path}"

        elif [[ -f "${next_path}.sh" ]]; then
            path="${next_path}.sh"

        else
            break
        fi
    done

    echo "${path}"
}

cli::is_function() {
    local name=${1?}

    if [[ "$(type -t "${name}")" == 'function' ]]; then
        return 0
    else
        return 1
    fi
}

cli::assert_is_function() {
    local name=${1?}

    if ! cli::is_function ${name}; then
        cli::die "function '${name}' not defined."
    fi
}

cli::main() {
    # shell opt
    cli::set_fail_if_command_fails
    cli::set_fail_on_unset_expansion

    # Print commands and their arguments as they are executed.
    # set -x

    shopt -s extglob
    shopt -s globstar

    # if stderr is tty, point it at a log file instead. This way, 
    # stdout can be used exclusively to report status, as opposed
    # to logging spew.
    cli::if_stderr_is_tty_then_log_stderr_to_file "${CLI_LOG_FILE}"

    # if exit with non-zero, then dump the last few lines of log
    # messages as stdout has been reserved for operational status.
    local __dump_help=false
    cli::on_exit() {
        local exit_code=$?

        if (( exit_code != 0 )); then
            echo ERROR: Exited with non-zero code: "${exit_code}"
            cli::dump_log_tail "${CLI_LOG_FILE}" "${CLI_LOG_TAIL}"

            if $__dump_help; then
                echo
                help
            fi
        fi

        return $exit_code
    }   
    trap cli::on_exit EXIT

    # log this command and its arguments
    cli::log $ "${CLI_CMD_NAME}" $@

    # if no arguments, then push '--help'
    if (( $# == 0 )); then
        set -- '--help'
    fi

    # shift positional args into array. 
    # e.g. '$ cmd moo boo --foo bar' -> ARG_POSITIONAL=( 'moo' 'boo' )
    # then shift named args into variables. 
    # e.g. '$ cmd --foo bar' -> ARG_FOO='bar'
    declare -g ARG_HELP=false
    declare -g ARG_DEBUG=false
    declare -g ARG_RUN_AS="$(whoami)"
    cli::declare_args "$@"

    # implement '--run-as'
    if [[ "${ARG_RUN_AS}" != "$(whoami)" ]]; then
        sudo su "${ARG_RUN_AS}" < <(printf "\"%s\" " "${CLI_CMD_FILE}" "$@"; echo)
        exit
    fi

    # construct the expected script path given the positional arguments
    # e.g. '$ cmd moo boo' -> 'moo/boo.sh'
    local __path="./${CLI_CMD_DIR}$( printf "/%s" "${ARG_POSITIONAL[@]}" ).sh"

    if [[ ! -f "${__path}" ]]; then
        local help_path="$(cli::probe_for_script "${CLI_CMD_DIR}" "${ARG_POSITIONAL[@]}")"
        echo Help ::${help_path} :: ...
        cli::die
    fi

    # source the script to define 'description', 'help', 'validate', and 'main' 
    . "${__path}"
    cli::assert_is_function 'main'
    cli::assert_is_function 'help'
    cli::assert_is_function 'description'

    # implement '--help'
    if ${ARG_HELP}; then
        cli::exit "$(help)"
    fi

    # enable/disable debugging before command code invoked
    cli::prolog() { if $ARG_DEBUG; then cli::set_debugging; fi; }
    cli::epilog() { if $ARG_DEBUG; then cli::clear_debugging; fi; }

    # if validate defined, then validate, and dump help on failures
    if cli::is_function 'validate'; then
        __dump_help=true
        cli::prolog; validate; cli::epilog
        __dump_help=false
    fi

    cli::prolog; main; cli::epilog
}