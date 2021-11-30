function ComputerNodeSelectedMoreThanOne {
    param($Message)
    [system.media.systemsounds]::Exclamation.play()
    [System.Windows.MessageBox]::Show("Too many hostname/IPs selected`r`nMake sure to checkbox only one hostname/IP`r`nSelecting a Category will not allow you to connect to multiple hosts","$($Message):  Error")

<#
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("$($Message):  Error")
    #Removed For Testing#$ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Add("Error:  Too many hostname/IPs selected")
    $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
    $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")
#>
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUVGeTbYnG8/4cwjTdVnCmwzRo
# 6SugggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUJB9xObqXWSjtxB7jfCWscQsld7EwDQYJKoZI
# hvcNAQEBBQAEggEAS3T6LDD4rrBmzd54dHIKyj0ITPfgOdh5uiOU+gPBbS6QG1WR
# 8FKSMqP+OD5yDfhM7UsaEj3pWvG/lPjZryOLRJXFiGCIJK9wlVDV3GgiiZsqls9L
# Pt+/0ZaxDtyDBk13MiYliKonyuOeu/h35Uf5O2tfnbKmIYu6bk82e4MoOUqHutjJ
# 2K1XfseVMZJcx5CDqsWtvbGSEgtqc88EYB7rJEifueru2qhSMvE3Vnxl2RdbWxc6
# V0zafVvEq9fTB37iRNTk9uVTVruXggjb7xpFFYTMl+tSIzijGVoPm7KD9b2JRIhd
# 5p7GUSD3A+LJ6f5L0ztCQttza3BQhqgC/32O9w==
# SIG # End signature block
