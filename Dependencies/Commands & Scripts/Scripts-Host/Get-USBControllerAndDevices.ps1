<#
Antecedent: A CIM_USBController representing the Universal Serial Bus (USB) controller associated with this device.
Dependent: Describes the logical device connected to the Universal Serial Bus (USB) controller.
#>
Get-WmiObject -Class Win32_USBControllerDevice | Foreach-Object {
    $Dependent  = [wmi]($_.Dependent)
    $Antecedent = [wmi]($_.Antecedent)

    [PSCustomObject]@{
        USBDeviceName             = $Dependent.Name
        USBDeviceManufacturer     = $Dependent.Manufacturer
        USBDeviceService          = $Dependent.Service
        USBDeviceStatus           = $Dependent.Status
        USBDevicePNPDeviceID      = $Dependent.PNPDeviceID
        USBDeviceHardwareID       = $Dependent.HardwareID
        USBDeviceInstallDate      = $Dependent.InstallDate
        USBControllerName         = $Antecedent.Name
        USBControllerManufacturer = $Antecedent.Manufacturer
        USBControllerStatus       = $Antecedent.Status
        USBControllerPNPDeviceID  = $Antecedent.PNPDeviceID
        USBControllerInstallDate  = $Antecedent.InstallDate
    }
} `
| Select-Object -Property PSComputerName, * `
| Sort-Object Description,DeviceID





# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUd+WFRLRo0W8q8QTAQaoTNnRo
# iD2gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU0tNooMW+l1p03OrBpUB8IfE+ungwDQYJKoZI
# hvcNAQEBBQAEggEAViSSLiwPyBw3gkHGXYww5blauxuNu4MvPiJ9vg4h7jfNbVMB
# qASnITZg4JgfBxKVotiiAo2TduzcD7cOLm4alUhbICHzgV1VshaU57QjhaHQuySK
# QB9yW4oy/ovoCReoS48Su/foMyKa1H3T3K+0K2CK5XcbqEZNJ18h2y7g1il8pF/t
# kItxC9OM/q12wp4geiVzCiukiI58Wf1Y3ZaMt8tnYzhIVspYLTedUzLnJ/t5ROX1
# +FWGH42Z5e26FeYJZS8IduGQ2zaQ0c19z7C8ng9b9Ws0cOy6uq5RHlrpZzp3L1sh
# 8xNFJkNoyKVl93O1Fb2ctdN/2bFI7iaMBqxqOA==
# SIG # End signature block
