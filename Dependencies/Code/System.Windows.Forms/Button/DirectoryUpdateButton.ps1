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
# mcWgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU6c4lHRSNowk1hSHfkv7gv/7YuJEwDQYJKoZI
# hvcNAQEBBQAEggEAMke7PixTBUK0GbbNy2PTfbQGwt4SrJWWBjhWMZgGjCfSrsSH
# 5SuUIjwqcrv+7DkiE93a/uXA1Z4mNBgVv6uJJ7TjVbKM6kDhS7kf836ADCtCSsVB
# M2ptspqPKimsPeWZ/wc1ynZkyV/tyYbyfdpUvSxLHpHrrXMT+/oHQwyuh/5Kon2a
# 7IOxKnGxy3NhG2dJF0pAp9uH6JKFSOuk3HWDRJ+WozCK8+Y9cEXmP2XAnz3K1Qo7
# zMHizic2JZANHVQCm0vZoLSW2jvXjzDClX5InLg1tL6OVPLMI8YTHofLpe+FvOr4
# 90KyW5QE7jgQ6XYTf8kUM3ItXysGtpe4OOmtUw==
# SIG # End signature block
