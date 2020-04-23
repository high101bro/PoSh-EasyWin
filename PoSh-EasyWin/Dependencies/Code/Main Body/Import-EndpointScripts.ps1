Function Import-EndpointScripts {
    Foreach ($script in (Get-ChildItem -Path "$QueryCommandsAndScripts\Scripts - Endpoint")) {
        if ($script -match 'processes' -or $script -match 'services') {
            $CollectionName = $script.basename
            $script:AllEndpointCommands += [PSCustomObject]@{ 
                Name                 = $CollectionName
                Type                 = "script, chart"
                Command_WinRM_Script = "Invoke-Command -FilePath '$($script.FullName)'"
                Properties_PoSh      = 'PSComputerName, *'
                Description          = "$(Get-Help $($script.FullName) | Select-Object -ExpandProperty Description)".TrimStart('@{Text=').TrimEnd('}')
                ScriptPath           = "$($script.FullName)"
                ExportFileName       = "$(($script.basename).trim())"
            }
        }
        else {
            $CollectionName = $script.basename
            $script:AllEndpointCommands += [PSCustomObject]@{ 
                Name                 = $CollectionName
                Type                 = "script"
                Command_WinRM_Script = "Invoke-Command -FilePath '$($script.FullName)'"
                Properties_PoSh      = 'PSComputerName, *'
                Description          = "$(Get-Help $($script.FullName) | Select-Object -ExpandProperty Description)".TrimStart('@{Text=').TrimEnd('}')
                ScriptPath           = "$($script.FullName)"
                ExportFileName       = "$(($script.basename).trim())"
            }
        }
    }
}