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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCIj+vjrgq1KPhw0OFeI1QPul
# mDegggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUcgk7BIz6HQbnTRpuNrcFVRe5LDIwDQYJKoZI
# hvcNAQEBBQAEggEARhwNyTkrCQXeHkqS4l9Hn7atEojjD8/uA5dnHFI2ZrEbY0Ig
# IPwd4CttJQW9BKhOl+8W/ykpkCcMpafKhPtrMneK7p8bh710qbZ6kOhcyObtnoII
# 1seBGU7Fx9TcO2xUT2WURl4WW9H/G49LLIWFiH5fsmSGcTlRGwXzv6zKPBd+S63j
# WlhOjfdxpyDSjL7FvkT4kOMyTfDi8IHOlOxkEgFXvaSOGkXJ2sMqpte47l9BVkSv
# +pEj89s42/OYR212o+xB+oNHvBejRrDzZNtlDj5M5KgIMwGUjun6x8khfwePMn/a
# 6EiYCJ3KVxOKmfkBzTF8q/DJzchBoDuuzfyyyQ==
# SIG # End signature block
