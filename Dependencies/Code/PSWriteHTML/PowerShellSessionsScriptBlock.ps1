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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEkJi26oo14N4hegOU2+p6DcN
# /4+gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUJiLUkfOij09F6YujPnTJa1HAaaQwDQYJKoZI
# hvcNAQEBBQAEggEAlM7YUqh4nOni3yV3llk3Ca16wCWAcAp/CxZg5rnJPomQGI7q
# MHigArbXMZmT7ezW8fmIxhKv8LqelXw0ezbLSeoBsIIUIwZ2LtMmcUZox0U1UCzb
# PBozFE79exAx444Q6791j1fRrNYNf/XUPsGuvmc9wTwJ5LC16SHD5JL64bFnWmvf
# Od2fEOQHD/kctybS9CxULCWxxN6rwXTCAEC6HqZh5Y8zZTPz+aI/ppL7zbKVns0F
# PecVgxfQgiuG3V31//wAUkf2HaSE2UHy2InA7JKBPyVOVxE+a9e+b5PR6k2lTpPH
# CYC/f7SlQJbI4qljxrM/D+A/kjBQ85D54tizFA==
# SIG # End signature block
