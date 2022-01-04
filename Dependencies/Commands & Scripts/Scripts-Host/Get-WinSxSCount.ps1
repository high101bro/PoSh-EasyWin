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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUp0caKJjchWyD+BQe6vT7I34V
# Qm+gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUZIoCnMergh32Ghuhoe4gCXpKzIAwDQYJKoZI
# hvcNAQEBBQAEggEASDcGke/6+AlKPaTt9YU+lpvWxvxJdACmRLunlIInqx6kPyB7
# qh2OPbxgGABxTYAUEpzH1jegg1+88xmLHRI+Z7pWxFS3C7xRdtRO0cCZcsL68D9f
# h3cBSRd1F17snJUK26p8yBPxRstsbKIcHqtnz08tLIwdmdbxqzUCzg82Jm6ilp/n
# CbXs8GoquOBGeUj5GShwhYxXdU0zWxtxwbRFx5Wwt3KGw053dBouhrgqUFWN3em9
# gffFmJQn2srN7kdLhhIBDWaNiccCrTvqAsfpx5waqolnPuKxoy7skG7rwJjupjRT
# vHNkwAZ1IYxcRX593QAuKGh4t6r/J6xeHMpNjg==
# SIG # End signature block
