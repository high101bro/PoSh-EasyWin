$RegistryValueDataCheckBoxAdd_Click = {
    $RegistrySearchCheckbox.checked  = $true
    $RegistryKeyNameCheckbox.checked   = $false
    $RegistryValueNameCheckbox.checked = $false
    $RegistryValueDataCheckbox.checked = $true

    Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
}