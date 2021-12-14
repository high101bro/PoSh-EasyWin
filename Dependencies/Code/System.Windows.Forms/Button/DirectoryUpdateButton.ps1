$DirectoryUpdateButtonAdd_Click = {
    $script:CollectedDataTimeStampDirectory = "$CollectedDataDirectory\$((Get-Date).ToString('yyyy-MM-dd HH.mm.ss'))"
    $script:CollectionSavedDirectoryTextBox.Text = $script:CollectedDataTimeStampDirectory
}

$DirectoryUpdateButtonAdd_MouseHover = {
    Show-ToolTip -Title "New Timestamp" -Icon "Info" -Message @"
+  Provides a new timestamp name for the directory files are saved.
+  The timestamp is automatically renewed upon launch of PoSh-EasyWin.
+  Collections are saved to a 'Collected Data' directory that is created
    automatically where the PoSh-EasyWin script is executed from.
+  The directory's timestamp does not auto-renew after data is collected,
    you have to manually do so. This allows you to easily run multiple
    collections and keep this co-located.
+  The full directory path may also be manually modified to contain any
    number or characters that are permitted within NTFS. This allows
    data to be saved to uniquely named or previous directories created.
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUf4oSNYxP8Fh86/EBD8nJAzHc
# mcWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU6c4lHRSNowk1hSHfkv7gv/7YuJEwDQYJKoZI
# hvcNAQEBBQAEggEAqRxpudHCnZp7cNDTRdJ6j/j0m3R/pNnWKTFLZOOiv/+EH4Le
# 7k0ck2Fb6FEy7prcQvnbd2gh9hDhtlxdd2cJcW+Gk4SIml7rpphSHn8HteaXxS+f
# 7PUMqtV60aGPKS68wsSSFcvzi3hV3nzTy4F4/vb3bF6btJ07dGE183sjRoW5PJep
# uR7QtowIpYntzO0ivvk1Kebu5V/Z6qiR+8PJLiJqcILsjK/0/YUEoO1guuP+KKRB
# 7ZsUFHPNjiztpvIaDMM8+w/ACpYjOD6ym8mv8pdj4mmw8+/R7G/O2pXyWXV6a+Qx
# bHWRxfaVkDH+sY5xauPMDYW2PxDvVAHH5MTQUg==
# SIG # End signature block
