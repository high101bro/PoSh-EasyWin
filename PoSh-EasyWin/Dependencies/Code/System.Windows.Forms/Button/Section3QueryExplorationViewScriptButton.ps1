$Section3QueryExplorationViewScriptButtonAdd_Click = {
    Foreach($Query in $script:AllEndpointCommands) {
        if ($Section3QueryExplorationNameTextBox.Text -eq $Query.Name -and $Query.Type -eq 'script') { 
            write.exe $Query.ScriptPath
        }
    }
    Foreach($Query in $script:AllActiveDirectoryCommands) {
        if ($Section3QueryExplorationNameTextBox.Text -eq $Query.Name -and $Query.Type -eq 'script') { 
            write.exe $Query.ScriptPath
        }
    }
}