$PowerShellSessionsScriptBlock = {
    Get-WSManInstance -ResourceURI Shell -Enumerate |
        ForEach-Object {
            $Days    = [int]($_.ShellRunTime.split(".").split('D')[0].trim('P'))    * 24 * 60 * 60
            $Hours   = [int]($_.ShellRunTime.split(".").split('T')[1].split('H')[0]) * 60 * 60
            $Minutes = [int]($_.ShellRunTime.split(".").split('H')[1].split('M')[0]) * 60
            $Seconds = [int]($_.ShellRunTime.split(".").split('M')[1].split('S')[0]) + $Minutes + $Hours + $Days
            $_ | Add-Member -MemberType NoteProperty -Name LogonTime -Value (Get-Date).AddSeconds(-$Seconds) -PassThru
        } |
        Select-Object @{n='PSComputerName';e={$env:Computername}}, ClientIP, Owner, ProcessId, State, ShellRunTime, ShellInactivity, MemoryUsed, ProfileLoaded,
        LogonTime, @{n='CollectionType';e={'PowerShellSessions'}}
}












# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkncDw088XQJ5msWGHOt8b/Pz
# LS6gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUXHv3UNaBjYyVwj76KBomVONukScwDQYJKoZI
# hvcNAQEBBQAEggEAWiTapjppILP+8Ew4/gMb9hToPOSRDhAsBR4EBLsN9+7lECmH
# rcS/kXddF/alwqDZbbNlCulY7V6mX1uMZwv0wSy4v+uRdNW8cTe2RDKfARY6Yrb5
# 8OIQVoednHw6XapHp6JKcRkabV8OKiUubkK3oUNsif+g7QqYEAa7Cpe40svILGba
# v5/raEYclVMUhEpn5bsPEf6UbnSZYHX3oe7zHt0leziWjSIHQlj9iCo53sgPJWDk
# k4zb/+9IOU1VgW+pvxx0Iur8srzEEjNOsJ2GnpzrnjAFLSm8+7MSXjM2iiwLdeDj
# gH9gQS+mXdJW5e/CQN0QVF7lBE18BEglO+THcA==
# SIG # End signature block
