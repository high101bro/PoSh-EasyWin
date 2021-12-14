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
# sFqgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUpF7G86yxqpdnNfoHhwGl6S4trCgwDQYJKoZI
# hvcNAQEBBQAEggEAIN5MbuvJg+xPTvz1DA3kab8/07glYEEmgq95V01MwGRI4oII
# Nm1DGHhCcA3EtOvHD6bIZ4VCj6KHMzFr718e0IEqWQzkl8NF7kcox9sFVm3Ypc2b
# 6DweXCqTGzYEzcSdzi28nq2uLTJydZ9bvFFAhfMzZezvWRoBGSiaCnEQ9ipfjtKR
# uHnKaML/un7/QXl5MLPyDNDHSnJF8baicYTYuuCRroWKkBArXEvdRz9Q0/jPkgcC
# +sS32PEj69zGII1xxZAAYnB9lWL21SAFzCyMi14ztacBdFzu+y/e2tViZRR8D+xl
# zkY2T6kroKSS2TFZ4QciZ6s5OO9fuEfBBqO9Zg==
# SIG # End signature block
