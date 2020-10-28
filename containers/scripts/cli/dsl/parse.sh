. $(dirname ${BASH_SOURCE})/dsl.sh

declare line
declare word
declare token
declare token_name
declare identifier=
declare arg_name='.'

dsl::read_token() {
    read token_name line word identifier
    token=${!token_name}

    local expected_token=${1-$token}
    if (( ! token == expected_token )); then
        ERROR $expected_token
    fi
}

dsl::yield() {
    echo ${arg_name} $1 ${PRODUCTIONS[$1]} ${2-}
}