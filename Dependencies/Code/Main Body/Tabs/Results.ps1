
$Section3ResultsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Info / Results  "
    Name = "Results Tab"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { script:Minimize-MonitorJobsTab }
    ImageIndex = 1
}
$InformationTabControl.Controls.Add($Section3ResultsTab)


Load-Code "$Dependencies\Code\System.Windows.Forms\Button\ResultsTabOpNotesAddButton.ps1"
. "$Dependencies\Code\System.Windows.Forms\Button\ResultsTabOpNotesAddButton.ps1"
$ResultsTabOpNotesAddButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Add Selected To OpNotes"
    Top    = $FormScale * 305
    Left   = $FormScale * 553
    Width  = $FormScale * 175
    Height = $FormScale * 25
    Add_Click = $ResultsTabOpNotesAddButtonAdd_Click
    Add_MouseHover = $ResultsTabOpNotesAddButtonAdd_MouseHover
    Font      = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
}
$Section3ResultsTab.Controls.Add($ResultsTabOpNotesAddButton)
Apply-CommonButtonSettings -Button $ResultsTabOpNotesAddButton


$ResultsListBox = New-Object System.Windows.Forms.ListBox -Property @{
    Name   = "ResultsListBox"
    Left   = $FormScale * 3
    Top    = $FormScale * 3
    Height = $FormScale * 329
    Width  = $FormScale * 742
    FormattingEnabled   = $True
    SelectionMode       = 'MultiExtended'
    ScrollAlwaysVisible = $True
    AutoSize            = $False
    Font                = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
}
$Section3ResultsTab.Controls.Add($ResultsListBox)



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0wymnslTbzvWiQb/9zGQWUzc
# 8d+gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUnK4rj7HjJcDbh/FNH22t0v4pOWwwDQYJKoZI
# hvcNAQEBBQAEggEAVSsHZ8Z4Y7kEESV6K7gkTvx6FiiXOBtMZdgI9krWzeInBXd/
# 5NZq18k28C03ByDF9l3TLjcuF8+yZlztqbtO6dMBUvQCBbHnU0RIeXiQf2o9lzKv
# YrT6xjek9uU/nb4bvHrrFBt+XodEm6qP3iD9YDvmcHeQBVHDJfdD446HIoTW8T2q
# FmkHiWEoHGt5p6sGbf4n1I8NJ4OUVQB9JpioLf/UbxXZqo6FtPVhp7/BJkdZonKZ
# 2RSggz8B8OHJVK76LNxY27q52ANlwDYOuv8PhIcuKYtytrNW+vUGBP2N1jM8syfj
# I+n+uyyc4QTX7hbZE38U2D4JMiQYNYdz/FB/MQ==
# SIG # End signature block
