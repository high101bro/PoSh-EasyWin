# Deprecated
# Processes Reference
# $Section1ProcessesTab = New-Object System.Windows.Forms.TabPage -Property @{
#     Text                    = "Processes  "
#     Name                    = "Processes Tab"
#     UseVisualStyleBackColor = $True
#     Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
#     ImageIndex = 1
# }
# if (Test-Path "$Dependencies\Process Info") { $MainLeftTabControl.Controls.Add($Section1ProcessesTab) }


# $MainLeftProcessesTabControl = New-Object System.Windows.Forms.TabControl -Property @{
#     Name     = "Processes TabControl"
#     Location = @{ X = $FormScale * 3
#                   Y = $FormScale * 3 }
#     Size     = @{ Width  = $FormScale * 446
#                   Height = $FormScale * 557 }
#     Appearance = [System.Windows.Forms.TabAppearance]::Buttons
#     Hottrack = $true
#     Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,2,1)
#     ShowToolTips  = $True
#     SelectedIndex = 0
# }
# $Section1ProcessesTab.Controls.Add($MainLeftProcessesTabControl)

# Deprecated
# # Dynamically generates tabs
# # Iterates through the files and dynamically creates tabs and imports data
# Load-Code "$Dependencies\Code\Main Body\Dynamically Create Process Info.ps1"
# . "$Dependencies\Code\Main Body\Dynamically Create Process Info.ps1"
# $script:ProgressBarFormProgressBar.Value += 1
# $script:ProgressBarSelectionForm.Refresh()

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUF8M05dhg1JiJUrNnvhtcV8wF
# xnWgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUGO4+8MG5cIyte9CQFsf8x6WO0EUwDQYJKoZI
# hvcNAQEBBQAEggEAM+Iel9KObG8gJ0/xhE5fzdz6VbGM+k/GHu5sD1g2B/USJ6Qn
# LZbKHMG2FjluYrPJ3F2Zr71lVRPqFnbUF/8TG6xgMiH6//q/NpIN64O+p7XyCw+r
# J5ycphguyQJl9mfMLU7EIsqiVOBM8TyO4AV69mLXvlHPvTWCs77brJRyy2C7ufBf
# ylXIx2dJykumBqFEhMaHUudQgqyc5/clE9Nwn56pD/jPw/Rkwudsu9STjmvLGmDL
# Omfs0ONk/0btNwEb+wJn9icn/jcgi1cAPAKyv9wXdpci4KLVakynscgxJi8p7xDN
# 6sSOFBe3c3erNYqAhLtNGBMllSbQw746XxDrRg==
# SIG # End signature block
