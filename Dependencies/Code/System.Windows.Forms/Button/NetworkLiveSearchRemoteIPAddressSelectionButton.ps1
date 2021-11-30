$NetworkLiveSearchRemoteIPAddressSelectionButtonAdd_Click = {
    Import-Csv "$script:EndpointTreeNodeFileSave"  | Out-GridView -Title 'PoSh-EasyWin: IP Address Selection' -OutputMode Multiple | Select-Object -Property IPv4Address | Set-Variable -Name IPAddressSelectionContents
    $IPAddressColumn = $IPAddressSelectionContents | Select-Object -ExpandProperty IPv4Address
    $IPAddressToBeScan = ""
    Foreach ($Port in $IPAddressColumn) {
        $IPAddressToBeScan += "$Port`r`n"
    }
    if ($NetworkLiveSearchRemoteIPAddressRichTextbox.Lines -eq "Enter Remote IPs; One Per Line") { $NetworkLiveSearchRemoteIPAddressRichTextbox.Text = "" }
    $NetworkLiveSearchRemoteIPAddressRichTextbox.Text += $("`r`n" + $IPAddressToBeScan)
    $NetworkLiveSearchRemoteIPAddressRichTextbox.Text  = $NetworkLiveSearchRemoteIPAddressRichTextbox.Text.Trim("")
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUfGU6kqIiU4zfm29KxdHOWbjI
# q/agggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUDTC5QKh/wwmR594wBUeS4ymsJhQwDQYJKoZI
# hvcNAQEBBQAEggEAPEj7HS31fOVUUh6quaADsdaJ9oNFiZjzMdCcCDKNN0UDgnQ4
# PLTqiGlmj+DmoN1py24uV3SqVnlSwFNcoQL6i5TqoKsRuY9x8kWXCbZqRgycBMfu
# EFPcH60DPBkXjTFkoTm1w11Se78gkJk4IQfLo0WVDHsv0QXQn3vB4Of8XwABVcH1
# Wa7fSpAkZDjtsLHBhpVbd901SDwZTpjZrn7t0lior/tCOkja5naryDkTh9ikoJvm
# BnClzdFCkFFiA6YP8V8pLMM2i085vrAzwRRLO2VuvKNtazWqgkM3oCX2tg1rZecf
# eHSOAdN1ZOOopMQ82EAYJs2NsCeKF253d6wZgg==
# SIG # End signature block
