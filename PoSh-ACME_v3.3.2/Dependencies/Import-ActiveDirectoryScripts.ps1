Function Import-ActiveDirectoryScripts {
    Foreach ($script in (Get-ChildItem -Path "$QueryCommandsAndScripts\Scripts - Active Directory")) {
        $CollectionName = $script.basename
        $script:AllActiveDirectoryCommands += [PSCustomObject]@{ 
            Name                 = $CollectionName
            Type                 = "script"
            Command_WinRM_Script = "Invoke-Command -FilePath '$($script.FullName)'"
            Properties_PoSh      = 'PSComputerName, *'
            Properties_WMI       = 'PSComputerName, *'
            Description          = "$(Get-Help $($script.FullName) | Select-Object -ExpandProperty Description)".TrimStart('@{Text=').TrimEnd('}')
            ScriptPath           = "$($script.FullName)"
        }
    }
}