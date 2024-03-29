####################################################################################################
# ScriptBlocks
####################################################################################################
Update-FormProgress "Statistics.ps1 - ScriptBlocks"

$StatisticsViewLogButtonAdd_MouseHover = {
    Show-ToolTip -Title "View Activity Log File" -Icon "Info" -Message @"
+  Opens the PoSh-EasyWin activity log file.
+  All activities are logged, to inlcude:
    The launch of PoSh-EasyWin and the assosciated account/privileges.
    Each queries executed against each host.
    Network enumeration scannning for hosts: IPs and Ports.
    Connectivity checks: Ping, WinRM, & RPC.
    Remote access to hosts, but not commands executed within.
"@
}

$StatisticsRefreshButtonAdd_Click = {
    $StatisticsResults = Get-PoShEasyWinStatistics
    $PoshEasyWinStatistics.text = $StatisticsResults
}

####################################################################################################
# WinForms
####################################################################################################
Update-FormProgress "Statistics.ps1 - WinForms"

$Section2StatisticsTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "Statistics  "
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 10),0,0,0)
    UseVisualStyleBackColor = $True
    ImageIndex = 2
}
$MainCenterTabControl.Controls.Add($Section2StatisticsTab)


$StatisticsResults = Get-PoShEasyWinStatistics


$StatisticsRefreshButton = New-Object System.Windows.Forms.Button -Property @{
    Text     = "Refresh"
    Location = @{ X = $FormScale * 2
                  Y = $FormScale * 5 }
    Size     = @{ Width  = $FormScale * 100
                  Height = $FormScale * 22 }
    Add_Click = $StatisticsRefreshButtonAdd_Click
}
$Section2StatisticsTab.Controls.Add($StatisticsRefreshButton)
Add-CommonButtonSettings -Button $StatisticsRefreshButton


$StatisticsViewLogButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "View Log"
    Left   = $StatisticsRefreshButton.Left + $StatisticsRefreshButton.Width + ($FormScale * 5)
    Top    = $FormScale * 5
    Width  = $FormScale * 100
    Height = $FormScale * 22
    Add_Click      = { write.exe $PewLogFile }
    Add_MouseHover = $StatisticsViewLogButtonAdd_MouseHover
}
$Section2StatisticsTab.Controls.Add($StatisticsViewLogButton)
Add-CommonButtonSettings -Button $StatisticsViewLogButton


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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkuXl8utVRmWifE84f6dMi3Gj
# AZqgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU7nOFNP9CnUtTQ5xlWUQt/mqhLnAwDQYJKoZI
# hvcNAQEBBQAEggEAWp51+c5/zSGBp1N26HM4fjD14oTLfE3JfhhVJve2jgV8vjSP
# VDwQbiZc6Ku9PQmPIRkZ5vtBzwFWTBAl6C3RB5tTljBbrv4mKxa0mQfbuG64PqFT
# TqK0f/Z+LQ9FawqurfZ5cFpZZkqIT6yEhUJUSk0BMZeDE9bq7L8y4H7hR9HqAWse
# 5nv2NtYbZFtVUHfokvw1WZ8hQyHx/tiEp6Kxgq6rUP6u0yho1ym5RoBlo9qUY1o8
# DJEMYCpV52JNR++JBfJeNkmf6d0CZC58P7m8Feef7cRjmXOlu0QaEqhVgK6GtITS
# ofpfAFZxydQ956Te7XzoB/S4VsAYI5Itx7An/g==
# SIG # End signature block
