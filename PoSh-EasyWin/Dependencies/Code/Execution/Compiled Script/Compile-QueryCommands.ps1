function Compile-QueryCommands {
    param(
        [switch]$raw
    )
    $script:QueryCommands = @{}
    Foreach ($Command in $script:CommandsCheckedBoxesSelected) {
        # Checks for the type of command selected and assembles the command to be executed
        $OutputFileFileType = ""
        if (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Get-WmiObject")) { $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }} }
        elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Invoke-WmiMethod")) {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }
        elseif ($Command.Type -eq "(WinRM) Script") {
            $CommandScript = $command.command
            if ($raw) {
                $script:QueryCommands += @{ 
                    $Command.Name = @{ Name = $Command.Name
                    Command = @"

$(Invoke-Expression ("$CommandScript").Replace("Invoke-Command -FilePath '","Get-Content -Raw -Path '"))

"@
                    Properties = $Command.Properties }
                }
            }
            else {
                $File = ("$CommandScript").Replace("Invoke-Command -FilePath '","").TrimEnd("'")
                $CommandContents = ""
                Foreach ($line in (Get-Content $File)) {$CommandContents += "$line`r`n"}                            
                $script:QueryCommands += @{ 
                    $Command.Name = @{ Name = $Command.Name
                    Command = @"

$CommandContents

"@
                    Properties = $Command.Properties }
                }
            }
        }
        elseif ($Command.Type -eq "(WinRM) PoSh") {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }
        elseif ($Command.Type -eq "(WinRM) WMI") {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }


        elseif ($Command.Type -eq "(SMB) PoSh") {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }
        elseif ($Command.Type -eq "(SMB) WMI") {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }
        elseif ($Command.Type -eq "(SMB) CMD") {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }

        
        #elseif ($Command.Type -eq "(WinRM) WMIC") {
        #    $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        #}
        #elseif ($Command.Type -eq "(RPC) CMD") {
        #    $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        #}
        elseif ($Command.Type -eq "(RPC) PoSh") {
            $script:QueryCommands += @{ $Command.Name = @{ Name = $Command.Name ; Command = $Command.Command ; Properties = $Command.Properties }}
        }
        $CommandName = $Command.Name
        $CommandType = $Command.Type
    }
}
