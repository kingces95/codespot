
cli::group() (
    local line
    local words
    local more=false

    if read line; then
        words=( ${line} )
        glob=${words[0]}\ *
        more=true
    fi

    while ${more}; do
        echo -n "${line}"\ ;

        more=false
        while IFS= read line; do
            if [[ "${line}" == ${glob} ]]; then
                more=true
                break
            fi

            base64 <<< ${line} | tr '\n' ' '
        done

        echo
    done
)

cli::disband() (
    local unencoded_words=${1-1}

    while read -a words line; do
        echo "${words[@]:0:$unencoded_words}"
        for word in "${words[@]:$unencoded_words}"; do
            base64 -d <<< ${word}
        done
    done
)