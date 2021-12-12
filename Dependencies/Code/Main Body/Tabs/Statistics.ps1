
$Section2StatisticsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Statistics  "
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 2
}
$MainCenterTabControl.Controls.Add($Section2StatisticsTab)

# Gets various statistics on PoSh-EasyWin such as number of queries and computer treenodes selected, and
# the number number of csv files and data storage consumed
Load-Code "$Dependencies\Code\Execution\Get-PoShEasyWinStatistics.ps1"
. "$Dependencies\Code\Execution\Get-PoShEasyWinStatistics.ps1"
$StatisticsResults = Get-PoShEasyWinStatistics


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\StatisticsRefreshButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\StatisticsRefreshButton.ps1"
$StatisticsRefreshButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Refresh"
    Location = @{ X = $FormScale * 2
                  Y = $FormScale * 5 }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = $StatisticsRefreshButtonAdd_Click
}
$Section2StatisticsTab.Controls.Add($StatisticsRefreshButton)
Apply-CommonButtonSettings -Button $StatisticsRefreshButton


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\StatisticsViewLogButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\StatisticsViewLogButton.ps1"
$StatisticsViewLogButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "View Log"
    Left   = $StatisticsRefreshButton.Left + $StatisticsRefreshButton.Width + ($FormScale * 5)
    Top    = $FormScale * 5
    Width  = $FormScale * 100
    Height = $FormScale * 22
    Add_Click      = $StatisticsViewLogButtonAdd_Click
    Add_MouseHover = $StatisticsViewLogButtonAdd_MouseHover
}
$Section2StatisticsTab.Controls.Add($StatisticsViewLogButton)
Apply-CommonButtonSettings -Button $StatisticsViewLogButton


$PoshEasyWinStatistics = New-Object System.Windows.Forms.Textbox -Property @{
    Text   = $StatisticsResults
    Left   = $FormScale * 3
    Top    = $FormScale * 32
    Height = $FormScale * 215
    Width  = $FormScale * 590
    Font   = New-Object System.Drawing.Font("Courier new",$($FormScale * 11),0,0,0)
    Multiline  = $true
    Enabled    = $true
}
$Section2StatisticsTab.Controls.Add($PoshEasyWinStatistics)

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUEgMQ9KQnv3fv8UtZONY4j4wn
# +ZigggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUjY9Pv7MSHw8KODkb9pDXOJXIQXYwDQYJKoZI
# hvcNAQEBBQAEggEAuU2Gjn0nJ/HmaiNd6UGLIWA+DiFYC1MxLBOu3Ovcpc7UcrOg
# 0hrB5xj2YtZlm46pwtXIvr9hK6WOkkiZIZNNUr9eBVGAkw2sLZgAJG7zS30UBtaH
# AAtX9e1CisMnx11SiakZzohQf0r/weNQuHDoHho7HTW1QkzQyBOrxclWgqsdWWKu
# 1zkQu+uN4Ll+NPAHV2vwBawLmm5vcAfojSWpY0koXXxtD48XuNIoK45AmTBY7k6u
# xBzwfGCOl4zT+FIWm0ULAb+fnhDz7gDoEZdC9ZwfuS9pvYuIpctCgEgiZ9DJ2l8b
# iDDNokDra6OuFhb30lFwCZaG86E/Sdxu/auBAw==
# SIG # End signature block
