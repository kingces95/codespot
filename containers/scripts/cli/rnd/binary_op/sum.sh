ARG_NAMES=( 'left' 'right' )

description() {
    echo 'Return a sum.'
}

help() {
${HERE_DOC} << EOF
    Command
        ${CLI_FILE_NAME} ${CLI_FULLNAME[*]} : $(description)

    Arguments
        --left   [Required] : left operand. Default: 0.
        --right  [Required] : like 
                              --left, but on the right. Default: 1.
EOF
}

main() {
    echo $(( ${ARG_LEFT} + ${ARG_RIGHT} )) 
}
