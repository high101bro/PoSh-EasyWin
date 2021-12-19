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

    #Deselect-AllComputers
    Deselect-AllCommands

    # Garbage Collection to free up memory
    [System.GC]::Collect()
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUet/TRa5bvN76vBhpjZIDTq9i
# UYqgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUYuV6ctKegIrFFRS2zSMWH52VqdIwDQYJKoZI
# hvcNAQEBBQAEggEAavIH5pY7Tl4thNc6IHiUf3BGB+iyOjBL1EiECJPFcM60Ew+A
# /EzG+aPUoQiwf6DEF53uOY0PgPGckoeX5Z2l/9xyRHgfXxYDUcjCgcpJw8kRvdJ3
# kBk/IvSK7Ueq/nKl+TTox5bWwBo/1swUj/m2apFivh6Zd+0NSslZGRusDCBa137v
# RPOtO4A7kmMxpLF3UQ485LyH4UH8ibs4xVo4vxN1w2nDlDlm5rFLl3RPNTKaGt/4
# bsamCYAX9OIGNGAHOL83Tf79tXVHPnZvMGHSPcvRR8McgGnN9g63vQZAty6aqYQF
# FC7RrtRgpvxP4YEPxl8YW/KQCNRf+65MhOiZwQ==
# SIG # End signature block
