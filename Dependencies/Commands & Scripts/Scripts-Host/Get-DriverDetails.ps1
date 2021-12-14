# Gets Driver Details, MD5 Hash, and File Signature Status
# This script can be quite time consuming
$Drivers = Get-WindowsDriver -Online -All
$MD5     = [System.Security.Cryptography.HashAlgorithm]::Create("MD5")
$SHA256  = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")

foreach ($Driver in $Drivers) {
    $filebytes = [system.io.file]::ReadAllBytes($($Driver).OriginalFilename)

    $HashMD5 = [System.BitConverter]::ToString($MD5.ComputeHash($filebytes)) -replace "-", ""
    $Driver | Add-Member -NotePropertyName HashMD5 -NotePropertyValue $HashMD5

    # If enbaled, add HashSHA256 to Select-Object
    #$HashSHA256 = [System.BitConverter]::ToString($SHA256.ComputeHash($filebytes)) -replace "-", ""
    #$Driver | Add-Member -NotePropertyName HashSHA256 -NotePropertyValue $HashSHA256

    $FileSignature = Get-AuthenticodeSignature -FilePath $Driver.OriginalFileName
    $Signercertificate = $FileSignature.SignerCertificate.Thumbprint
    $Driver | Add-Member -NotePropertyName SignerCertificate -NotePropertyValue $Signercertificate
    $Status = $FileSignature.Status
    $Driver | Add-Member -NotePropertyName Status -NotePropertyValue $Status
    $Driver | Select-Object -Property @{name="PSComputerName";expression={$env:COMPUTERNAME}}, Online, ClassName, Driver, OriginalFileName, ClassDescription, BootCritical, HashMD5, DriverSignature, SignerCertificate, Status, ProviderName, Date, Version, InBox, LogPath, LogLevel
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUKPxhDFgxajShPg/FWCBBZXCR
# nvKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUN8QDi5UMlZ50xPuhfeIcfH51NZkwDQYJKoZI
# hvcNAQEBBQAEggEAKa0oXaVYWIqJ3fAJyIAHqwZ0HWChepp19Q70Os0vP7mPY+Jj
# 4161aXNNeR+OWsV/7dK/ZMp4+FqPn3lws/ltaMlVTo+9R4pYMwQPZODu7Dowmw+x
# hhcbGhuhAsRGNQwuvkR3+yhn95ZLmzxMaLg4cvxjxw1AOlR5rsCoc8pOs5nVGpeM
# 5rxkGESz8AGLvNZUJ9eKRBmv6+tV+zPesfyIUr12zq841wZGBwRQJeRV5aimf75u
# OdnxtKmS7WOWSUZnt79DvfjYCbh6lRT00n0QBO2WBBNF3lPHqc0KTA+2xEZccmjG
# VXucG9hLR9pUqhtx5CU8eFM61ajY+RodzyBVKg==
# SIG # End signature block
