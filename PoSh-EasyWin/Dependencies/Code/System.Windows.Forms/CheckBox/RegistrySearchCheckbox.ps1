$RegistrySearchCheckboxAdd_Click = {
    if ($this.Checked -eq $true){
        $RegistrySearchCheckbox.checked = $true
        if     ($script:RegistrySelected -eq 'RegistryKeyNameCheckBox') {
            $RegistryKeyNameCheckbox.checked = $true
        }
        elseif ($script:RegistrySelected -eq 'RegistryValueNameCheckbox') {
            $RegistryValueNameCheckbox.checked = $true
        }
        elseif ($script:RegistrySelected -eq 'RegistryValueDataCheckBox') {
            $RegistryValueDataCheckbox.checked = $true
        }
        else {
            $RegistryKeyNameCheckbox.checked = $true
        }
    }
    else {
        $RegistrySearchCheckbox.checked    = $false
        $RegistryKeyNameCheckbox.checked   = $false
        $RegistryValueNameCheckbox.checked = $false
        $RegistryValueDataCheckbox.checked = $false
    }

    Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
}


