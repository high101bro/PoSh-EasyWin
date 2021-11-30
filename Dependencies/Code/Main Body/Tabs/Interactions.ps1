
$Section1InteractionsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text     = "Interactions"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 0 }
    Size     = @{ Width  = $FormScale * 450
                  Height = $FormScale * 25 }
    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 1
}
$MainLeftTabControl.Controls.Add($Section1InteractionsTab)


$MainLeftSection1InteractionsTabControlImageList = New-Object System.Windows.Forms.ImageList -Property @{
    ImageSize = @{
        Width  = $FormScale * 16
        Height = $FormScale * 16
    }
}
# Index 0 = Main
$MainLeftSection1InteractionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Muliple-Endpoints.png"))
# Index 1 = Options
$MainLeftSection1InteractionsTabControlImageList.Images.Add([System.Drawing.Image]::FromFile("$Dependencies\Images\Icons\Executable.png"))


$MainLeftSection1InteractionsTabTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name     = "Interactions TabControl"
    Location = @{ X = $FormScale * 3
                  Y = $FormScale * 3 }
    Size     = @{ Width  = $FormScale * 446
                  Height = $FormScale * 557 }
    ShowToolTips  = $True
    SelectedIndex = 0
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ImageList = $MainLeftSection1InteractionsTabControlImageList
}
$Section1InteractionsTab.Controls.Add($MainLeftSection1InteractionsTabTabControl)


Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Interactions Multi-Endpoint Actions.ps1"
. "$Dependencies\Code\Main Body\Tabs\Interactions Multi-Endpoint Actions.ps1"
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()


Update-FormProgress "$Dependencies\Code\Main Body\Tabs\Interactions Executables.ps1"
. "$Dependencies\Code\Main Body\Tabs\Interactions Executables.ps1"
$script:ProgressBarFormProgressBar.Value += 1
$script:ProgressBarSelectionForm.Refresh()

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZB4msluMuA0FsV5W0rgLDgad
# IaKgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUgjzlZkqIWb3Q5P4yJzqyYDT90h8wDQYJKoZI
# hvcNAQEBBQAEggEAQPT4CpplVeeieHAXME7hx+3wINI9x3fZJj8C57M/Nsh8IBCL
# fiHuK9RuFo2z4PT4VmaFWUWMqPkiDpbnLIpwwDAEOuFijcY0ZmSSRehmTo77Htg3
# T2IQUQvo+AiiB87UCcuxdfn34uJPDw52S3AuYW/yzxAxk/8KV4KHWcgE7fCHwAnV
# tuVqpcHUxuPHYqY4EFJSKkQJqnU1jbN4npEr4O9Tp9ov5QcZVsGL5MujRPULL4he
# e4KAifjGpVAHq1dmc5jfl7Z0azBFf3xdJ3yA9slCHcKArzRo500wZpJXQpJdnS0n
# gzAca/UMUxc+kmkuTvbgBTh4PDXOV2Cvk39lEQ==
# SIG # End signature block
