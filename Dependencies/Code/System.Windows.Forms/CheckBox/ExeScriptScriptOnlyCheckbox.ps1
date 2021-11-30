$ExeScriptScriptOnlyCheckboxAdd_Click = {
    if ($this.Checked -eq $true) {
        $ExeScriptSelectExecutableButton.Enabled  = $false
        $ExeScriptSelectExecutableTextBox.Enabled = $false
        $ExeScriptSelectDirRadioButton.Enabled    = $false
        $ExeScriptSelectFileRadioButton.Enabled   = $false
        $ExeScriptSelectExecutableTextBox.text    = 'Disabled - No files being copied over'
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.text = "User Specified Custom Script (WinRM)"
    }
    else {
        $ExeScriptSelectExecutableButton.Enabled  = $true
        $ExeScriptSelectExecutableTextBox.Enabled = $true
        $ExeScriptSelectDirRadioButton.Enabled    = $true
        $ExeScriptSelectFileRadioButton.Enabled   = $true
        if     ($ExeScriptSelectDirRadioButton.checked)  { $ExeScriptSelectExecutableTextBox.text = 'Directory:'}
        elseif ($ExeScriptSelectFileRadioButton.checked) { $ExeScriptSelectExecutableTextBox.text = 'File:'}
        $script:ExeScriptSelectDirOrFilePath      = $null
        $ExeScriptUserSpecifiedExecutableAndScriptCheckbox.text = "User Specified Files and Custom Script (WinRM)"
    }
}




# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUa++GMB9NSrqWbTNFppdU/AM7
# VOqgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUR9uzBIcTinZU5hDQ9zf2OZLQBsEwDQYJKoZI
# hvcNAQEBBQAEggEAjvFjmMJry2ueZ4sLRJIhBUlL06SW6V0vsuybVqA4dsiX7ut3
# zDp8w2MTQ7MBQcKOS6RUl0mlqPNBeCbScodqCSJ7NMP3x62ihO+rRlpq6f37J71H
# e2Nn45O60YspUG9NW09Xeh9Wk13ZJ/cZZKgwogwztt9iB/tG/ss6PZ+EhIQQSxa8
# m4BtfWAzq6vvBzAk1vfPeZ5Hl/ptvz1nljCpVamvJsIjw7ww1sxeujhQnEsEjUCE
# 2N0mDgFp5FjgwkrJSCmqC3NiQXTs6883EzeU0X0Ubsagyg5jlJgX9RDfjEiZpATy
# GdL2jOQ9Wala9dydqJS4b2bj0yGjYWaCWkiQxQ==
# SIG # End signature block
