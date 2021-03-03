$ExeScriptUserSpecifiedExecutableAndScriptCheckboxAdd_Click = {
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("User Specified Executable and Script")

    # Manages how the checkbox is handeled to ensure that a config is selected if sysmon is checked
    if ($ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked -and ($ExeScriptSelectExecutableTextBox.Text -eq "Directory:" -or $ExeScriptSelectExecutableTextBox.Text -eq "File:")) {
        Select-UserSpecifiedExecutable
    }
    if ($ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked -and $ExeScriptSelectScriptTextBox.Text -eq "Script:") {
        Select-UserSpecifiedScript
    }

    if ($ExeScriptSelectExecutableTextBox.Text -eq "Executable:" -and $ExeScriptSelectScriptTextBox.Text -eq "Script:"){
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false
        [System.Windows.Forms.MessageBox]::Show("You need to first select an executable and script.","Prerequisite Check",'OK','Info')

    }
    elseif ($ExeScriptSelectExecutableTextBox.Text -eq "Executable:"){
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false
        [System.Windows.Forms.MessageBox]::Show("You need to first select an executable.","Prerequisite Check",'OK','Info')
    }
    elseif ($ExeScriptSelectScriptTextBox.Text -eq "Script:"){
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked = $false
        [System.Windows.Forms.MessageBox]::Show("You need to first select an script.","Prerequisite Check",'OK','Info')
    }

    Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
}

$ExeScriptUserSpecifiedExecutableAndScriptCheckboxAdd_MouseHover = {
    Show-ToolTip -Title "User Specified Executable and Script" -Icon "Info" -Message @"
+  Select an Executable and Script to be sent and used within endpoints
+  The executable needs to be executed/started with the accompaning script
+  The script needs to execute/start with the accompaning executable
+  Results and outputs to copy back need to be manually scripted
+  Cleanup and removal of the executable, script, and any results need to be scripted
+  Validate the executable and script combo prior to use within a production network
+  The executable and script are copied to the endpoints' C:\Windows\Temp directory
"@
}


