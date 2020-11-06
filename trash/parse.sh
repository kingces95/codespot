. $(dirname ${BASH_SOURCE})/../cli.sh

declare line
declare word
declare token
declare token_name
declare identifier
declare arg_name='.'

dsl::read_token() {

    read token_name line word identifier
    token=${!token_name}

    local expected_token=${1-$token}

    if (( token == TOKEN_ERROR )); then
        ERROR "${identifier}"

    elif (( ! token == expected_token )); then
        TOKEN_ERROR $expected_token
    fi
}

dsl::yield() {
    echo ${arg_name} $1 ${PRODUCTIONS[$1]} ${2-}
}

ERROR() {
    dsl::yield ${PRODUCTION_ERROR} "$1"
    exit
}

PARSE_ERROR() {
    ERROR "PARSE ERROR: line ${line}, word ${word}, identifier '${identifier}': $1"
}

TOKEN_ERROR() {
    PARSE_ERROR "Unexpected token \"${token_name}\", expected \"$1\"."
}