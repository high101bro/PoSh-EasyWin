# The end of the collection script
Function Completed-QueryExecution {

    # Updates the value of the most recent queried computers
    # Used to ask if you want to conduct rpc,smb,winrm checks again if the currnet computerlist doens't match the history
    $script:ComputerListHistory = $script:ComputerList
    if ($script:RpcCommandCount   -gt 0) { Set-variable RpcCommandCountHistory   -Scope script -Value $true -Force } else { Set-variable RpcCommandCountHistory   -Scope script -Value $false -Force }
    if ($script:SmbCommandCount   -gt 0) { Set-variable SmbCommandCountHistory   -Scope script -Value $true -Force } else { Set-variable SmbCommandCountHistory   -Scope script -Value $false -Force }
    if ($script:WinRmCommandCount -gt 0) { Set-variable WinRmCommandCountHistory -Scope script -Value $true -Force } else { Set-variable WinRmCommandCountHistory -Scope script -Value $false -Force }

    $CollectionTimerStop = Get-Date
    $ResultsListBox.Items.Insert(0,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss'))  Finished Executing Commands")

    if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
        Start-Sleep -Seconds 3
        Generate-NewRollingPassword
        $ResultsListBox.Items.Insert(1,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss'))  Rolled Password For Account: $($script:PoShEasyWinAccount)")
        $TotalElapsedTimeOrder = @(2,3,4)
    }
    else {$TotalElapsedTimeOrder = @(1,2,3)}


    # Check for and remove empty direcotires
    #$EmtpyDir = "$($script:CollectionSavedDirectoryTextBox.Text)\"
    #do {
    #    $Dirs = Get-ChildItem $EmtpyDir -Directory -Recurse `
    #    | Where-Object { (Get-ChildItem $_.FullName).count -eq 0 } `
    #    | Select-Object -ExpandProperty FullName
    #    $Dirs | Foreach-Object { Remove-Item $_ }
    #} while ($Dirs.count -gt 0)


    $StatusListBox.Items.Clear()
    if     ($QueryCount -eq 1 -and $script:ComputerList.Count -eq 1) { $StatusListBox.Items.Add("Completed Executing $($QueryCount) Command to $($script:ComputerList.Count) Endpoint") }
    elseif ($QueryCount -gt 1 -and $script:ComputerList.Count -eq 1) { $StatusListBox.Items.Add("Completed Executing $($QueryCount) Commands to $($script:ComputerList.Count) Endpoint") }
    elseif ($QueryCount -eq 1 -and $script:ComputerList.Count -gt 1) { $StatusListBox.Items.Add("Completed Executing $($QueryCount) Command to $($script:ComputerList.Count) Endpoints") }
    elseif ($QueryCount -eq 1 -and $script:ComputerList.Count -gt 1) { $StatusListBox.Items.Add("Completed Executing $($QueryCount) Commands to $($script:ComputerList.Count) Endpoints") }


    $CollectionTime = New-TimeSpan -Start $CollectionTimerStart -End $CollectionTimerStop
    $ResultsListBox.Items.Insert($TotalElapsedTimeOrder[0],"   $CollectionTime  Total Elapsed Time")
    $ResultsListBox.Items.Insert($TotalElapsedTimeOrder[1],"====================================================================================================")
    $ResultsListBox.Items.Insert($TotalElapsedTimeOrder[2],"")


    # Ensures that the Progress Bars are full at the end of collection
    $script:ProgressBarEndpointsProgressBar.Maximum = 1
    $script:ProgressBarEndpointsProgressBar.Value   = 1
    $script:ProgressBarQueriesProgressBar.Maximum   = 1
    $script:ProgressBarQueriesProgressBar.Value     = 1

    # Plays a Sound When finished
    [system.media.systemsounds]::Exclamation.play()

    Execute-TextToSpeach

    #$OpenCsvResultsButton.BackColor = 'LightGreen'
    #$OpenXmlResultsButton.BackColor = 'LightGreen'

    #Deselect-AllComputers
    Deselect-AllCommands

    # Garbage Collection to free up memory
    [System.GC]::Collect()
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDNUVrB9eyu5dKNdLaHFLDsPZ
# RAGgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUaIUaNwDyzuoxwdsoEGEzpBmLjNYwDQYJKoZI
# hvcNAQEBBQAEggEAuvk1V6WLmsMZAt7fCJALG2rWPW5GJqHrV2Phhgb5RM3J1fqh
# gCEaLdZYY1MPggFUvO/P1Ka/9SraH9qbdDZtl6eV5epTmS++IUeHi0EyOhf6hf7g
# IwMUWl8ms+YZ2UBGkagjUgsqDK2As6uJ6dfgKWgZmsZ6qmkvmB1U71IT6ze0NTeN
# j4t11qNqbLoan+tUkQvuE0RLlZgyQJ/lFWeNe/eGpzQYxniLER4iTncNgR0oN/+T
# /wP8zoWfdh0p87nBgiCyzp7hUiPVu9+a9yQ75R0y/8LEPv72TOKIF/q2Op3/0JoI
# sxIgPTGJBjvqnsTF/xs07jqnp3ncnVNQHPw0Uw==
# SIG # End signature block
