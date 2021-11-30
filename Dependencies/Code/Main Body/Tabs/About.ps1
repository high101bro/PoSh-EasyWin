
$Section3AboutTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text = "About"
    Font = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
    Add_click = { script:Minimize-MonitorJobsTab }
    imageindex = 0
}
$InformationTabControl.Controls.Add($Section3AboutTab)


$Section1AboutSubTabRichTextBox = New-Object System.Windows.Forms.TextBox -Property @{
    Text   = $(Get-Content "$Dependencies\About PoSh-EasyWin.txt" -raw)
    Font   = New-Object System.Drawing.Font("Courier New",$($FormScale * 11),0,0,0)
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
    Top    = $FormScale * 300
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4l/0ElANEO+V++bza2O0ytKO
# f6egggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUiQoaLjY+2m8kEPLM8iOAxwhXPG8wDQYJKoZI
# hvcNAQEBBQAEggEAydlvryiaj6wMfbvyg7tUmarYQcJ2sLUwKsriASJYHaCdI1M/
# ICrDph4jDLF/djWhNeKpiT99pb2tofyQ85D35CIyL/elCE4L+mzwDEc9Wx48pKl8
# kGqQTW0qzYI3BKC7SfdyLV3UCSEhuDMsX6z7nlqMOyFFL/sRTGlJb3IFvsZoS5nb
# KJcxH4hFoBvs+jWJq5QATq85GurrYJoo0IpNLu8/le9UpQaxP+NridvDNp3ip/QL
# Q9pMTDBrPVg9pd0unvwnNqwKYdzDbfqh2xE6hS+ptMGjHAPvbRtxqO5NJlxZmT1l
# WWESQ+OAx3HMjrfzerh1NTjZ0gm5YkBH8In/kg==
# SIG # End signature block
