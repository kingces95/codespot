. $(dirname ${BASH_SOURCE})/../util.sh
. $(util::this_dir)/../assert/index.sh

readonly CLI_ARG_CHAR_GLOB="[a-zA-Z0-9_-]"
readonly CLI_ARG_PATH_GLOB="@(.|./*|/*)"
readonly CLI_ARG_DIR_ENTRY_GLOB="+(${CLI_ARG_CHAR_GLOB})"
readonly CLI_ARG_ALIAS_GLOB="-@(${CLI_ARG_CHAR_GLOB})" 
readonly CLI_ARG_NAME_GLOB="--@(${CLI_ARG_CHAR_GLOB})+(${CLI_ARG_CHAR_GLOB})"

readonly TOKENS=(
    'TOKEN_DEFAULT'
    'TOKEN_ALLOWED_VALUES'
    'TOKEN_VALUE_COMMA'
    'TOKEN_VALUE_PERIOD'
    'TOKEN_IDENTIFIER'
    'TOKEN_NAME'
    'TOKEN_ALIAS'
    'TOKEN_COLON'
    'TOKEN_REQUIRED'
    'TOKEN_PATH'
    'TOKEN_EOF' 
    'TOKEN_ERROR' 
) && util::declare_enums TOKENS

readonly PRODUCTIONS=(
    'PRODUCTION_ARG_PATH'
    'PRODUCTION_ARG_FILE'
    'PRODUCTION_ARG_DIR'
    'PRODUCTION_HELP_NAME'
    'PRODUCTION_HELP_ALIAS'
    'PRODUCTION_HELP_DEFAULT'
    'PRODUCTION_ARG_NAME'
    'PRODUCTION_ARG_ALIAS'
    'PRODUCTION_ARG_VALUE'
    'PRODUCTION_HELP_REQUIRED'
    'PRODUCTION_HELP_ALLOWED'
    'PRODUCTION_HELP_ALLOWED_VALUE'
    'PRODUCTION_HELP_ALLOWED_END'
    'PRODUCTION_ERROR'
) && util::declare_enums PRODUCTIONS

readonly INSTRUCTIONS=(
    'INSTRUCTION_ASSIGN'
    'INSTRUCTION_TEST'
    'INSTRUCTION_SKIP'
    'INSTRUCTION_ASSERT'
    'INSTRUCTION_PUSH'
    'INSTRUCTION_CALL'
    'INSTRUCTION_ECHO'
    'INSTRUCTION_EXIT'
) && util::declare_enums INSTRUCTIONS

# logging
cli::log() { >&2 echo $@; }
cli::log_callstack() {
    local skip_frames=${1-0}

    cli::log CALLSTACK: 
    util::callstack \
        | cli::skip ${skip_frames} \
        | cli::indent 1>&2
}

# exiting
cli::die() { 
    cli::log "ERROR:" $@
    cli::log_callstack
    exit 1
}

cli::if_tty_then_redirect_to_file() {
    local file_descriptor="${1?}"
    local file="${2?}"

    if [[ -t ${file_descriptor} ]]; then
        # clear
        : > "${file}"

        # redirect
        eval "exec ${file_descriptor}>> ${file}"
    fi
}

cli::on_exit() {
    local exit_code=$?

    if (( exit_code == 0 )); then
        return
    fi

    log_callstack 1

    echo ERROR: Exited with non-zero code: "${exit_code}"
    echo "$ cat ${LOG_FILE} | tail -n ${LOG_TAIL}"
    cat "${LOG_FILE}" \
        | tail -n "${LOG_TAIL}" \
        | cli::indent

    if $help_on_exit; then
        echo "$(help)"
        exit
    fi

    return $exit_code
}

parser::yield() {
    echo ${arg_name} $1 ${PRODUCTIONS[$1]} ${2-}
}

parser::error() {
    parser::yield ${PRODUCTION_ERROR} "$1"
    exit
}

parser::bad_token() {
    local message
    local -a expected
    
    for i in "$@"; do
        expected+=( ${TOKENS[$i]} )
    done
    
    message="Unexpected argument '${identifier}'. Expected \
        token in { ${expected[@]} }, but got ${token_name}."

    parser::error "${message}"
}

parser::assert_token_is() {
    for expected_token in "$@"; do
        if (( token == expected_token )); then
            return

        elif (( token == TOKEN_ERROR )); then
            parser::error "${identifier}"
        fi
    done

    parser::bad_token $@
}

parser::read_token() {
    read token_name line word identifier
    token=${!token_name}

    if (( $# > 0 )); then
        parser::assert_token_is "$@"
    fi
}