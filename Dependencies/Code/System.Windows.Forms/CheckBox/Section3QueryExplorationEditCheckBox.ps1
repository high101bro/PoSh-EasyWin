$Section3QueryExplorationEditCheckBoxAdd_Click = {
    if ($Section3QueryExplorationEditCheckBox.checked){
        $Section3QueryExplorationSaveButton.Text                    = "Save"
        $Section3QueryExplorationSaveButton.ForeColor               = "Red"
        $Section3QueryExplorationDescriptionRichTextbox.ReadOnly    = $false
        $Section3QueryExplorationDescriptionRichTextbox.BackColor   = 'White'
        $Section3QueryExplorationDescriptionRichTextbox.ForeColor   = 'Blue'
        $Section3QueryExplorationWinRSCmdTextBox.ReadOnly           = $false
        $Section3QueryExplorationWinRSCmdTextBox.BackColor          = 'White'
        $Section3QueryExplorationWinRSCmdTextBox.ForeColor          = 'Blue'
        $Section3QueryExplorationWinRSWmicTextBox.ReadOnly          = $false
        $Section3QueryExplorationWinRSWmicTextBox.BackColor         = 'White'
        $Section3QueryExplorationWinRSWmicTextBox.ForeColor         = 'Blue'
        $Section3QueryExplorationPropertiesWMITextBox.ReadOnly      = $false
        $Section3QueryExplorationPropertiesWMITextBox.BackColor     = 'White'
        $Section3QueryExplorationPropertiesWMITextBox.ForeColor     = 'Blue'
        $Section3QueryExplorationPropertiesPoshTextBox.ReadOnly     = $false
        $Section3QueryExplorationPropertiesPoshTextBox.BackColor    = 'White'
        $Section3QueryExplorationPropertiesPoshTextBox.ForeColor    = 'Blue'
        $Section3QueryExplorationRPCWMITextBox.ReadOnly             = $false
        $Section3QueryExplorationRPCWMITextBox.BackColor            = 'White'
        $Section3QueryExplorationRPCWMITextBox.ForeColor            = 'Blue'
        $Section3QueryExplorationRPCPoShTextBox.ReadOnly            = $false
        $Section3QueryExplorationRPCPoShTextBox.BackColor           = 'White'
        $Section3QueryExplorationRPCPoShTextBox.ForeColor           = 'Blue'
        $Section3QueryExplorationWinRMWMITextBox.ReadOnly           = $false
        $Section3QueryExplorationWinRMWMITextBox.BackColor          = 'White'
        $Section3QueryExplorationWinRMWMITextBox.ForeColor          = 'Blue'
        $Section3QueryExplorationWinRMCmdTextBox.ReadOnly           = $false
        $Section3QueryExplorationWinRMCmdTextBox.BackColor          = 'White'
        $Section3QueryExplorationWinRMCmdTextBox.ForeColor          = 'Blue'
        $Section3QueryExplorationWinRMPoShTextBox.ReadOnly          = $false
        $Section3QueryExplorationWinRMPoShTextBox.BackColor         = 'White'
        $Section3QueryExplorationWinRMPoShTextBox.ForeColor         = 'Blue'
        $Section3QueryExplorationTagWordsTextBox.ReadOnly           = $false
        $Section3QueryExplorationTagWordsTextBox.BackColor          = 'White'
        $Section3QueryExplorationTagWordsTextBox.ForeColor          = 'Blue'
        $Section3QueryExplorationSmbPoshTextBox.ReadOnly            = $true
        $Section3QueryExplorationSmbPoshTextBox.BackColor           = 'White'
        $Section3QueryExplorationSmbPoshTextBox.ForeColor           = 'Blue'
        $Section3QueryExplorationSmbWmiTextBox.ReadOnly             = $true
        $Section3QueryExplorationSmbWmiTextBox.BackColor            = 'White'
        $Section3QueryExplorationSmbWmiTextBox.ForeColor            = 'Blue'
        $Section3QueryExplorationSmbCmdTextBox.ReadOnly             = $true
        $Section3QueryExplorationSmbCmdTextBox.BackColor            = 'White'
        $Section3QueryExplorationSmbCmdTextBox.ForeColor            = 'Blue'
        $Section3QueryExplorationSshLinuxTextBox.ReadOnly           = $true
        $Section3QueryExplorationSshLinuxTextBox.BackColor          = 'White'
        $Section3QueryExplorationSshLinuxTextBox.ForeColor          = 'Blue'
    }
    else {
        $Section3QueryExplorationSaveButton.Text                    = "Locked"
        $Section3QueryExplorationSaveButton.ForeColor               = "Green"
        $Section3QueryExplorationDescriptionRichTextbox.ReadOnly    = $true
        $Section3QueryExplorationDescriptionRichTextbox.BackColor   = 'White'
        $Section3QueryExplorationDescriptionRichTextbox.ForeColor   = 'Black'
        $Section3QueryExplorationWinRSCmdTextBox.ReadOnly           = $true
        $Section3QueryExplorationWinRSCmdTextBox.BackColor          = 'White'
        $Section3QueryExplorationWinRSCmdTextBox.ForeColor          = 'Black'
        $Section3QueryExplorationWinRSWmicTextBox.ReadOnly          = $true
        $Section3QueryExplorationWinRSWmicTextBox.BackColor         = 'White'
        $Section3QueryExplorationWinRSWmicTextBox.ForeColor         = 'Black'
        $Section3QueryExplorationPropertiesWMITextBox.ReadOnly      = $true
        $Section3QueryExplorationPropertiesWMITextBox.BackColor     = 'White'
        $Section3QueryExplorationPropertiesWMITextBox.ForeColor     = 'Black'
        $Section3QueryExplorationPropertiesPoshTextBox.ReadOnly     = $true
        $Section3QueryExplorationPropertiesPoshTextBox.BackColor    = 'White'
        $Section3QueryExplorationPropertiesPoshTextBox.ForeColor    = 'Black'
        $Section3QueryExplorationRPCWMITextBox.ReadOnly             = $true
        $Section3QueryExplorationRPCWMITextBox.BackColor            = 'White'
        $Section3QueryExplorationRPCWMITextBox.ForeColor            = 'Black'
        $Section3QueryExplorationRPCPoShTextBox.ReadOnly            = $true
        $Section3QueryExplorationRPCPoShTextBox.BackColor           = 'White'
        $Section3QueryExplorationRPCPoShTextBox.ForeColor           = 'Black'
        $Section3QueryExplorationWinRMWMITextBox.ReadOnly           = $true
        $Section3QueryExplorationWinRMWMITextBox.BackColor          = 'White'
        $Section3QueryExplorationWinRMWMITextBox.ForeColor          = 'Black'
        $Section3QueryExplorationWinRMCmdTextBox.ReadOnly           = $true
        $Section3QueryExplorationWinRMCmdTextBox.BackColor          = 'White'
        $Section3QueryExplorationWinRMCmdTextBox.ForeColor          = 'Black'
        $Section3QueryExplorationWinRMPoShTextBox.ReadOnly          = $true
        $Section3QueryExplorationWinRMPoShTextBox.BackColor         = 'White'
        $Section3QueryExplorationWinRMPoShTextBox.ForeColor         = 'Black'
        $Section3QueryExplorationTagWordsTextBox.ReadOnly           = $true
        $Section3QueryExplorationTagWordsTextBox.BackColor          = 'White'
        $Section3QueryExplorationTagWordsTextBox.ForeColor          = 'Black'
        $Section3QueryExplorationSmbPoshTextBox.ReadOnly            = $true
        $Section3QueryExplorationSmbPoshTextBox.BackColor           = 'White'
        $Section3QueryExplorationSmbPoshTextBox.ForeColor           = 'Black'
        $Section3QueryExplorationSmbWmiTextBox.ReadOnly             = $true
        $Section3QueryExplorationSmbWmiTextBox.BackColor            = 'White'
        $Section3QueryExplorationSmbWmiTextBox.ForeColor            = 'Black'
        $Section3QueryExplorationSmbCmdTextBox.ReadOnly             = $true
        $Section3QueryExplorationSmbCmdTextBox.BackColor            = 'White'
        $Section3QueryExplorationSmbCmdTextBox.ForeColor            = 'Black'
        $Section3QueryExplorationSshLinuxTextBox.ReadOnly           = $true
        $Section3QueryExplorationSshLinuxTextBox.BackColor          = 'White'
        $Section3QueryExplorationSshLinuxTextBox.ForeColor          = 'Black'
    }
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU6gronDCbe3cxxDgrJDWxA6aO
# bNugggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUwJddnIgrAgWDhPTyUI2Qhzn57m4wDQYJKoZI
# hvcNAQEBBQAEggEAylyuBqBv0emD7PW55cK/0/gyppoYQjXtDhcZGQvaQIN0D4Zz
# u6P6fXoYgmtGNcPmMfyAF6QQ4ZLNm8RkUW8wEERQBbDo5thKHjnXldhYJm0R989W
# sZ805lfitYcmFOdIYuG3oWX9ofCi92lMRjSYiCMnJGTDwpjjkx5peKOp+2D2f1C3
# fSpnvfAT3N6ctX+SsBn9KkDemTVb2UgPzBox+j7GWWfzkNfe7XrmDfPBWSzIS1hV
# 9m1Mrgxh5yGVrJ1bNL2BbTUn3FyY1BkWZq/DOTPR3utKrL3aGA3oDmcoHqiV8GIW
# JM/o2Jlza9zoNOXivqeBBOd4T1ov/O7DVDXz9A==
# SIG # End signature block
