$RegistryValueNameCheckboxAdd_Click = {
    $RegistrySearchCheckbox.checked  = $true
    $RegistryKeyNameCheckbox.checked   = $false
    $RegistryValueNameCheckbox.checked = $true
    $RegistryValueDataCheckbox.checked = $false

    $script:RegistrySelected = 'RegistryValueNameCheckbox'
    Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
}