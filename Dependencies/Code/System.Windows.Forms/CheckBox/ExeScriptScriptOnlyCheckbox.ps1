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
# VOqgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUR9uzBIcTinZU5hDQ9zf2OZLQBsEwDQYJKoZI
# hvcNAQEBBQAEggEAHIOR7pYIxfhlfATIcDPvd86zA/zbJ9eDkKx0f5w0SeZ4gMfc
# PUJFAYY5g6nKVDohUk38owMoEFQp95JfyKpUfMpmCaR/QMwSdN1xz/mclKOE/NEE
# 1N2hqGSlnaIQI3AiXgjkaRor2XKTQkOsfJn7/xKQND5cSx6uhoQ1CIo1YgjImgII
# N8JkO3Rd7UtjIaB/rr8waZpY98GTgXpKzCNTCG5lB7PIuzLLQpbV0EykhE2/FG5T
# MpsvaSN33uqloS1dSZXrV9kN5k7CfG3NC68gdFkna+x8eP9SN3doHKqsDtDVaBPD
# UgYwK15vj3OZmr7brFm4k6tpXpkhaE32daAtEQ==
# SIG # End signature block
