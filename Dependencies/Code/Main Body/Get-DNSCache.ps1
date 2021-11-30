function Get-DNSCache {
    param(
        $NetworkConnectionSearchDNSCache,
        $Regex
    )
    $DNSQueryCache = Get-DnsClientCache
    $DNSQueryFoundList = @()
    foreach ($DNSQuery in $NetworkConnectionSearchDNSCache) {
        if ($Regex -eq $true){
            $DNSQueryFoundList += $DNSQueryCache | Where-Object {
                ($_.name -match $DNSQuery) -or ($_.entry -match $DNSQuery) -or ($_.data -match $DNSQuery)
            }
        }
        if ($Regex -eq $false){
            $DNSQueryFoundList += $DNSQueryCache | Where-Object {
                ($_.name -eq $DNSQuery) -or ($_.entry -eq $DNSQuery) -or ($_.data -eq $DNSQuery)
            }
        }
    }
    $DNSQueryFoundList | Select-Object -Property PSComputerName, Entry, Name, Data, Type, Status, Section, TTL, DataLength
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUJd5GmwZByufL1uSApM6MkGNe
# wuCgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUoiPHDin3eV4U2vBCfgVJ9rzLdZcwDQYJKoZI
# hvcNAQEBBQAEggEAFOYMz3JBRBLtBLM/GmaWNmrigWQUy1BAIERd1uURSQmHUxrq
# uhJBDponSheeIITdi8mxBHIM7/48g9kBtfIQn+asdN/8tC5kRFFUdsx7mF/+d8vh
# muqaOOALFGvRd1RszbsrVX57L65jo80Nh8VS3GB8FYGlFtClYc0yw8budY4fB7eL
# WU28hgdIrWIAYvr+/gdqXC79Tq5i/K2P+oY9oYRfluKSk7AElNZ0RSrzXdzVNFl4
# +wjgNOwQ03TgFggKmmeV2gVdCf1pUaIBCLq9eHws5GdnYFlxUCnMJnj1z0YkmaMv
# uZJMavDoWYZ0fDvOHtogvvoWGpXiSc1IY44LKQ==
# SIG # End signature block
