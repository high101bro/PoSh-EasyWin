$RegistryValueNameSearchRichTextboxAdd_MouseEnter = {
    if ($this.text -eq "Enter Value Name; One Per Line") {
        $this.text = ""
    }
}

$RegistryValueNameSearchRichTextboxAdd_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter Value Name; One Per Line"
    }
}

$RegistryValueNameSearchRichTextboxAdd_MouseHover = {
    Show-ToolTip -Title "Registry Search (WinRM)" -Icon "Info" -Message @"
+  Enter one Value Name per line
+  Supports RegEx, examples:
    +  [aeiou]
    +  ([0-9]{1,3}\.){3}[0-9]{1,3}
    +  [(http)(https)]://
    +  ^[(http)(https)]://
    +  [a-z0-9]
+  Will return results with partial matches
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6+dv3CvLcYG4HL7w6TCeW8Ul
# vHugggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUPwF6DKK5udiD1iczUbJIdzEtRI8wDQYJKoZI
# hvcNAQEBBQAEggEAGW+KkM0DjMmvtIiZzu5r4UyAe0fQwLYY403KcIB3nrshylFD
# ldyvwETooquIQcGd1iz7CHVedPCPwjE+uuTBaKvq8wCLfuO0GjSG6JOak+Su+9q5
# Q0TlgFjgkIhpsFaKIaChkX32tA6fY0Poxv7CCilcPBL1kfTwwgmPGDYJwcqF3D9P
# Q68YtYrqW9JDlKCKz8++xQZaPjlRGQdw25eYbuJN2JXtNNUlJWj6pgclJTt9AY5K
# JFsZFuevxr8DGM7mLeQbJEt9ugGODMAVZxPF5Mo9LhUDeddPR29DXVDHDvcZSa5F
# 7KuuTfKVZU6aS63hLHZo/dOELMNxGSZfOeLoRQ==
# SIG # End signature block
