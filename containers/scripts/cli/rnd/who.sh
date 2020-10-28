description() {
    echo 'Return "whoami".'
}

help() {
${HERE_DOC} << EOF
    Command
        ${CLI_FILE_NAME} ${CLI_FULLNAME[*]} : $(description)

    Arguments
        --run-as    : Run as the specified user.

    Global Arguments
        --debug     : Debug the script.
        --help      : Show this message and exit.
EOF
}

main() {
    whoami
}