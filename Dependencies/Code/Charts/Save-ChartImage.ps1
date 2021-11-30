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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUIPNEfbZg6vZcNBH4UUuxnYK7
# 0FSgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUuJVgYUk9/NKnqCEBzZHi8DXfU4owDQYJKoZI
# hvcNAQEBBQAEggEAPFoo9p6gQ5RpZwUT+wuKDWulUqlxTJ6IuGII6GeqlF3JYF2y
# YMvEVDC/GwBqdI9JMz0wV+wnfp/dGmxuvp1Awnh1+MRKEjzBvgbxNC9MfaV27XKQ
# WYixliIrgZRREPh+YAbpASbmvA6r4jHmz45V2snuRFEBndork2szeUFmm2j9/fPx
# psZDFYh+4DPCLV0fdLx6mRYD9Ms/FzavqHzbrlAvy9nlQoTcPa2e1Orocz5Nrhx8
# pZVuYIRh4S9OdIG7nm2GwigmcH/eDFFmGXFBOvOdzz3doAO0JJNLRC3z60foICR7
# uQjNG/Wn3JIfwD9qUa979QydOajm22CvdCt1Ug==
# SIG # End signature block
