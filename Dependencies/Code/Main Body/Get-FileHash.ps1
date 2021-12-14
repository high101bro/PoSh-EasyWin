# This function is created within a string variable as it is used with an an agrument for Invoke-Command
# It is initialized below with an Invoke-Expression

$GetFileHash = @'
function Get-FileHash{
    param (
        [string]$Path,
        [string]$Algorithm
    )
    if ($Algorithm -eq 'MD5') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'SHA1') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'SHA256') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'SHA384') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA384CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'SHA512') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA512CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'RIPEMD160') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.RIPEMD160Managed
    }


    $Hash=[System.BitConverter]::ToString($HashAlgorithm.ComputeHash([System.IO.File]::ReadAllBytes($Path)))

    $Properties = @{
        "Path"       = $Path
        "Hash"       = $Hash.Replace("-", "")
        "Algorithm"  = $Algorithm
        "ScriptNote" = 'Get-FileHash Script For Backwards Compatibility'
    }
    $ReturnFileHash = New-Object –TypeName PSObject –Prop $Properties
    return $ReturnFileHash
}
'@
Invoke-Expression -Command $GetFileHash




# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3A2dje3dTuCc9vVXxZffUrkn
# DcWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQURzEa77Pn6G++QCNu8wC4KOfMFAswDQYJKoZI
# hvcNAQEBBQAEggEATUyq1ABX726RKu+FB44wV2+CP7KVB2oEISD9+CBMJdOSDYI0
# pHkap2McnVmZ3O0EDQ7EhmF+p4DvZVu6+QtaOyf9W6RVNZWfb23tFmjpI5QN13HN
# eTauaraizaVE4CdhnkZRYSoLvnGuphvHR6/wxJ80vto0bYHULRhKsmCy53WLPktR
# BM5Tg8Wy2HEj6Kuw6O6DFK+cBEHQKl3HESBQtEaqoOz03ECayCuLAakEiZl52cED
# GTI/hIEO2YevTE+a2KdWqwjgCb79VPbaqw9ZcJfajty0AwC7TCVRfE+XkI4kRxzM
# Em0Leaw0f+0lJZ16btktvABbP/ikGjo9EBZAcg==
# SIG # End signature block
