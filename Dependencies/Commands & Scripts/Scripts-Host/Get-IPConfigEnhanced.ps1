$GetNetAdapter = Get-NetAdapter | Select-Object -Property *

$GetNetIPAddress = Get-NetIPAddress


foreach ($NetAdapter in $GetNetAdapter) {
    foreach ($NetIPAddress in $GetNetIPAddress) {
        if ($NetAdapter.ifIndex -eq $NetIPAddress.ifIndex) {
            $NetAdapter `
            | Add-Member -MemberType NoteProperty -Name IPAddress     -Value $NetIPAddress.IPAddress     -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name PrefixLength  -Value $NetIPAddress.PrefixLength  -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name PrefixOrigin  -Value $NetIPAddress.PrefixOrigin  -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name SuffixOrigin  -Value $NetIPAddress.SuffixOrigin  -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name Type          -Value $NetIPAddress.Type          -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name AddressFamily -Value $NetIPAddress.AddressFamily -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name AddressState  -Value $NetIPAddress.AddressState  -Force -PassThru `
            | Add-Member -MemberType NoteProperty -Name PolicyStore   -Value $NetIPAddress.PolicyStore   -Force
        }
    }
}
$GetNetAdapter | Select-Object -Property Name, InterfaceName, InterfaceDescription, Status, ConnectorPresent, Virtual, AddressFamily, IPAddress, Type, MacAddress, MediaConnectionState, PromiscuousMode, AdminStatus, MediaType, LinkSpeed, MtuSize, FullDuplex, AddressState, PrefixLength, PrefixOrigin, SuffixOrigin, DriverInformation, DriverProvider, DriverVersion, DriverDate, ifIndex, PolicyStore, Speed, ReceiveLinkSpeed, TransmitLinkSpeed, DeviceWakeUpEnable, AdminLocked, NotUserRemovable, ComponentID, HardwareInterface, Hidden, * -ErrorAction SilentlyContinue


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUsy+rE82wVSr7PojhnSROGV4M
# dV6gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUWRSzB7bS0xrQKe05ThP6tDIt+74wDQYJKoZI
# hvcNAQEBBQAEggEACg17tXNXPRpjIxZPQNoYI2Wg6m2wU2lOT/o5hwCFVKlY9mSX
# CnGid++f0j2S6e94NVb668MAnDMAtf5LRp4AUckC8P3LRiRFBN2PRFhWSyIJ4sve
# TY2nvyIEp2rYbcDDCN/ZMFX/NJWMvtVCnAY1/DxGmLXC7ikOf0stH8mu3FDMiJYk
# rf0XadVSEtD0SE4N2OBdS/+hQ6+U/vzY2gT6kwQmi0zkkcsxU+D3AR2INE5pKgX4
# fqydDco5COJ2CNK/goMUJqLAjUCu7EatUqnvzoGwG+igwy5M8ShC7+4jGCVU+sFm
# etfj4l178+3xPPhSCW+mE08z1HTJ9qyAR1hJjA==
# SIG # End signature block
