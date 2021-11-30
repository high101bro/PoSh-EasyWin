$PoShEasyWinLicenseAndAboutButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3AboutTab

    if ($PoShEasyWinLicenseAndAboutButton.Text -eq "License (GPLv3)" ) {
        $PoShEasyWinLicenseAndAboutButton.Text = "About PoSh-EasyWin"
        $Section1AboutSubTabRichTextBox.Text   = $(Get-Content "$Dependencies\GPLv3 - GNU General Public License.txt" -raw)
    }
    elseif ($PoShEasyWinLicenseAndAboutButton.Text -eq "About PoSh-EasyWin" ) {
        $PoShEasyWinLicenseAndAboutButton.Text = "License (GPLv3)"
        $Section1AboutSubTabRichTextBox.Text   = $(Get-Content "$Dependencies\About PoSh-EasyWin.txt" -raw)
    }
}

$PoShEasyWinLicenseAndAboutButtonAdd_MouseHover = {
    Show-ToolTip -Title "Posh-EasyWin" -Icon "Info" -Message @"
+  Switch between the following:
     About PoSh-EasyWin
     GNU General Public License v3
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0Im7ye5mCRevPhmuYiFhEimC
# VUigggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU8Uh6iuB2QE37hTGod1lcGNKPFf0wDQYJKoZI
# hvcNAQEBBQAEggEAXyaqpzHCkWhuqOnT86zSp0+I73iZZPpXx+VMaAdZhSKgJ4sB
# iRNqfoqnBYkTuGr1ixeh1RQSS+kXlrHmlBYXWd6z1r7BER1yMDYWiNtw1rS8UT0b
# Lr5OA849bmfnUFGvM3gOHJxG/mgcHKMuimWx8wueFr0J2mzx+D0XNjCDHmfF4Jej
# oadfAB93gpD4gPdIkeqnlcvyxw8Ie1eReU9QE8fNx2FRRjNAWCRwTcfchr3Kfkng
# qFzvyyrbd5uNhfzS9+RUc0c/hJqatvCA3G6G94H/8XOgpNiVx1eIFj2hymlcVE+H
# fAPkKdPnyRLeOrfUl5R6tcXTgiSZCgO7kKopLA==
# SIG # End signature block
