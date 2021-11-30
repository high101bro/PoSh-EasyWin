$script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseEnter = {
    if ($this.text -eq "Enter IP, Range, or Subnet") {
        $this.text = ""
    }
}

$script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseLeave = {
    if ($this.text -eq "") {
        $this.text = "Enter IP, Range, or Subnet"
    }
}

$script:ActionsTabQuarantineEndpointAccessFromIPSubnetTextbox_MouseHover = {
    Show-ToolTip -Title "Access Endpoints from IP or Subnet" -Icon "Info" -Message @"
+  This textbox identifies the host(s) that can access the quarantined endpoint(s).
+  CAUTION! If there's an error in the entry, the endpoint(s) may become completely inaccessible over the network.
+  Use the following list as guidelines to fill the textbox:
     -  Single IPv4 Address: 1.2.3.4
     -  Single IPv6 Address: fe80::1
     -  IPv4 Subnet (by network bit count): 1.2.3.4/24
     -  IPv6 Subnet (by network bit count): fe80::1/48
     -  IPv4 Subnet (by network mask): 1.2.3.4/255.255.255.0
     -  IPv4 Range: 1.2.3.4-1.2.3.7
     -  IPv6 Range: fe80::1-fe80::9
     -  Keyword: Any, LocalSubnet, DNS, DHCP, WINS, DefaultGateway, Internet, Intranet, IntranetRemoteAccess,
     PlayToDevice. NOTE: Keywords can be restricted to IPv4 or IPv6 by appending a 4 or 6 (for example, keyword
     "LocalSubnet4" means that all local IPv4 addresses are matching this rule).
"@
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbhVI45bbE6w+wxlrc6cYjVM+
# o8GgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU34bvWmb5zBKUT+8TXIVKKC4YvzYwDQYJKoZI
# hvcNAQEBBQAEggEANxm4t/UpEtXgnuVMGgmBN5YrYI2XvP6SVSDlMeXt5qc7eZWQ
# O0dx+x5vI4O69osk+NF0Qpb+jZyQp7UYU41e2/YhG01MZaLBx3CrDjsJu1tHb2oA
# WbgFP1fjnrPsURfGlGlCqXOHL2nnnieiEBC2rb/XPQSqzsV9gKfu8MBhkjLFoRe0
# Asv896wWMCz00nq9Wjx00BR+HiZ8R/iPLfAfXUeEJOffobP/s60iyJ2izDM4YYi9
# 99vIInXdL2WBhTsQzmlHfNN3s4pn4yMVkzdbqs8KKBL9Yo3FD4Gqrf1Zh6WKDSE+
# PEkvzjFL6yZ6b7zof9ZrI/YgCMc1g8tj5NZycg==
# SIG # End signature block
