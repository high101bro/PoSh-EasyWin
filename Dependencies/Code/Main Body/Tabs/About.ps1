
$Section3AboutTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "About  "
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { script:Minimize-MonitorJobsTab }
    imageindex = 0
}
$InformationTabControl.Controls.Add($Section3AboutTab)


$Section1AboutSubTabRichTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Text   = "$(Get-Content "$Dependencies\About PoSh-EasyWin.txt" -raw)  "
    Font   = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    Top    = $FormScale * 3
    Height = $FormScale * 329
    Left   = $FormScale * 3
    Width  = $FormScale * 742
    MultiLine  = $True
    ScrollBars = "Vertical"
    WordWrap   = $true
    ReadOnly   = $True
    BackColor  = 'White'
    ShortcutsEnabled = $true
}
$Section3AboutTab.Controls.Add($Section1AboutSubTabRichTextBox)
$Section1AboutSubTabRichTextBox.bringtofront()


$FeatureRequestReportBugButton = New-Object System.Windows.Forms.Button -Property @{
    Text   = "Request Feature / Report Bug"
    Top    = $FormScale * 305
    Left   = $FormScale * 553
    Width  = $FormScale * 175
    Height = $FormScale * 25
    Font   = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
    Add_Click = {
        $Verify = [System.Windows.Forms.MessageBox]::Show(
            "Do you want to navigate to PoSh-EasyWin's GitHub page and either request a feature or report a bug?",
            "PoSh-EasyWin - Feature Request / Report Bug",
            'YesNo',
            "Warning")
        switch ($Verify) {
            'Yes'{Start-Process "https://github.com/high101bro/PoSh-EasyWin/issues"}
            'No' {continue}
        }                    
    }
}
$Section3AboutTab.Controls.Add($FeatureRequestReportBugButton)
Apply-CommonButtonSettings -Button $FeatureRequestReportBugButton
$FeatureRequestReportBugButton.bringtofront()


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdDbKlX6fKHyYQmRsaEe9HZu3
# 82qgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUP4otHWejwqpm4qIu5o6CgBNmPckwDQYJKoZI
# hvcNAQEBBQAEggEAc8xQwH8KWsXZEMB3IUVpB6D23zhAAFC1XW3qcu+u9QeBFZ1v
# 3G+HR2hHWJ3R25h9mQ4qiKshh8dj7MWNpPxkQmWuhExnIXX2SQXQGP24XUKfTHKn
# 5MF+OOILLCkyAB1YeAQfBYNEbECaRePhsdV/pJ9ajd6IbmIhQgPLAfHcoVcjlMF0
# dmyLu+luXzLrNiC7bPtXPT1KYGvTZVR5OhI006ZS7PD5x9zSDSS9kIz1UZkCwDdG
# NKIyWTBPmpjmekU9kTRMF4riSGHc5jGjiTgT/WQ16LotktLgriT4yIIIf7i1rsLE
# 1CfoVclnGNBT6cl57p88jm9P7PjwQMKA9lZJaw==
# SIG # End signature block
