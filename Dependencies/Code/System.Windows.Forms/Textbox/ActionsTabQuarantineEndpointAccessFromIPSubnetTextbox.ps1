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
# o8GgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU34bvWmb5zBKUT+8TXIVKKC4YvzYwDQYJKoZI
# hvcNAQEBBQAEggEAHP7HvpwF20FFvvZzawAuTlIHaEvYKz/NsVKXP4mXDws19soq
# 3YGIfHUJWFiAxToZdzI7VBNYSgEuAyBqZ3bgD4YHfq2oj55x26DE8C7P1li64bRo
# IoO4dI477G0vruSmnioSLEOdmA3l+dGDDMsjWznoalnfvcp7I7orfEktij1QNbsW
# KDLO2okhuen9/Z6uCh3+yp5p8Jo2eNac89KUundy0YOZJnw6jIKsGnSpUg4WoEqC
# ZbAUPIlU+WNtt7AaL49zzuvG6vGL1v7DAw1660AlYazYrwSsQXzXvTyPLYSkCk5m
# Y9pYdh+sPQuBNrm7IGDPMeao2DZ5UTgZlbvZTg==
# SIG # End signature block
