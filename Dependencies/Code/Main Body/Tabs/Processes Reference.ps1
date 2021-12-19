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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUGxbZ19QI0d/RtGIfl9wBYQ29
# ncagggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUnMiymFGjF9QYl46IQIdLYE7VrmEwDQYJKoZI
# hvcNAQEBBQAEggEADwVheBvXKyR9dhBt8B50X1y+aupjRe/ukJJ5kDiUH8NJ0c6Y
# HDTJUkArzkUveVq+yIMcdD+vk6q/oe9JuWjlkZgTfWo/x4iwlRQnU9iKwZ6soxke
# pNRuBWKmNGDQptYmSxlKfgDnBfPDxnB3wDQaP4yfYlNhWjuCeOleoG/eElrx4MTk
# /mc+5/BnbRVFu/KZ0Eg5w8OJX7dGRths3Db0AClW9lJn3Qlzlr9fLKbklXpTI0Jg
# CBbvhnksNx2Fp2WjEpRxCzti5Gi4vOgcsbzZsTkXNrOvReuTQzki9u6wvd+rublC
# TkDy2DSnSv1yD246Uv66f9/HXf+oTSuLh6PLzQ==
# SIG # End signature block
