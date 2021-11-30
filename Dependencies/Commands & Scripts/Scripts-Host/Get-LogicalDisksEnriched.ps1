<#
.Description

	This script gets the Logical Dives mapped to the computer. It translates the drivetype something user readible.
	This also gets plugged in External Drives via USB.
#>
function Get-LogicalMappedDrives{
    Get-WmiObject -Class Win32_LogicalDisk |
        Select-Object -Property @{Name='ComputerName';Expression={$($env:computername)}},
        @{Name='Name';Expression={$_.DeviceID}},
            DeviceID, DriveType,
        @{Name = 'DriveTypeName'
            Expression = {
                if     ($_.DriveType -eq 0) {'Unknown'}
                elseif ($_.DriveType -eq 1) {'No Root Directory'}
                elseif ($_.DriveType -eq 2) {'Removeable Disk'}
                elseif ($_.DriveType -eq 3) {'Local Drive'}
                elseif ($_.DriveType -eq 4) {'Network Drive'}
                elseif ($_.DriveType -eq 5) {'Compact Disc'}
                elseif ($_.DriveType -eq 6) {'RAM Disk'}
                else                        {'Error: Unknown'}
            }}, VolumeName,
        @{L='FreeSpaceGB';E={"{0:N2}" -f ($_.FreeSpace /1GB)}},
        @{L="CapacityGB";E={"{0:N2}" -f ($_.Size/1GB)}},
        FileSystem, VolumeSerialNumber, 
        Compressed, SupportsFileBasedCompression,
        SupportsDiskQuotas, QuotasDisabled, QuotasIncomplete, QuotasRebuilding
}
Get-LogicalMappedDrives


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUXG/I1ZhDJpb/R08cE5fuzNB4
# sFqgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUpF7G86yxqpdnNfoHhwGl6S4trCgwDQYJKoZI
# hvcNAQEBBQAEggEAtfwDhzhRVCAFVyVQ2tiRMyyRBC0UmUDh0ofGMUHqqkv9Hzx5
# k1rYYdgU+qTvi5DBcm4/DQCV4CZx3ilk6m5e7WhFJ2zKf+1bLey5C5oaaDO9ePTs
# hKbiEBycn+6QJK6AUrYBFwu4T0bay5sqQ5o0fAw6hKN8bEjr4tBt0EzJKh+Cjk95
# Bk7tZUrgyNTUx/XGhs7UI4S29CP1YEN75AcY1q9iYHMsY2VFpnW+DaIEZiaaN3d6
# jbT3bwhunoYHJYoJCQgTExZaa3kOpWKGRjzEe5a2rXZ3jfMb/ptlnw8jaQH9GXL+
# z/+j1E9nDU8Uz4J4+SW7Eub9hr5Ush1bjZtGuA==
# SIG # End signature block
