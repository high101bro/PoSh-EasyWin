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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUiCwjPkk6+AK5qQ1pRkQxvNSl
# WVugggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU/fOsb0wk3aFr5wiiuwITMqhkpvgwDQYJKoZI
# hvcNAQEBBQAEggEAH57x44iHPsLXQ57/96hsOP8WQBGr9ciuVLYu8gcY+Ga4yVua
# 7NWzbxonqFcx3IUaORhOa3B6cY+tTsfwtQExaOs7DSe1vZaw8ZRo4IBllQXDNEH6
# jYE4dy9MrKUPX87PbylYnPyh0NSGmn6BeQ71nmQTItqPKt6pkx48joSE7+vdMULu
# LhxybwFfHIJLK+p9uwLxrO4PLgyr+4otWGs9Q3qzEdyoweHc4SCjWJQU3RECAq8/
# TaRGiN5JExXaXE+RGaY8mCneZwuZXBexiQ987fmR0GYscdpiIA55q8jH3Xc8WCTF
# zMSdupMqji3BF1e6BuaBbgE6qksRzq/21sRttQ==
# SIG # End signature block
