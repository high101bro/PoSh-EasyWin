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


