Function Save-ChartImage {
    param($Chart,$Title)
    $MessageBox = [System.Windows.Forms.MessageBox]::Show("Do you want scale up (x2) the chart?`nThe chart will auto-optimize.","Save Chart",[System.Windows.Forms.MessageBoxButtons]::YesNo)
     switch ($MessageBox){
        "Yes" {
            $Result = Launch-ChartImageSaveFileDialog

            If ($Result) {
                $OriginalWidth  = $Chart.Size.Width
                $OriginalHeight = $Chart.Size.Height
                $Chart.Width  = $OriginalWidth * 2
                $Chart.Height = $OriginalHeight * 2
                $Title.Font   = New-Object System.Drawing.Font @('Microsoft Sans Serif','22', [System.Drawing.FontStyle]::Bold)

                $Chart.SaveImage($Result.FileName, $Result.Extension)

                $Chart.Width  = $OriginalWidth
                $Chart.Height = $OriginalHeight
                $Title.Font   = New-Object System.Drawing.Font @('Microsoft Sans Serif','10', [System.Drawing.FontStyle]::Bold)

            }
        }
        "No" {
            $Result = Launch-ChartImageSaveFileDialog

            If ($Result) {
                $Chart.SaveImage($Result.FileName, $Result.Extension)
            }
        }
    }
}












# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5p0+J8SFvq6MH3mfQ+3VAFrl
# Y6egggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUW5t4hvk1p+zVxECJvAJiW7WXk0gwDQYJKoZI
# hvcNAQEBBQAEggEABU0G3fCfY1dXtVg+u89Dw68dR8gyDqjQS17VuKST2nmFBMd0
# TBJpPbdVele+Uai9ddIUvvausEaM3RnQe3Z5qohhFZcAc1Qew5FA08BPgTSyB1fV
# Jda+rWGqfY0GrTjuWDao848S32qyVEgIctmLa7aSKH9tlycpJsHmo7ZjdNJpwKHj
# zCzYE0wVvx3g11422AiLMRnuRCuKMdiS6078eBe1sEcUE7ratZnTedpa1kEX7sIY
# Ay1vKdpSFPLaqxxEkZQ/FMQUOlZfjUFEAkgAQaovJLITvcWR/6gyssQ/n0IJY2gZ
# 8wW2RGQ9j00XwhFfghL5wk/Ej2xoE4NhuTj6pQ==
# SIG # End signature block
