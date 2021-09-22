Function Import-EndpointScripts {
    Foreach ($script in (Get-ChildItem -Path "$QueryCommandsAndScripts\Scripts-Host" | Where-Object {$_.Extension -eq '.ps1'})) {
        $CollectionName = $script.basename
        
        if ($CollectionName -match 'DeepBlue') {
            $script:AllEndpointCommands += [PSCustomObject]@{
                Name                 = $CollectionName
                Type                 = "script"
                Command_WinRM_Script = $script.FullName
                Arguments            = @('$Dependencies\Commands & Scripts\Scripts-Host\Invoke-DeepBlue-regexes.txt','$Dependencies\Commands & Scripts\Scripts-Host\Invoke-DeepBlue-whitelist.txt')
                #Properties_PoSh      = 'PSComputerName, *'
                Description          = @"
$("$(Get-Help $($script.FullName) | Select-Object -ExpandProperty DESCRIPTION)".TrimStart('@{Text=').TrimEnd('}'))

Regex File:
$("$Dependencies\Commands & Scripts\Scripts-Host\Invoke-DeepBlue-regexes.txt")

Whitelist File:
$("$Dependencies\Commands & Scripts\Scripts-Host\Invoke-DeepBlue-whitelist.txt")
"@            
                ScriptPath           = "$($script.FullName)"
                ExportFileName       = "$(($script.basename).trim())"
            }    
        }
        else {
            $script:AllEndpointCommands += [PSCustomObject]@{
                Name                 = $CollectionName
                Type                 = "script"
                Command_WinRM_Script = $script.FullName
                Arguments            = $null
                #Properties_PoSh      = 'PSComputerName, *'
                Description          = @"
$("$(Get-Help $($script.FullName) | Select-Object -ExpandProperty SYNOPSIS)".TrimStart('@{Text=').TrimEnd('}'))

$("$(Get-Help $($script.FullName) | Select-Object -ExpandProperty DESCRIPTION)".TrimStart('@{Text=').TrimEnd('}'))
"@            
                ScriptPath           = "$($script.FullName)"
                ExportFileName       = "$(($script.basename).trim())"
            }
        }
    }
}

