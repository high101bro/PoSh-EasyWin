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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/SzKpkstUECN00AvAi8Ot+1p
# 1TmgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUnyTcUXosm+i1vtgTZg2PKWhj6uIwDQYJKoZI
# hvcNAQEBBQAEggEAX02UqIH+kwuMfWboJx8Wg5xDz51AT5s55h9XKkQX8Oi4PO7V
# jNGF2UbT+cPAEnDwuCdjlBGPAWYVdCQWnRLsOqlSk+1UmBxpUhIAs3lD5QeqcqDu
# 4WmV2skOGZCc1UGn5BuHysPeZ3/T/d7H9FjG9s0loib7ClfLKvqcA+gzaI0LMNsJ
# zaSIRiIYHdAlyxFtMW50InbdSvsbqgQtMSCIQwOYFGW2Xx5Maa4fXohvECeovK+t
# wmZKfG9jDnpJw0fpp2AgIM2b4W59DpVL4Cv6kF2FIJSr3ZNyuof4xDojcz2XThs4
# KfwFabYDdUnMBHekvovb3CDUnoNwq3FZ94vZYg==
# SIG # End signature block
