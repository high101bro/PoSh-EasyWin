$ComputerListProvideCredentialsCheckBoxAdd_Click = {
    if ($script:ComputerListProvideCredentialsCheckBox.Checked -and (Test-Path "$script:CredentialManagementPath\Specified Credentials.txt")) {
        $SelectedCredentialName = Get-Content "$script:CredentialManagementPath\Specified Credentials.txt"
        $script:SelectedCredentialPath = Get-ChildItem "$script:CredentialManagementPath\$SelectedCredentialName"
        $script:Credential = Import-CliXml $script:SelectedCredentialPath
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Credentials:  $SelectedCredentialName.xml")
    }
    elseif ($script:ComputerListProvideCredentialsCheckBox.Checked -and -not (Test-Path "$script:CredentialManagementPath\Specified Credentials.txt")) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Credentials:  There are no credentials stored")
        Launch-CredentialManagementForm
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Credentials:  $([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)")
    }

    # Test View of Credentials
    ##Removed For Testing#$ResultsListBox.Items.Clear()
    #$ResultsListBox.Items.Add("Username: $($script:Credential.UserName)")
    #$ResultsListBox.Items.Add("Password: $($script:Credential.GetNetworkCredential().Password)")
}

$ComputerListProvideCredentialsCheckBoxAdd_MouseHover = {
    Show-ToolTip -Title "Specify Credentials" -Icon "Info" -Message @"
+  Credentials are stored in memory as credential objects.
+  Credentials stored on disk as XML files are encrypted credential objects using Windows Data Protection API.
    This encryption ensures that only your user account on only that computer can decrypt the contents of the
    credential object. The exported CLIXML file can't be used on a different computer or by a different user.
+  To enable auto password rolling, both this checkbox and the one in Automatic Password Rolling must be checked.
+  If checked, credentials are applied to:
    RDP, PSSession, PSExec
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqol/ecmUXSE0uTtFuTQ/cjyt
# gFmgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUGV1HMTiaKba4wqvsbe3EdPK3phUwDQYJKoZI
# hvcNAQEBBQAEggEAUS2tEC8Nweua87NCgkmk9PSPyenb9P9SajEEcOz6bbYV+NM2
# WeK4e21pni14rwRvWYt4CHy8V4T3B6EMNYKfKVokG0gP2Kkj3yG9o9TEVJ1RSrWj
# PBfqZsrjzg8JZV7NcxbkJIV6XZQM+KD6HCt/hoC4W6kcr3KLGvOt0FYof8d1E+Gx
# +JEJYMtFzxjTt0LJGT2BRtXUux0QkGemrMwST6U8b0XfKp9Ie6E3SIKsGUCAq43E
# vzMKleH5iLNjlwsFwZSTuzGntIBZP+g2ehivivblMyxB9kE7AYtpKqX/aFJyoAnB
# akW0BCbgVLtstwX5Fe0HNWD033/X/gG3culzEw==
# SIG # End signature block
