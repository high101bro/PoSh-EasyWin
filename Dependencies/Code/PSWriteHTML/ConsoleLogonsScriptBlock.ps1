$ConsoleLogonsScriptBlock = {
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
                CollectionType = 'ConsoleLogons'
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
                CollectionType = 'ConsoleLogons'
            }
        }
    }
}

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUWDK6GHv/QovDuVGtZvd2ikYR
# x/KgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU624GlIML9632+gcjl6iTWisgLIgwDQYJKoZI
# hvcNAQEBBQAEggEACsuz+OEKa3lTKVeQKz9xbWf/HC+UrGwn8m+OMS75xAp4+Egk
# wvweOHDFYD3nDbeL+eazJoOu57oHKLES+Rct7sak99cs9mo3apdMrVCQ9YPfspC2
# csreAPGss1/YWtcRunk2YMB9yJiO1npmjI6j5gyLsgDaAN8ylCGx1nszceBwPg1x
# PnAupwDG4llB7yG179wLVIZ6JPqeF9X7CjVZ8puh4UW1EjJvyqz1QuNdg8pR4lqm
# 1M7Jo0oK1LH+/fOgOzz36h1+3lDdgo5S43YVA/wyQSFl3aoSVEvhY8SUoeENS29f
# WQPIgKfFs7j5EIwIaKFxiwUHU4CNbfm8CCwGvQ==
# SIG # End signature block
