$RegistrySearchCheckboxAdd_Click = {
    if ($RegistrySearchCheckbox.Checked -ne $true){
        $RegistryKeyNameCheckbox.checked   = $false
        $RegistryValueNameCheckbox.checked = $false
        $RegistryValueDataCheckbox.checked = $false
    }
    else {
        $RegistryKeyNameCheckbox.checked           = $true    
        $RegistryValueNameCheckbox.checked         = $false
        $RegistryValueDataCheckbox.checked         = $false
        $RegistryRegistryRecursiveCheckbox.Checked = $false
    }
    Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
}
