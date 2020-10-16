# command prompt
export PS1='$(pwd)/ $ '

# network
alias ports="lsof -i -P -n | grep LISTEN"

# shell
alias e="env | sort"

# navigation
pd() { pushd $1 > /dev/null; }
pod() { popd > /dev/null; }
alias pd="pd"
alias p="pod"
alias pp="pod && p"
alias ppp="pod && pp"
alias pppp="pod && ppp"
alias u="cd .."
alias uu="u && cd .."
alias uuu="uu && cd .."
alias uuuu="uuu && cd .."

# reflection
alias pa="alias -p"
alias re="pd $BASEDIR && . $BASEDIR/.profile && pod"

# git
alias clean="git clean . -fxd"

# known directories
alias h="pd ~"

# repo directories
export REPO_DIR=$(pwd)
alias r="pd $REPO_DIR" 