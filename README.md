# GitHubtainer
Fast, feisty, and delightful cloud hosted development containers.

# Getting Started
On a mac...
 
* Install [VSCode](VSCode)
   * Install the [Remote Development Pack][Remote Development] which will install
     * [Remote SSH][Remote SSH]
     * [Remote Containers][Remote Containers]
     * [Remote WSL][Remote WSL]
* Sign up with [Docker Hub](Docker Hub)
   * Install [Docker](Docker)
* Sign-up for an [Azure Account][Azure Account]
   * Install the [Azure CLI][Azure CLI]

# Attach VSCode to an Azure Container
 * Sync this repository

In VSCode...
 * File > Open > this enlistment
 * In the VSCode terminal enter
```
docker signin 
az signin
```
 * Update `.docker.sh` variables
   * `dockerHubName=[your dockerhub login]`
   * `commit=[VSCode > About > Commit]`
 * Change directory to `./container`
 * Run `.docker.sh` to build and publish the docker images
```
./.docker.sh
```
 * Run the following and note your azure subscription id
```
az account show 
``` 
 * Update `.azure.sh` variables
   * `azSubscription=[your subscription id]`
   * `azCommit=[VSCode > About > Commit]`
 * Copy/paste the variables at the top of `.azure.sh` into your terminal
   * all lines from the top of the file to the first command `az group create...`
 * Copy/past the commands in `.azure.sh` one by one into the terminal to walk through activating and attaching the command line to a container
 * Make a note of the IP address of the container (`azIp`)
 * After you successfully ssh into the container, hit `ctrl-d` to exit the SSH shell
* In VSCode...
  * click on the computer icon in the extensions bar on the left to open the Remote Extension pane
   * select `SSH Targets` from the `REMOTE EXPLORER` dropdown above the extension pane 
   * click the gear that appears after hovering over `SSH TARGETS`
   * select `/Users/<user>/.ssh/config`
   * add the following the the config substituting `ip` with the IP of the container, and save
```
VSCS_HOST myRemote
  HostName <ip>
  User vscode
  UserKnownHostsFile ~/.ssh/known_host/<ip>
```
  * click on `myRemote` in the extensions pane to attach VSCode to the container!

[VSCode]: https://code.visualstudio.com/insiders/
[Remote Development]: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack
[Remote SSH]: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh
[Remote Containers]: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers
[Remote WSL]: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl

[Docker]: https://docs.docker.com/get-docker/
[Docker Hub]: https://hub.docker.com/signup
[Azure CLI]: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos
[Azure Account]: https://azure.microsoft.com/en-us/account/
