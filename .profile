repoDir=$(pwd)/$(dirname $BASH_SOURCE)

# git bash complete
. $repoDir/.git-completion.bash

# git prompt
. $repoDir/.git-prompt.sh

# customize prompt
# see https://gist.github.com/tdd/594d37179ee9b36e1ba3
# GIT_PS1_SHOWDIRTYSTATE=1
# GIT_PS1_SHOWCOLORHINTS=1
# GIT_PS1_DESCRIBE_STYLE=branch
# GIT_PS1_HIDE_IF_PWD_IGNORED=1
# GIT_PS1_SHOWUNTRACKEDFILES=1
# GIT_PS1_SHOWSTASHSTATE=1
# GIT_PS1_SHOWUPSTREAM=verbose
# PS1='$(pwd) \[\e[0m\e[0;32m\]\W\[\e[1;33m\]$(__git_ps1 " (%s)")\[\e[0;37m\] \$\[\e[0m\] '

# useful git config (e.g. submodule support)
git config --local include.path ../.gitconfig

# basic command prompt
export PS1='$(pwd)/ $ '

# git subtree add \
#     --prefix .vim/bundle/tpope-vim-surround \
#     https://bitbucket.org/vim-plugins-mirror/vim-surround.git master \
#     --squash
# git fetch https://bitbucket.org/vim-plugins-mirror/vim-surround.git master 
# warning: no common commits remote: Counting objects: 338, done. remote: 
# Compressing objects: 100% (145/145), done. remote: Total 338 (delta 101), 
# reused 323 (delta 89) Receiving objects: 100% (338/338), 71.46 KiB, done. 
# Resolving deltas: 100% (101/101), done. 
# From https://bitbucket.org/vim-plugins-mirror/vim-surround.git * branch master -} 
# FETCH_HEAD Added dir '.vim/bundle/tpope-vim-surround'

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

alias azx=$repoDir/containers/scripts/azx/index.sh $*
alias vscs=$repoDir/containers/scripts/vscs/index.sh $*