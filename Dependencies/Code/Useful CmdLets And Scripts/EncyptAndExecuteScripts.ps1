# https://community.idera.com/database-tools/powershell/powertips/b/tips/posts/encrypting-powershell-scripts


function Encrypt-Script {
    param(
        $Path, 
        $Destination
    )
    $script = Get-Content $Path | Out-String
    $secure = ConvertTo-SecureString $script -asPlainText -force
    $export = $secure | ConvertFrom-SecureString
    Set-Content $Destination $export
    "Script '$Path' has been encrypted as '$Destination'"
}


function Execute-EncryptedScript($path) {
    trap { "Decryption failed"; break }
    $raw = Get-Content $path
    $secure = ConvertTo-SecureString $raw
    $helper = New-Object system.Management.Automation.PSCredential("test", $secure)
    $plain = $helper.GetNetworkCredential().Password
    Invoke-Expression $plain
}

# Testing Message Encryption
'notepad.exe' | Set-Content -Path .\test.ps1
Get-Content -Path .\test.ps1
Encrypt-Script .\test.ps1 .\test-encrypted.bin
Get-Content -Path .\test-encrypted.bin
Execute-EncryptedScript .\test-encrypted.bin

  










# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUlmUVcGuC7r7XvMPEaXeO65z2
# xnSgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUWMGYkigXW5hcs6x0KoA0cJskpw8wDQYJKoZI
# hvcNAQEBBQAEggEApUJKcTUKjwJJHaWQchQfG/2IoHHdmx/Ql7XkNZ8m8APC7UKG
# f7qnBBR2+ZR6wE41bUhFmfYlhCfzyZJrUwXWjMsaoqj4zWEQ311gamtwqXZhVI59
# oTZ3y6/xvTOOzLozLDaRquZb6OnQ94bUmxvsnT3Jj6pJX4L1E6keCFiKS9aPqXEP
# 6ZhBNexNlYxo9tH6FuGt0kMn3vUb/IdOlYdhRQsudmyNQpJRBPlHoOOMRrcFHK4o
# GG1ypupPJTflrgJ6lLutnyGy3aAkkXfyfKha3rwrCJUJae2BsE4rLpgS/aM8G7DW
# 55CZyvouC7lQGz4e4Cibt/7XaivLhBga0ky8xg==
# SIG # End signature block
