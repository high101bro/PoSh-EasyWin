$ExeScriptScriptOnlyCheckboxAdd_Click = {
    if ($this.Checked -eq $true) {
        $ExeScriptSelectExecutableButton.Enabled  = $false
        $ExeScriptSelectExecutableTextBox.Enabled = $false
        $ExeScriptSelectDirRadioButton.Enabled    = $false
        $ExeScriptSelectFileRadioButton.Enabled   = $false
        $ExeScriptSelectExecutableTextBox.text    = 'Disabled - No files being copied over'
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.text = "User Specified Custom Script (WinRM)"
    }
    else {
        $ExeScriptSelectExecutableButton.Enabled  = $true
        $ExeScriptSelectExecutableTextBox.Enabled = $true
        $ExeScriptSelectDirRadioButton.Enabled    = $true
        $ExeScriptSelectFileRadioButton.Enabled   = $true
        if     ($ExeScriptSelectDirRadioButton.checked)  { $ExeScriptSelectExecutableTextBox.text = 'Directory:'}
        elseif ($ExeScriptSelectFileRadioButton.checked) { $ExeScriptSelectExecutableTextBox.text = 'File:'}
        $script:ExeScriptSelectDirOrFilePath      = $null
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.text = "User Specified Files and Custom Script (WinRM)"
    }
}



