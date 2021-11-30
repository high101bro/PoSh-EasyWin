
$MainLeftInfoTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Info"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 4
}
$MainLeftTabControl.Controls.Add($MainLeftInfoTab)


$MainLeftInfoTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 446
                  Height = $FormScale * 557 }
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$MainLeftInfoTab.Controls.Add($MainLeftInfoTabControl)


$ResourceFiles = Get-ChildItem "$Dependencies\About"


# Iterates through the files and dynamically creates tabs and imports data
foreach ($File in $ResourceFiles) {

    $Section1AboutSubTab = New-Object System.Windows.Forms.TabPage -Property @{
        Text                    = $File.BaseName
        UseVisualStyleBackColor = $True
        Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    $MainLeftInfoTabControl.Controls.Add($Section1AboutSubTab)


    $TabContents = Get-Content -Path $File.FullName -Force | ForEach-Object {$_ + "`r`n"}
    $Section1AboutSubTabTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Text       = "$TabContents"
        Name       = "$file"
        Location = @{ X = $FormScale * -2
                      Y = $FormScale * -2 }
        Size     = @{ Width  = $FormScale * 442
                      Height = $FormScale * 536 }
        MultiLine  = $True
        ScrollBars = "Vertical"
        Font       = New-Object System.Drawing.Font("Courier New",($FormScale * 9),0,0,0)
    }
    $Section1AboutSubTab.Controls.Add($Section1AboutSubTabTextBox)
}
# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0wdED1hL0MKyX+Pm8wlmmWKR
# yh+gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUKJiRNE32hGyBrE5rbyb1JALi/rUwDQYJKoZI
# hvcNAQEBBQAEggEADcyjMNMKaYmOuDMEkbb9XPQwS5CA6Klrm9FeO+BpTMf5lRSq
# BkkTJ6kN9F8zP0RgXr1UxHJvLLhJFB1rrPDnS/Ryv/xFV1BYw0A0RAPTOy5zuOe+
# hyt2MtJDRXLnnfU9m5BooycjjTo0LdV6BmmL+HgmeD7N2brLuPpk3hyEy52cdS4Q
# 0WBGOw54tt/LgYcx0jL+zzfFxZbv3WXNtjK5TMJ4Vs/kUCUXhM90G10JmikQI40w
# HLSoKDGrJEtRydTXJCZbt4R4ozGh2ocLT/UAI4Q9uPpxS4Km+973GZ3e86NovTIJ
# JVexBGZEH11tAasMMeeOpgzttOBzDhWie5REMw==
# SIG # End signature block
