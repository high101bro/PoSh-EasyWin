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
# SzSgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU5DQYqUN4KZLpKYTSGrYrNNVVHyIwDQYJKoZI
# hvcNAQEBBQAEggEAV8ZI80gKvH1uoiSMITqDi+efYLhaZHWxkAkXT19QFfThWYfm
# zKqqGfd1EfM/dnSSWVXZS4ifhe35mBnWz5kM2/GYsCHZirelE9T8c8Z8jYWXAc/l
# FvM8+mFeZZXq9tIMcA1/gEcwGSuYf0CYcyYsbF2F+B1mzM5YG5QbzvauGZXWACO7
# sjfXc13J/Tc7WU7APde2ttn+zF7mAWNw/Nd6XTds4dEJCmVhkHN8Q8Mpm25lA7Q6
# 0EjZez2DlYBfycMFHwnENmWAjmpuFGmUoAqJ0Txe4YiERCKz1IKQXTsSjm1PkGVx
# 7sjY41CuD5Em0ceGcPbzp4cO515Nxmo2XQXacw==
# SIG # End signature block
