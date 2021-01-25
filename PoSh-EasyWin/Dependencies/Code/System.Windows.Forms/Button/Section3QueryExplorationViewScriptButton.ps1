$Section3QueryExplorationViewScriptButtonAdd_Click = {
    Foreach($Query in $script:AllEndpointCommands) {
        if ($Section3QueryExplorationNameTextBox.Text -match $Query.Name -and $Query.Type -match 'script' -and $Query.Command_WinRM_Script -match 'filepath') {
            write.exe $Query.ScriptPath
        }
    }
    Foreach($Query in $script:AllActiveDirectoryCommands) {
        if ($Section3QueryExplorationNameTextBox.Text -eq $Query.Name -and $Query.Type -match 'script') {
            write.exe $Query.ScriptPath
        }
    }
}

