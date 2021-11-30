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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUkWO+qh8Q8l55IUntGEQPDoN7
# LEOgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUawErozLfAzHzN1whattwV6RfCP0wDQYJKoZI
# hvcNAQEBBQAEggEAXAnWqDMEAAJnz1eQQ4Vj2a3ga4UeOBnYpBPc9lo7Wn2CWdr+
# NHxqVKKBQl43ENBLrVXONA817eV8QS7sNYMo5l3s/I9Va2pCzBf0LylqDborti7Z
# N1j8bAxbAGzz40RMbTa+hsbsjE8NxMzMPc81AHu0mSxq0Y+1ZjLc0kSx4uLKcsO3
# clnl2le9QdrI2OmN+OziUbtdj7PzqjqVzODPYQ8ewZQMRsHVofeSusKXslSF1YTi
# dDNqMp9M/vfMkQvBzdFsFOSv5yk+KsiH6i5HprFcpRX810zS8rhcupk02ItVwCIx
# mohVH4us7Nvut0PIw/e6dm2WYhzktmdr/WAl5Q==
# SIG # End signature block
