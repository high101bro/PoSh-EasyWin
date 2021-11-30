$DirectoryOpenButtonAdd_Click = {
    if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {
        $OpenDirectory = $script:CollectionSavedDirectoryTextBox.Text
    }
    elseif (Test-Path $CollectedDataDirectory) {
        $OpenDirectory = $CollectedDataDirectory
    }
    else {
        $OpenDirectory = $PoShHome
    }
    Invoke-Item -Path $OpenDirectory
}

$DirectoryOpenButtonAdd_MouseHover = {
    Show-ToolTip -Title "Open Results" -Icon "Info" -Message @"
+  Opens the directory where the collected data is saved.
+  The 'Collected Data' parent directory is opened by default.
+  After collecting data, the directory opened is changed to that
    of where the data is saved - normally the timestamp folder.
+  From here, you can easily navigate the rest of the directory.
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGmB1tmO4t6br3B3GMWqXtnKx
# yFKgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUX4p1WI5Lu41STlonlUHFqZ6oXvswDQYJKoZI
# hvcNAQEBBQAEggEACuLmtPQKi8NIq9vRsk02u1OIM/6YahKpRIHoDDRl/sPBtkYr
# d3OA7eTiuTwcRGZA7p0fgwibbf3j4ZNAXno3CS2E9TRVfskto9zYLLrkCu4Sb60y
# D3mUVps+wCFPBdp3Q4r3+HmZbVfHSURS7bH5GVx9CTfRcKouuWqWzeO6Pb2sdIkl
# 07LffGmrq2C/m1oCBdjVGzOuGy17P7jCow3f02gekzEQ1uh9KA/rnr/muuCfCQbc
# q3kXHMvvgSG1hjeOsC4/Vj8pORBzcf+65HLuux/g7gR+zDkp9IjCoBOlsOz2WcOG
# ZOPG4653JytoE/IdxZ6m/1iNx3V4N8iUWMGT+Q==
# SIG # End signature block
