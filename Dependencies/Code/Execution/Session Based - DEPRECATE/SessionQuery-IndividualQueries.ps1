<#
    .Description
    This iterates though the commands selected and determines how to exactly execute them
    based off their labeled protocol and command type.
#>
Foreach ($Command in $script:CommandsCheckedBoxesSelected) {
    $script:ProgressBarEndpointsProgressBar.Value = 0
    $ProgressBarEndpointsCommandLine = 0

    $ExecutionStartTime = Get-Date
    $CollectionName = $Command.Name
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Executing: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
    $PoShEasyWin.Refresh()

    if ($Command.Type -eq "(WinRM) Script") {
        $CommandString = "$($Command.Command)"
        $script:OutputFileFileType = "csv"
    }
    elseif ($Command.Type -eq "(WinRM) PoSh") {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $script:OutputFileFileType = "csv"
    }
    elseif ($Command.Type -eq "(WinRM) WMI") {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $script:OutputFileFileType = "csv"
    }
    #elseif ($Command.Type -eq "(WinRM) CMD") {
    #    $CommandString = "$($Command.Command)"
    #    $script:OutputFileFileType = "txt"
    #}


    #elseif ($Command.Type -eq "(RPC) PoSh") {
    #    $CommandString = "$($Command.Command) | Select-Object -Property @{n='PSComputerName';e={`$TargetComputer}}, $($Command.Properties)"
    #    $script:OutputFileFileType = "csv"
    #}
    elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Get-WmiObject")) {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $script:OutputFileFileType = "csv"
    }
    #elseif ($Command.Type -eq "(RPC) CMD") {
    #    $CommandString = "$($Command.Command)"
    #    $script:OutputFileFileType = "txt"
    #}




    elseif ($Command.Type -eq "(SMB) PoSh") {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $script:OutputFileFileType = "txt"
    }
    elseif ($Command.Type -eq "(SMB) WMI") {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $script:OutputFileFileType = "txt"
    }
    elseif ($Command.Type -eq "(SMB) CMD") {
        $CommandString = "$($Command.Command)"
        $script:OutputFileFileType = "txt"
    }


    $CommandName = $Command.Name
    $CommandType = $Command.Type


    # Checks for the file output type, removes previous results with a file, then executes the commands
    if ( $Command.Type -eq "(WinRM) Script" ) {
        $OutputFilePath = "$script:CollectedDataTimeStampDirectory\$((($CommandName) -split ' -- ')[1]) - $CommandType"
        Remove-Item -Path "$OutputFilePath.csv" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$OutputFilePath.xml" -Force -ErrorAction SilentlyContinue

        #The following string replacements edits the command to be compatible with session based queries witj -filepath
        $CommandString = $CommandString.replace('Invoke-Command -FilePath ','').replace("'","").replace('"','')
        Invoke-Command -FilePath $CommandString -Session $PSSession | Select-Object -Property PSComputerName, * -ExcludeProperty "__*",RunspaceID `
        | Set-Variable SessionData
        $SessionData | Export-Csv -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml"
        Remove-Variable -Name SessionData
    }
    elseif ( $script:OutputFileFileType -eq "csv" ) {
        $OutputFilePath = "$script:CollectedDataTimeStampDirectory\$((($CommandName) -split ' -- ')[1]) - $CommandType"
        Remove-Item -Path "$OutputFilePath.csv" -Force -ErrorAction SilentlyContinue
        Invoke-Command -ScriptBlock { param($CommandString); Invoke-Expression -Command $CommandString } -argumentlist $CommandString -Session $PSSession `
        | Set-Variable SessionData
        $SessionData | Export-Csv -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force
    }
    elseif ( $script:OutputFileFileType -eq "txt" ) {
        $OutputFilePath = "$script:CollectedDataTimeStampDirectory\$((($CommandName) -split ' -- ')[1]) - $CommandType - $($TargetComputer)"
        Remove-Item -Path "$OutputFilePath.txt" -Force -ErrorAction SilentlyContinue
        Invoke-Command -ScriptBlock { param($CommandString); Invoke-Expression -Command $CommandString } -argumentlist $CommandString -Session $PSSession `
        | Set-Variable SessionData
        $SessionData | Out-File -Path "$OutputFilePath.txt" -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force
    }


    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
    $PoShEasyWin.Refresh()


    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Invoke-Command -ScriptBlock { param($CommandString); Invoke-Expression -Command $CommandString } -argumentlist $CommandString -Session `$PSSession"


    $script:ProgressBarQueriesProgressBar.Value   += 1
    $script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
    $PoShEasyWin.Refresh()
    Start-Sleep -match 500
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGviD5C4E3KuFkhsln7CQwphS
# ZFygggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUN4XG9Z3sVvmoPWTyXRnpk2BwYEowDQYJKoZI
# hvcNAQEBBQAEggEAPGHVhvXOqCDH4G3Itay5V2PmlV9Q+vKSS1lnr5hCIhNpwA/k
# FAwEWzydKkCXIu5f3J6DKIhcuU5KZA4/PFjquCBDQzzJ5XXZv03aJUVNplJ19fE6
# XbJd2gYJLHw+MXih6neTk7UUHSG43bO2OOax/g1erSFBf2tsdK5/iY7zCr2MS0N+
# HwgEoAH2kgjlaFo7TuIzp5jXEWK0FckTCCXNkRXK5N+9jDEfLn6r/wsacBW5cP/7
# dKNjlkAWbdikwQ5Vd9QNZ5p/p/svOj7WiMNhBDYPUXhZBdFhMV6y7+IZJ8GgZHQS
# 63bzfuAtkgEgR4XbIDXVuLTdSSa38hnjnzKBXg==
# SIG # End signature block
