<#
    .Synopsis
    Gets the PowerShell History of user profiles
#>
#Get-Content ((Get-PSReadLineOption).HistorySavePath)


$Users = Get-ChildItem C:\Users | Where-Object {$_.PSIsContainer -eq $true}

$Results = @()
Foreach ($User in $Users) {
    $UserPowerShellHistoryPath = "$($User.FullName)\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt"
    if (Test-Path $UserPowerShellHistoryPath) {
        $count = 1
        $UserHistory += Get-Content "$UserPowerShellHistoryPath" -ErrorAction Stop | ForEach-Object {"$_ `r`n"}
        foreach ($HistoryEntry in $UserHistory) {
            $Results += [PSCustomObject]@{
                PSComputerName    = "$env:COMPUTERNAME"
                HistoryCount      = "$Count"
                ProfileName       = "$($User.Name)"
                PowerShellHistory = "$HistoryEntry"
                ProfilePath       = "$($User.FullName)"
                HistoryPath       = "$UserPowerShellHistoryPath"
            }
            $Count += 1
        }
    }
    else {
        $Results += [PSCustomObject]@{
            PSComputerName    = "$env:COMPUTERNAME"
            HistoryCount      = "0"
            ProfileName       = "$($User.Name)"
            PowerShellHistory = "There is not PowerShell History for $($User.BaseName)."
            ProfilePath       = "$($User.FullName)"
            HistoryPath       = "$UserPowerShellHistoryPath"
        }
    }
}
$Results




# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUszyirTQMUyMhUMA0u7fE+/eg
# SzSgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU5DQYqUN4KZLpKYTSGrYrNNVVHyIwDQYJKoZI
# hvcNAQEBBQAEggEAk2f+3mcaX1BQ91FrFdvH5JmH4Se/cuX1FQTExO796pq29Vlo
# mesRbHhdaTT7DGEwYVeP/sxYJ5ascGNgUbF47BTI63bwyYIiNXkBx3Od4leTsMHL
# CA+oIbv6ljCsKKKk2ixIoKsepLkp7yveHpfhATGcUFWQXFI6u9wZ8Cl45J2qOQ2B
# C1ju/rRZPU4NR259vdaJ70AftxGyp92okRXcN5XdhLYbqaHQxx7U9ZsFWRBDpnDX
# paEoKkCfbj5ylZTxnLE7PW5axkdYEQeuvsLYx6PsLvSkhrq/+DVhwspQnO19dHlp
# mjTVK+1kgpcdNO9GlLXhxshz3fgFGapNdfu+lg==
# SIG # End signature block
