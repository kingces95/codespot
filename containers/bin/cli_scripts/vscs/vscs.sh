. $(dirname ${BASH_SOURCE})/../util.sh

DocVscs="All Visual Studio Code Server commands."
DocServer="Visual Studio Code Server commands."
DocServerStart=""

VSCS_HOST=https://update.code.visualstudio.com
VSCS_DIR_STABLE=~/.vscode-server
VSCS_DIR_INSIDER=${VSCS_DIR_STABLE}-insiders
VSCS_TARGZC_TEMP=/tmp/vscode.tar.gzc

vscs::declare_server_dirs() {
    : ${arg_build:?}

    if [[ "${arg_build}" == 'stable' ]]; then
        server_dir=${VSCS_DIR_STABLE}
    else
        server_dir=${VSCS_DIR_INSIDER}
    fi
}

vscs::declare_dirs() {
    : ${arg_commit:?}
    : ${arg_build:?}

    vscs::declare_server_dirs
    : ${server_dir:?}

    commit_dir=${server_dir}/bin/${arg_commit}
}