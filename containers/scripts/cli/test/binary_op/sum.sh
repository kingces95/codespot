description() {
    echo 'Return a sum.'
}

help() {
${HERE_DOC} << EOF
    Command
        ${CLI_CMD_NAME} ${ARG_POSITIONAL[*]} : $(description)

    Arguments
        left                : left operand
        right               : right operand
EOF
}

validate() {
    : ${ARG_LEFT?}
    : ${ARG_RIGHT?}
}

main() {
    echo $(( ${ARG_LEFT} + ${ARG_RIGHT} )) 
}