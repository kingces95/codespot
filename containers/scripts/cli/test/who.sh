description() {
    echo 'Return "whoami".'
}

help() {
${HERE_DOC} << EOF
    Command
        ${CLI_CMD_NAME} ${ARG_POSITIONAL[*]} : $(description)
EOF
}

main() {
    whoami
}