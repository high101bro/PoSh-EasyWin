<#
.SYNOPSIS
Gets a count of WinSxS files.

.DESCRIPTION
WinSxS (or Windows SxS) is short of 'Windows Side by Side'. The WinSxS feature is used by many applications to attempt to alleviate problems that arise from the use of dynamic-link libraries (DLLs). Such problems include version conflicts, missing DLLs, duplicate DLLs, and incorrect or missing registration. Windows stores multiple versions of a DLL in C:\Windows\WinSxS and loads them on demany to reduce dependency problems for applications that include a side-by-side manifest.

DLL side-loading attack makes use of WinSxS directory. When an application uses this directory to retrieve DLL, it needs to have a manifest. This application manifest lists the DLL that can be used at run time by this application and is used to determine which version of DLL to use.
#>

[PSCustomObject]@{
    Name           = 'Windows Side by Side (Count)'
    PSComputerName = hostname
    FileCount      = $((Get-ChildItem -Path 'C:\Windows\WinSxS').count)
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUb9UV2XZgG6CNahNCDKjjqx3E
# DBCgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUvzV+G3q4MlqLaPqhXpftVcxh2mUwDQYJKoZI
# hvcNAQEBBQAEggEAbnXZKfEzCnT24/so0JPx06xDkqYFPifNsRN4Spr9b0iS5ZRO
# T4ajimeIW8SS7rJtHMvx5c4bfWrCqzNol6423jRhsgEuS6dRXfFJgh0X9Qnug7sc
# HWcomNlrtqbSyv3WkIpdesicyJoyLGVTE1PDCqRzhXdtBGzHTfQBqAJFu44OVJLI
# yqz+iIgYRUxKVvksAjd51rkTuh9M6139Fyw6j6nucR5JsgX65691OWpaMRWxWFRT
# Hfia/ip6LxEdf1/kF650DjDZ+CBkQgIRhYT4fAWDtTN/ZVdvQqS+QSLpTPv/5PlK
# b9i8+bUlij71gRUpzOPSVIv1MdvOpIk4J7JJIg==
# SIG # End signature block
