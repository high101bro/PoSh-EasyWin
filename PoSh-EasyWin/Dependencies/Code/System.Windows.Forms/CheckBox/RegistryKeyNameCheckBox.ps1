$RegistryKeyNameCheckBoxAdd_Click = {
    $RegistrySearchCheckbox.checked  = $true
    $RegistryKeyNameCheckbox.checked   = $true
    $RegistryValueNameCheckbox.checked = $false
    $RegistryValueDataCheckbox.checked = $false

    Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
}