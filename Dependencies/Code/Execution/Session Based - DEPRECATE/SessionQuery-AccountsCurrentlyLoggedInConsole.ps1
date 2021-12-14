$ExecutionStartTime = Get-Date
$CollectionName = "Accounts Currently Logged In via Console"

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)"
if (-not (Test-Path $OutputFilePath)){New-Item -Type Directory -Path $OutputFilePath -Force}

<# Version 1
Invoke-Command -ScriptBlock {
    Get-WmiObject -Class Win32_Process -EA "Stop" `
    | Foreach-Object {$_.GetOwner().User} `
    | Where-Object {$_ -ne "NETWORK SERVICE" -and $_ -ne "LOCAL SERVICE" -and $_ -ne "SYSTEM"} `
    | Sort-Object -Unique `
    | ForEach-Object { New-Object psobject -Property @{LoggedOn=$_} } `
    | Select-Object PSComputerName,LoggedOn
} -Session $PSSession `
| Set-Variable SessionData -Force
#>
<# Version 2
Invoke-Command -ScriptBlock {
    Get-WmiObject -Class Win32_Process -EA "Stop" `
    | Select-Object @{N='AccountName';E={$_.GetOwner().User}}, SessionID `
    | Where-Object {$_.AccountName -ne "NETWORK SERVICE" -and $_.AccountName -ne "LOCAL SERVICE" -and $_.AccountName -ne "SYSTEM" -and $_.AccountName -ne $null} `
    | Sort-Object -property AccountName -Unique `
    | ForEach-Object { New-Object pscustomobject -Property @{PSComputerName=$env:ComputerName;AccountName=$_.AccountName;SessionID=$_.SessionID} } `
    | Select-Object PSComputerName,AccountName,SessionID
} -Session $PSSession `
| Set-Variable SessionData -Force
#>


<# Version 3 #>
$scriptBlock = {
    ## Find all sessions matching the specified username
    $quser = quser | Where-Object {$_ -notmatch 'SESSIONNAME'}

    $sessions = ($quser -split "`r`n").trim()

    foreach ($session in $sessions) {
        try {
            # This checks if the value is an integer, if it is then it'll TRY, if it errors then it'll CATCH
            [int]($session -split '  +')[2] | Out-Null

            [PSCustomObject]@{
                PSComputerName = $env:COMPUTERNAME
                UserName       = ($session -split '  +')[0].TrimStart('>')
                SessionName    = ($session -split '  +')[1]
                SessionID      = ($session -split '  +')[2]
                State          = ($session -split '  +')[3]
                IdleTime       = ($session -split '  +')[4]
                LogonTime      = ($session -split '  +')[5]
            }
        }
        catch {
            [PSCustomObject]@{
                PSComputerName = $env:COMPUTERNAME
                UserName       = ($session -split '  +')[0].TrimStart('>')
                SessionName    = ''
                SessionID      = ($session -split '  +')[1]
                State          = ($session -split '  +')[2]
                IdleTime       = ($session -split '  +')[3]
                LogonTime      = ($session -split '  +')[4]
            }
        }
    }
}
Invoke-Command -ScriptBlock $scriptBlock `
-Session $PSSession `
| Set-Variable SessionData -Force


$SessionData | Export-Csv    -Path "$($OutputFilePath)\$($CollectionName).csv" -NoTypeInformation -Force
$SessionData | Export-Clixml -Path "$($OutputFilePath)\$($CollectionName).xml" -Force
Remove-Variable -Name SessionData -Force


Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `${function:Get-AccountLogonActivity} -ArgumentList @(`$AccountsStartTimePickerValue,`$AccountsStopTimePickerValue) -Session `$PSSession'"


$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()


$script:ProgressBarQueriesProgressBar.Value += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWFCWnCyl9JGl1tkou5tREvdH
# x7egggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUOQsV4UgEh9aGytGKqpxRDqHCquwwDQYJKoZI
# hvcNAQEBBQAEggEABNnqmcQPoeQM+2SQC1IAih4oP0KGbKsz0jVJT4A/hQzKQlD9
# vMVoHtNnvZbEFZgMSQdpxDL/jWe3lR+RhIV6MSEuyX03LaRn40hDixyNoypoFe7z
# 39Tair2PPR/0MPtIjXKRg9vyPsDYWnKb3hvfPtrXIqnvyM+vnm5jwXaspZi7T5/Q
# 9v20R8vkigQFn9G5A4NvNBxcWQr07Qf4ehcjWFNsXohsyG6aUv8pjimjv5aHK6Kv
# PYB6Z6vuyzIALLmRuqqfAlwHJV2UmtXoqIm+ZEuhcKmfrVHHrou5XhGCwof6ThB3
# /UF2IW5axHLhryJidHuoxrJeyL8ipqEQUUqDHw==
# SIG # End signature block
