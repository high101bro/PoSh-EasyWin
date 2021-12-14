
function Apply-CommonButtonSettings {
    param($Button)
    $Button.Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    $Button.ForeColor = "Black"
    $Button.Flatstyle = 'Flat'
    $Button.UseVisualStyleBackColor = $true
    #$Button.FlatAppearance.BorderSize        = 1
    $Button.BackColor = 'LightGray'
    $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::Gray
    $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DimGray
    $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::DarkGray
    <#
    $Button.BackColor = 'LightSkyBlue'
    $Button.FlatAppearance.BorderColor        = [System.Drawing.Color]::Gray
    $Button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::DodgerBlue
    $Button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::PowderBlue

    $contextMenuStrip1 = New-Object System.Windows.Forms.ContextMenuStrip
    $contextMenuStrip1.Items.Add("Item 1")
    $contextMenuStrip1.Items.Add("Item 2")
    $Button.ShortcutsEnabled = $false
    $Button.ContextMenuStrip = $contextMenuStrip1
    #>
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUwuQh7aqa7mA3V9YYoF2pVsgD
# N7qgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUbDrel7AH85JSDztc0/VEoyR63EUwDQYJKoZI
# hvcNAQEBBQAEggEACtCNM53sBapwneCEDP5B12FlYlztJrtFUOCmquqnQcFa4IU9
# QRfoT+/zLAyd/VupXLyvy2enNpsE9yIvqpo4CxdfzvgpHguEJO3WuNHkzaPHNnO9
# E+LXuC7XhHDfG6ag7qpWoo4e9VfPW39CN1w7fhkJNa80F+537vTvlcwdZIrmaDmv
# zXPpxVDa7o+9TRkFkZpifclM4NmPEllMJR9I1A06yWSsf1uMbBLa9R1AxgY1wROs
# y1TrTsgsMs99PehtBd7OQz3V0Pc+YeenC9WaO7wUlK3W0TPdHoLSCgXQ/tCrSxvz
# ROsbshkhoyWrXeVFttgUhkb3M5oJHp79o6QWmw==
# SIG # End signature block
