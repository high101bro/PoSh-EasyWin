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
# nvKgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUN8QDi5UMlZ50xPuhfeIcfH51NZkwDQYJKoZI
# hvcNAQEBBQAEggEALBY+RmCZIjLBlzCYrREsXMowsvstRNgZodP5YVlRr/hdGC9n
# 0F3xoXaCHtJpTdrJNvdNO+XSRIYHv8HCbErAtS7QuJzsurEzdzOGJ39bEuPlGhFt
# r1V47cv85nFYEmbvZBKGTCOydB+8g3bj0OwHi0CBdL9Ou2KMU7Iw9pN7vyiIbEkZ
# 0eAN7jGPL0I2D+CBxJzGZiCqnAgJW82xUvBWX5oYJ0+0yg1A8979gz+QZ0NIE0h3
# FkimFeJ3X7qtPA9bOXMuAj12gpKFb6SXxvaLnG5oxQXIBPLisKyz9VK+pp9NxFW7
# 6H65ra+3I1+cAyufHKUxC9cdkeOtu01Hu0nCiA==
# SIG # End signature block
