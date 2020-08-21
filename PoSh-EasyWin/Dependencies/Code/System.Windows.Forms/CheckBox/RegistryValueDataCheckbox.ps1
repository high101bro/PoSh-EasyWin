$RegistryValueDataCheckBoxAdd_Click = {
    $RegistrySearchCheckbox.checked  = $true
    $RegistryKeyNameCheckbox.checked   = $false
    $RegistryValueNameCheckbox.checked = $false
    $RegistryValueDataCheckbox.checked = $true

    $script:RegistrySelected = 'RegistryValueDataCheckBox'
    Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
}