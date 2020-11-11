. $(util::this_dir)/../assert/index.sh

AZX_TYPE_RESOURCE_GROUP=Microsoft.Resources/resourceGroups

DocApp="All application commands."
DocResource="Manage Azure resources."
DocResourceId="Format resource ids."
DocGroup="Manage Azure resource groups."

azx::log() {
    #log $ az $*
    az "$@"
}

azx::tsv() (
    azx::log "$@" --output tsv
)

azx::get_subscription_id() (
    azx::tsv account show --query id
)