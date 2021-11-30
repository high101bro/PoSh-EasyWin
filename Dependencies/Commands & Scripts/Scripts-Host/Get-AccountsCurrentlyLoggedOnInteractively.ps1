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


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUt6z4UJY1iqXMm2xi0j38GCEM
# tqSgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUddRwugZZUL2GNbogGhHV9XU/4NYwDQYJKoZI
# hvcNAQEBBQAEggEAsNWOIzv+vmRoBoc7LPf5VRWDOncfH/z8DrKUDYarirIAhRUU
# 0wTiCMe/s0ZDz5z+5HyImCEH/W+cBzgCb73SvjCta031qDuhTSfTMcjkvEdN0I9W
# O4NCFjlKHr1Of1wB/gOfjwi9upJ16Z+7S7zh6uegUua6TRKqc7H43ktIf2C50IsZ
# lqPMarlMK3SCW2iJ3jQy5REn+Ub7OAu5u5+gMCpc0fDZ8Nqwd9J6Awimtze+lMk7
# ZwtDIeYexZOmoDBG38Nw3nFI8XhQ2eu5DS12TAE0SNRunZNT72l0IGYWnZrXL73x
# n3kQIMOJ9dLVjjIMh4q6v91dlGJ8b9jMUqL7Bw==
# SIG # End signature block
