$VMwareDetected   = $False
$VMNetworkAdapter = $(Get-WmiObject Win32_NetworkAdapter -Filter 'Manufacturer LIKE "%VMware%" OR Name LIKE "%VMware%"')
$VMBios           = $(Get-WmiObject Win32_BIOS -Filter 'SerialNumber LIKE "%VMware%"')
$VMWareService    = $(Get-Service | Where-Object {$_.Name -match "vmware" -and $_.Status -eq 'Running'} | Select-Object -ExpandProperty Name)
$VMWareProcess    = $(Get-Process | Where-Object Name -match "vmware" | Select-Object -ExpandProperty Name)
$VMToolsProcess   = $(Get-Process | Where-Object Name -match "vmtoolsd" | Select-Object -ExpandProperty Name)
if($VMNetworkAdapter -or $VMBios -or $VMToolsProcess) {
    $VMwareDetected = $True
}
[PSCustomObject]@{
    PSComputerName   = $env:COMPUTERNAME
    Name             = 'VMWare Detection'
    VMWareDetected   = $VMwareDetected
    VMNetworkAdapter = $VMNetworkAdapter
    VMBIOS           = $VMBIOS
    VMWareService    = $VMWareService
    VMWareProcess    = $VMWareProcess
    VMToolsProcess   = $VMToolsProcess
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUBGiePB6yuF0KX0mqpUWmhqV3
# CTegggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQURCJ4iBjz8CN22RtLMzsgKf0Qk80wDQYJKoZI
# hvcNAQEBBQAEggEAURhZzNg1cLIe2tEAWA5nHw3AzNl4yxHGXijnId48Y9ODq23S
# 18xoQJBfAtm+AIudo+O9WWYI49K4wy1HdLPkGae480xK61cpq9a0Hy8wvwKpw8IW
# W9fTQDrLQczUKQnHs06B+myfeV6Mr3SAl4jA5JoV5fFo6qGA94f2zAlUp535QIDT
# pQqGUlAH1/SXsuqrRcVgkYCPZJLUAxRHCzvfT8gbKge4d6XIRZp+nK68jWjje0O6
# UXfb6JoEhDbZZRF4ztGvv6z7mz+dedUk/6eXBnh0Ym+JNO+Xoli9lx4ByVfXiavl
# /yQsDeL5+mzIla+/bBv5oXx56qp77kVcdU9G/Q==
# SIG # End signature block
