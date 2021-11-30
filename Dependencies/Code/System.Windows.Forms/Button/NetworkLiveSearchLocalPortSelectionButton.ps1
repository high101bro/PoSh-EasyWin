$NetworkLiveSearchLocalPortSelectionButtonAdd_Click = {
    Import-Csv "$Dependencies\Ports, Protocols, and Services.csv" | Out-GridView -Title 'PoSh-EasyWin: Port Selection' -OutputMode Multiple | Select-Object -Property Port | Set-Variable -Name PortManualEntrySelectionContents
    $PortsColumn = $PortManualEntrySelectionContents | Select-Object -ExpandProperty Port
    $PortsToBeScan = ""
    Foreach ($Port in $PortsColumn) {
        $PortsToBeScan += "$Port`r`n"
    }
    if ($NetworkLiveSearchLocalPortRichTextbox.Lines -eq "Enter Local Ports; One Per Line") { $NetworkLiveSearchLocalPortRichTextbox.Text = "" }
    $NetworkLiveSearchLocalPortRichTextbox.Text += $("`r`n" + $PortsToBeScan)
    $NetworkLiveSearchLocalPortRichTextbox.Text  = $NetworkLiveSearchLocalPortRichTextbox.Text.Trim("")
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyikRMrdPb8a3gihRJQfIwI2w
# fLagggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUA7pj81NipB1A1yDeCiF91DP0uHYwDQYJKoZI
# hvcNAQEBBQAEggEApj1tj5QP8N4a0k/GsUsM1dDdV9LONqr/wSyVcO73/zDzGSib
# wGxmoiEVuph9hLbaeyKTzuxh0athTuoQZSdToPmF3MtB4Uip8OK8GpdEpsF4SJC8
# Crk/gc+zlKCE6Q0fsQos/a3tsmMLqeXRM9hXX8Wj/FjYKqyNVUQy1kYLXfSh7hDs
# R5bvN5UUv8iQs47qMuuE2TCaKcd4Bvzh8rgl1WPR0MKsV756gCvvDJ3CujunvpbA
# JzEcSAC3wCWKjX2tJdrhZw6Ph0gW4b732NKr/iQfoVxPyQbK0q3uUSYsH95lLVrL
# q86uHL8SmPz24+WOjqUp5hJLRqUpqvZ/aLodQw==
# SIG # End signature block
