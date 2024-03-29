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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUc7HwkKdj626zoImvM9xp+dHC
# U+ugggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUDcJiTq45/6YrQshJDqPx3MOOU1owDQYJKoZI
# hvcNAQEBBQAEggEAgIFOfUyXl2dNBTwR1fyWV8812I2Dd0/WsPJMIAEd26USWCLM
# 6n7Jcclqc3msWw/p/4Kn5tYCCEeRUvMWqphFOaW/C0S1oCBGVG0NoCL/9yF6TBWD
# S+kE9kmfxW4eaY0BqJSjk945/Z6900F2+1aXAB7NUxi9xzxHH+s3P6XqKckqsTxO
# ALCcgHlw16cxQ4nICKwoEpGiGlZytr1/3OEeGJ97LuWnOlRhWWw1DxqIKiOJ6rjB
# m9CXsVkQ+xJRlIM84Ph6puFlsHCxsXvauZcS8Yam1YHMj25bmbqisT9lBfe3Wvrt
# pDRqgkOopCehysQw1Xz5f39NgLRXGzwy+wzoZg==
# SIG # End signature block
