
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSMqHaGqKhqL/ZCueMu901G9b
# VjCgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUR0r5RVQkBiESgYNIapoRFGMphMswDQYJKoZI
# hvcNAQEBBQAEggEAEWVCjpGGMFU6yrszhMf1Y/U3H/JQiHsgvRZiBwJ/i3Ox3bUD
# 4arZgnO3CZ+G50Eujn0nyl8nGQcINx7Xnhp1t7C0qVdZoA/aaYfE5j/gmrSosoKG
# +oT3ue8wjlyUY6RDuK5O6CslAfK0r07YXjrbdBp9KK5hbsBJCTzva2tx2r1uHMhj
# n2uqvyPa+hOa4R7XUX9ELcJ4XQNYWMvbMrHGdeFJYREnGzicYxuyegaUvaQ1nZ0j
# WLhqZ3nUNTMmIT2gaBdQbto70dDWFGuA3lunkC/eByM3qWnXHrmzBC1IMPwJ0FmY
# Q0bUQ5IcQlsfHBMZNlLOUywsNih3xx3fInMC1Q==
# SIG # End signature block
