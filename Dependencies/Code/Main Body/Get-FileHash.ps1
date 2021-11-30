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
# DcWgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQURzEa77Pn6G++QCNu8wC4KOfMFAswDQYJKoZI
# hvcNAQEBBQAEggEAvc10rtfn6I+s9cFeJF2sEfufMjXcd58ugVfgak/HEIepPC4e
# eaL/c6jz/c6XD3QZY4OiBvWRTLNtTW4pb2BkHroMO07vdW5Ji/oba8e/x6kDMy+D
# K6wFU2sbCXDPGH1CeaX0iLtwkqK5xpoD878+cz4jFPedvncDYufKTMZG69/+WKoW
# sDJW+bPkY0+XYhmDq2mZSGBGMFL3b+JYPUXGuCOEDaowOKa5Y1hBr5yHrXoli6V1
# E+chgBAe6kWs/t1J7vMFnYgWP/SXxqN34SXXuHDLgmKSayR04Y+kjaK0TOCSBSlD
# kWdNAMdVpXzy029YmwwDdu+/BX9eLqhdioO++g==
# SIG # End signature block
