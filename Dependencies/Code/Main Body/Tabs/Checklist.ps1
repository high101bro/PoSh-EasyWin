
$MainLeftChecklistTab = New-Object System.Windows.Forms.TabPage -Property @{
    Text                    = "Checklist"
    Font                    = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    UseVisualStyleBackColor = $True
}
if (Test-Path "$Dependencies\Checklists") { $MainLeftTabControl.Controls.Add($MainLeftChecklistTab) }


$MainLeftChecklistTabControl = New-Object System.Windows.Forms.TabControl -Property @{
    Name          = "Checklist TabControl"
    Location  = @{ X = $FormScale * 3
                   Y = $FormScale * 3 }
    Size      = @{ Width  = $FormScale * 446
                   Height = $FormScale * 557 }
    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ShowToolTips  = $True
    SelectedIndex = 0
}
$MainLeftChecklistTab.Controls.Add($MainLeftChecklistTabControl)


#-------------------------------------------------------
# Checklists Auto Create Tabs and Checkboxes from files
#-------------------------------------------------------
$ResourceChecklistFiles = Get-ChildItem "$Dependencies\Checklists"

# Iterates through the files and dynamically creates tabs and imports data
Update-FormProgress "$Dependencies\Code\Main Body\Dynamically Create Checklists.ps1"
. "$Dependencies\Code\Main Body\Dynamically Create Checklists.ps1"

# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGZxgSM/PiS8/OyDrZqj5h/6F
# EK+gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUDBNRNebqMN0z405QHcTkjurTTjgwDQYJKoZI
# hvcNAQEBBQAEggEAPsTdipVa0SpuEYX91PmVWURpP7HkpeogWw78DS1/ERQUq1kk
# onAwZR3voGu3MJ5BIeqAd0VhZ+vyKYtktnKTSNzY8I8v7ukGH9BskEKWMIly8FOK
# 2Wm+i1uT2RGIwSXlP1YjeYU2X40etgz5ehXUaZ0puaU3z1dyWhE28cte0qaeUc41
# 5gxV/McVkOoEyT3S3kHoOquaIic1WDVOwHA8vwdTjJQUefSKuuY5LTvqj6jP8LAC
# Iw5xx743zeURAX3+SuFp46ayZmUbC0503M23aTQ9RBl52AJK6MtkG6xkjzRk/yQZ
# LOlU/b6zlLXA1uzrf/DGVUED9grbYQP4o5YSRQ==
# SIG # End signature block
