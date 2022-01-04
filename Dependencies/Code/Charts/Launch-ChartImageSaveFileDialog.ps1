Function Launch-ChartImageSaveFileDialog {
    $SaveFileDlg = New-Object System.Windows.Forms.SaveFileDialog
    $SaveFileDlg.FileName   =  "{0:yyyy-MM-dd @ HHmm.ss} - {1}" -f (Get-Date),"PoSh-EasyWin Chart"
    $SaveFileDlg.DefaultExt = 'PNG'
    $SaveFileDlg.filter = "PNG (*.png)|*.png|JPEG (*.jpeg)|*.jpeg|BMP (*.bmp)|*.bmp|GIF (*.gif)|*.gif|TIFF (*.tiff)|*.tiff|All files (*.*)|*.*"
    $return = $SaveFileDlg.ShowDialog()
    If ($Return -eq 'OK') {
        [pscustomobject]@{
            FileName  = $SaveFileDlg.FileName
            Extension = $SaveFileDlg.FileName -replace '.*\.(.*)','$1'
        }
    }
}












# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4t8Ypgrt7r40EO+Xc1MKFpiN
# 3TagggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUd0dXNGPWOJb++7uI9QpyrIGtvSUwDQYJKoZI
# hvcNAQEBBQAEggEAWU+ztyH+cm1Jn8/if85lfE4n6Uc3pD69GviMNSjNYp5KSmww
# K/LBsPaPuHQ8aHep0qvno0BFrEOtLAKkKS2X/QOOGRRSrGfAXBWWWVOR2ghyAh+j
# 0XMCjCvUyJv2X+dUar1XDRU7n2ep++zkW5ZGjoFVmLQAdpKoFkpj+0Dygej7QQr9
# U3rvNbHbA+5fg6UffwLBtfxMVom/05Ufy8Zt7phRruSkNXa61uwMLmCIPYoXT/3j
# FcwsdDGYQ5Ejg4JtxOFYuI50vwrQQb+pk5OuEYdZf/GSMKNIFgn/+nx0sYT1lcYo
# AG4FWsofNAdtbDPqvB2LNI4FN7StHCli+AT7vg==
# SIG # End signature block
