function Create-RetrievedFileDetails {
    param(
        $LocalSavePath,
        $File,
        $Ads,
        $AdsUpdateName
    )
    #$RetrievedFileSavePath = "$LocalSavePath\File Details (Properties, File Hashes, Authenticode Signature).txt"
    $RetrievedFileSavePath = "$LocalSavePath\File Details.txt"
  

    "" | Out-File $RetrievedFileSavePath
    if ($Ads) {
        "====================================================================================================" | Add-Content $RetrievedFileSavePath
        "Alternate Data Stream Metadata" | Add-Content $RetrievedFileSavePath
        "====================================================================================================" | Add-Content $RetrievedFileSavePath
        "PSComputerName                                 : " + "$($ADS.PSComputerName)" | Add-Content $RetrievedFileSavePath
        "Stream                                         : " + "$($ADS.Stream)" | Add-Content $RetrievedFileSavePath
        "Filename Extracted From                        : " + "$($ADS.FileName)" | Add-Content $RetrievedFileSavePath
        "Zone ID                                        : " + "$($ADS.ZoneID)" | Add-Content $RetrievedFileSavePath
        "Stream Value Length                            : " + "$($ADS.Length)" | Add-Content $RetrievedFileSavePath
        "Stream Data (Sample of first 1000 characters)  : " + "$($ADS.StreamDataSample)" | Add-Content $RetrievedFileSavePath
        "Stream Data                                    : " + "Reference the zipped file: '$($ADS.Stream)'" | Add-Content $RetrievedFileSavePath
        "" | Add-Content $RetrievedFileSavePath
    }    


    "====================================================================================================" | Add-Content $RetrievedFileSavePath
    "File Properties" | Add-Content $RetrievedFileSavePath
    "====================================================================================================" | Add-Content $RetrievedFileSavePath
    # Obtains metadata properties and addes the 'File Details.txt' to the archive
    if ($ADS) { $RetrievedFileProperties = Invoke-Command -ScriptBlock { param($File) Get-ItemProperty "$File" | Select-Object -Property * } -argumentlist $File -Session $session }
    else      { $RetrievedFileProperties = Invoke-Command -ScriptBlock { param($File) Get-ItemProperty "$($File.FullName)" | Select-Object -Property * } -argumentlist $File -Session $session }
    "Name                                           : " + "$($RetrievedFileProperties.Name)" | Add-Content $RetrievedFileSavePath
    "Full Name                                      : " + "$($RetrievedFileProperties.FullName)" | Add-Content $RetrievedFileSavePath
    "Creation Time                                  : " + "$($RetrievedFileProperties.CreationTime)" | Add-Content $RetrievedFileSavePath
    "Creation Time Utc                              : " + "$($RetrievedFileProperties.CreationTimeUtc)" | Add-Content $RetrievedFileSavePath
    "Last Access Time                               : " + "$($RetrievedFileProperties.LastAccessTime)" | Add-Content $RetrievedFileSavePath
    "Last Access Time Utc                           : " + "$($RetrievedFileProperties.LastAccessTimeUtc)" | Add-Content $RetrievedFileSavePath
    "Last Write Time                                : " + "$($RetrievedFileProperties.LastWriteTime)" | Add-Content $RetrievedFileSavePath
    "Last Write Time Utc                            : " + "$($RetrievedFileProperties.LastWriteTimeUtc)" | Add-Content $RetrievedFileSavePath
    "Length                                         : " + "$($RetrievedFileProperties.Length)" | Add-Content $RetrievedFileSavePath
    "Bytes                                          : " + "$("$($RetrievedFileProperties.Length) Bytes")" | Add-Content $RetrievedFileSavePath
    "Kilobytes                                      : " + "$("$([math]::Round(($RetrievedFileProperties.Length / 1KB),3)) KB")" | Add-Content $RetrievedFileSavePath
    "MegaBytes                                      : " + "$("$([math]::Round(($RetrievedFileProperties.Length / 1MB),3)) MB")" | Add-Content $RetrievedFileSavePath
    "GigaBytes                                      : " + "$("$([math]::Round(($RetrievedFileProperties.Length / 1GB),3)) GB")" | Add-Content $RetrievedFileSavePath
    "Is Read Only                                   : " + "$($RetrievedFileProperties.IsReadOnly)" | Add-Content $RetrievedFileSavePath
    "Attributes                                     : " + "$($RetrievedFileProperties.Attributes)" | Add-Content $RetrievedFileSavePath
    "Mode                                           : " + "$($RetrievedFileProperties.Mode)" | Add-Content $RetrievedFileSavePath
    "Version Info                                   : Reference Below" | Add-Content $RetrievedFileSavePath
    "   File Version Raw                            : " + "$($RetrievedFileProperties.VersionInfo.FileVersionRaw)" | Add-Content $RetrievedFileSavePath
    "   Product Version Raw                         : " + "$($RetrievedFileProperties.VersionInfo.ProductVersionRaw)" | Add-Content $RetrievedFileSavePath
    "   Comments                                    : " + "$($RetrievedFileProperties.VersionInfo.Comments)" | Add-Content $RetrievedFileSavePath
    "   Company Name                                : " + "$($RetrievedFileProperties.VersionInfo.CompanyName)" | Add-Content $RetrievedFileSavePath
    "   File Build Part                             : " + "$($RetrievedFileProperties.VersionInfo.FileBuildPart)" | Add-Content $RetrievedFileSavePath
    "   File Description                            : " + "$($RetrievedFileProperties.VersionInfo.FileDescription)" | Add-Content $RetrievedFileSavePath
    "   File Major Part                             : " + "$($RetrievedFileProperties.VersionInfo.FileMajorPart)" | Add-Content $RetrievedFileSavePath
    "   File Minor Part                             : " + "$($RetrievedFileProperties.VersionInfo.FileMinorPart)" | Add-Content $RetrievedFileSavePath
    "   File Name                                   : " + "$($RetrievedFileProperties.VersionInfo.FileName)" | Add-Content $RetrievedFileSavePath
    "   File Private Part                           : " + "$($RetrievedFileProperties.VersionInfo.FilePrivatePart)" | Add-Content $RetrievedFileSavePath
    "   File Version                                : " + "$($RetrievedFileProperties.VersionInfo.FileVersion)" | Add-Content $RetrievedFileSavePath
    "   Internal Name                               : " + "$($RetrievedFileProperties.VersionInfo.InternalName)" | Add-Content $RetrievedFileSavePath
    "   Is Debug                                    : " + "$($RetrievedFileProperties.VersionInfo.IsDebug)" | Add-Content $RetrievedFileSavePath
    "   Is Patched                                  : " + "$($RetrievedFileProperties.VersionInfo.IsPatched)" | Add-Content $RetrievedFileSavePath
    "   Is Private Build                            : " + "$($RetrievedFileProperties.VersionInfo.IsPrivateBuild)" | Add-Content $RetrievedFileSavePath
    "   Is PreRelease                               : " + "$($RetrievedFileProperties.VersionInfo.IsPreRelease)" | Add-Content $RetrievedFileSavePath
    "   Is Special Build                            : " + "$($RetrievedFileProperties.VersionInfo.IsSpecialBuild)" | Add-Content $RetrievedFileSavePath
    "   Language                                    : " + "$($RetrievedFileProperties.VersionInfo.Language)" | Add-Content $RetrievedFileSavePath
    "   Legal Copyright                             : " + "$($RetrievedFileProperties.VersionInfo.LegalCopyright)" | Add-Content $RetrievedFileSavePath
    "   Legal Trademarks                            : " + "$($RetrievedFileProperties.VersionInfo.LegalTrademarks)" | Add-Content $RetrievedFileSavePath
    "   Original File Name                          : " + "$($RetrievedFileProperties.VersionInfo.OriginalFilename)" | Add-Content $RetrievedFileSavePath
    "   Private Build                               : " + "$($RetrievedFileProperties.VersionInfo.PrivateBuild)" | Add-Content $RetrievedFileSavePath
    "   Product Build Part                          : " + "$($RetrievedFileProperties.VersionInfo.ProductBuildPart)" | Add-Content $RetrievedFileSavePath
    "   Product Major Part                          : " + "$($RetrievedFileProperties.VersionInfo.ProductMajorPart)" | Add-Content $RetrievedFileSavePath
    "   Product Minor Part                          : " + "$($RetrievedFileProperties.VersionInfo.ProductMinorPart)" | Add-Content $RetrievedFileSavePath
    "   Product Name                                : " + "$($RetrievedFileProperties.VersionInfo.ProductName)" | Add-Content $RetrievedFileSavePath
    "   Product Private Part                        : " + "$($RetrievedFileProperties.VersionInfo.ProductPrivatePart)" | Add-Content $RetrievedFileSavePath
    "   Product Version                             : " + "$($RetrievedFileProperties.VersionInfo.ProductVersion)" | Add-Content $RetrievedFileSavePath
    "   Special Build                               : " + "$($RetrievedFileProperties.VersionInfo.SpecialBuild)" | Add-Content $RetrievedFileSavePath
    "Target                                         : " + "$($RetrievedFileProperties.Target)" | Add-Content $RetrievedFileSavePath
    "LinkType                                       : " + "$($RetrievedFileProperties.LinkType)" | Add-Content $RetrievedFileSavePath
    "Exists                                         : " + "$($RetrievedFileProperties.Exists)" | Add-Content $RetrievedFileSavePath
    "Base Name                                      : " + "$($RetrievedFileProperties.BaseName)" | Add-Content $RetrievedFileSavePath
    "Extension                                      : " + "$($RetrievedFileProperties.Extension)" | Add-Content $RetrievedFileSavePath
    "Directory                                      : " + "$($RetrievedFileProperties.Directory)" | Add-Content $RetrievedFileSavePath
    "PS Drive                                       : " + "$($RetrievedFileProperties.PSDrive)" | Add-Content $RetrievedFileSavePath
    "PS Provider                                    : " + "$($RetrievedFileProperties.PSProvider)" | Add-Content $RetrievedFileSavePath


    "`n" | Add-Content $RetrievedFileSavePath
    "====================================================================================================" | Add-Content $RetrievedFileSavePath
    "File Hashes" | Add-Content $RetrievedFileSavePath
    "====================================================================================================" | Add-Content $RetrievedFileSavePath
        "File Hash MD5                                  : $RetrievedFileHashMD5"    | Add-Content $RetrievedFileSavePath
        # Hash obtained earily

    if ($ADS){
        $RetrievedFileHashSHA1   = Invoke-Command -ScriptBlock { param($File) (Get-FileHash -Algorithm SHA1   -Path "$File").Hash } -argumentlist $File -Session $session
        "File Hash SHA1                                 : $RetrievedFileHashSHA1"   | Add-Content $RetrievedFileSavePath

        $RetrievedFileHashSHA256 = Invoke-Command -ScriptBlock { param($File) (Get-FileHash -Algorithm SHA256 -Path "$File").Hash } -argumentlist $File -Session $session
        "File Hash SHA256                               : $RetrievedFileHashSHA256" | Add-Content $RetrievedFileSavePath
        
        $RetrievedFileHashSHA512 = Invoke-Command -ScriptBlock { param($File) (Get-FileHash -Algorithm SHA512 -Path "$File").Hash } -argumentlist $File -Session $session
        "File Hash SHA512                               : $RetrievedFileHashSHA512" | Add-Content $RetrievedFileSavePath    
    }
    else{
        $RetrievedFileHashSHA1   = Invoke-Command -ScriptBlock { param($File) (Get-FileHash -Algorithm SHA1   -Path "$($File.FullName)").Hash } -argumentlist $File -Session $session
        "File Hash SHA1                                 : $RetrievedFileHashSHA1"   | Add-Content $RetrievedFileSavePath

        $RetrievedFileHashSHA256 = Invoke-Command -ScriptBlock { param($File) (Get-FileHash -Algorithm SHA256 -Path "$($File.FullName)").Hash } -argumentlist $File -Session $session
        "File Hash SHA256                               : $RetrievedFileHashSHA256" | Add-Content $RetrievedFileSavePath
        
        $RetrievedFileHashSHA512 = Invoke-Command -ScriptBlock { param($File) (Get-FileHash -Algorithm SHA512 -Path "$($File.FullName)").Hash } -argumentlist $File -Session $session        
        "File Hash SHA512                               : $RetrievedFileHashSHA512" | Add-Content $RetrievedFileSavePath    
    }
     

     "`n" | Add-Content $RetrievedFileSavePath
    "====================================================================================================" | Add-Content $RetrievedFileSavePath
    "Authenticode Signature Information" | Add-Content $RetrievedFileSavePath
    "====================================================================================================" | Add-Content $RetrievedFileSavePath
    if ($ADS) { $RetrievedFileAuthenticodeSignature = Invoke-Command -ScriptBlock { param($File) Get-AuthenticodeSignature "$File" | Select-Object -Property * } -argumentlist $File -Session $session }
    else      { $RetrievedFileAuthenticodeSignature = Invoke-Command -ScriptBlock { param($File) Get-AuthenticodeSignature "$($File.FullName)" | Select-Object -Property * } -argumentlist $File -Session $session }
    #$RetrievedFileAuthenticodeSignature | Select-Object -Property * | Export-Csv "$LocalSavePath\File Details (Authenticode Signature).csv" -NoTypeInformation
    #$RetrievedFileAuthenticodeSignature | Select-Object -Property * | Export-Clixml "$LocalSavePath\File Details (Authenticode Signature).xml"
    "Path                                           : " + $RetrievedFileAuthenticodeSignature.Path | Add-Content $RetrievedFileSavePath
    "Status                                         : " + $RetrievedFileAuthenticodeSignature.Status | Add-Content $RetrievedFileSavePath
    "Status Message                                 : " + $RetrievedFileAuthenticodeSignature.StatusMessage | Add-Content $RetrievedFileSavePath
    "Is OS Binary                                   : " + $RetrievedFileAuthenticodeSignature.IsOSBinary | Add-Content $RetrievedFileSavePath
    "Signature Type                                 : " + $RetrievedFileAuthenticodeSignature.SignatureType | Add-Content $RetrievedFileSavePath
    "Time Stamper Certificate                       : " + $RetrievedFileAuthenticodeSignature.TimeStamperCertificate | Add-Content $RetrievedFileSavePath
    "Signer Certificate Details                     : Reference Below Details" | Add-Content $RetrievedFileSavePath
    "   Enhanced Key Usage List                     : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.EnhancedKeyUsageList | Add-Content $RetrievedFileSavePath
#                "   Raw Data                                    : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.RawData | Add-Content $RetrievedFileSavePath
    "   Thumbprint                                  : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.Thumbprint | Add-Content $RetrievedFileSavePath
    "   Serial Number                               : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.SerialNumber | Add-Content $RetrievedFileSavePath
    "   Version                                     : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.Version | Add-Content $RetrievedFileSavePath
    "   Handle                                      : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.Handle | Add-Content $RetrievedFileSavePath
    "   DNS Name List                               : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.DnsNameList | Add-Content $RetrievedFileSavePath
    "   Send As Trusted Issuer                      : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.SendAsTrustedIssuer | Add-Content $RetrievedFileSavePath
    "   Subject Name                                : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.SubjectName | Add-Content $RetrievedFileSavePath
    "      Name                                     : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.SubjectName.Name | Add-Content $RetrievedFileSavePath
    "      Oid Friendly Name                        : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.SubjectName.Oid.FriendlyName | Add-Content $RetrievedFileSavePath
    "      Oid Value                                : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.SubjectName.Oid.Value | Add-Content $RetrievedFileSavePath
#                "      Raw Data                                 : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.SubjectName.RawData | Add-Content $RetrievedFileSavePath
    "   Signature Algorithm                         : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.SignatureAlgorithm | Add-Content $RetrievedFileSavePath
    "      Value                                    : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.SignatureAlgorithm.Value | Add-Content $RetrievedFileSavePath
    "      Friendly Name                            : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.SignatureAlgorithm.FriendlyName | Add-Content $RetrievedFileSavePath
    "   Signer Certificate Issuer                   : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.Issuer | Add-Content $RetrievedFileSavePath
    "      Company Name                             : " + $(($RetrievedFileAuthenticodeSignature.SignerCertificate.Issuer -split ',')[0] -split '=')[1] | Add-Content $RetrievedFileSavePath
    "      Organization                             : " + $(($RetrievedFileAuthenticodeSignature.SignerCertificate.Issuer -split ',')[1] -split '=')[1] | Add-Content $RetrievedFileSavePath
    "      Location                                 : " + $(($RetrievedFileAuthenticodeSignature.SignerCertificate.Issuer -split ',')[2] -split '=')[1] | Add-Content $RetrievedFileSavePath
    "      State                                    : " + $(($RetrievedFileAuthenticodeSignature.SignerCertificate.Issuer -split ',')[3] -split '=')[1] | Add-Content $RetrievedFileSavePath
    "      Country                                  : " + $(($RetrievedFileAuthenticodeSignature.SignerCertificate.Issuer -split ',')[4] -split '=')[1] | Add-Content $RetrievedFileSavePath
    "   Archived                                    : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.Archived | Add-Content $RetrievedFileSavePath
    "   Signer Certificate Subject                  : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.Subject | Add-Content $RetrievedFileSavePath
    "      Company Name                             : " + $(($RetrievedFileAuthenticodeSignature.SignerCertificate.Subject -split ',')[0] -split '=')[1] | Add-Content $RetrievedFileSavePath
    "      Organization                             : " + $(($RetrievedFileAuthenticodeSignature.SignerCertificate.Subject -split ',')[1] -split '=')[1] | Add-Content $RetrievedFileSavePath
    "      Location                                 : " + $(($RetrievedFileAuthenticodeSignature.SignerCertificate.Subject -split ',')[2] -split '=')[1] | Add-Content $RetrievedFileSavePath
    "      State                                    : " + $(($RetrievedFileAuthenticodeSignature.SignerCertificate.Subject -split ',')[3] -split '=')[1] | Add-Content $RetrievedFileSavePath
    "      Country                                  : " + $(($RetrievedFileAuthenticodeSignature.SignerCertificate.Subject -split ',')[4] -split '=')[1] | Add-Content $RetrievedFileSavePath
    "   Extensions                                  : " + "Broken Down Below" | Add-Content $RetrievedFileSavePath
    "      Enhanced Key Usages                      : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.Extensions.EnhancedKeyUsages | Add-Content $RetrievedFileSavePath
    "         Value                                 : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.Extensions.EnhancedKeyUsages.Value | Add-Content $RetrievedFileSavePath
    "         Friendly Name                         : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.Extensions.EnhancedKeyUsages.FriendlyName | Add-Content $RetrievedFileSavePath
    foreach ($item in $RetrievedFileAuthenticodeSignature.SignerCertificate.Extensions) {
    "      Extension - Oid Friendly Name            : " + $item.Oid.FriendlyName | Add-Content $RetrievedFileSavePath
    "                  Oid Value                    : " + $item.Oid.Value | Add-Content $RetrievedFileSavePath
    "                  Critical                     : " + $item.Critical | Add-Content $RetrievedFileSavePath
#                "                  Raw Data                     : " + $item.RawData | Add-Content $RetrievedFileSavePath
    }
    "   Issuer Name                                 : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.IssuerName | Add-Content $RetrievedFileSavePath
    "      Name                                     : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.IssuerName.Name | Add-Content $RetrievedFileSavePath
    "      Oid Friendly Name                        : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.IssuerName.Oid.FriendlyName | Add-Content $RetrievedFileSavePath
    "      Oid Value                                : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.IssuerName.Oid.Value | Add-Content $RetrievedFileSavePath
#                "      Raw Data                                 : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.IssuerName.RawData | Add-Content $RetrievedFileSavePath
    "   Not After                                   : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.NotAfter | Add-Content $RetrievedFileSavePath
    "   Not Before                                  : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.NotBefore | Add-Content $RetrievedFileSavePath
    "   Has Private Key                             : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.HasPrivateKey | Add-Content $RetrievedFileSavePath
    "   Private Key                                 : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PrivateKey | Add-Content $RetrievedFileSavePath
    "      Key                                      : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PrivateKey.Key | Add-Content $RetrievedFileSavePath
    "      Oid Friendly Name                        : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PrivateKey.Oid.FriendlyName | Add-Content $RetrievedFileSavePath
    "      Oid Value                                : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PrivateKey.Oid.Value | Add-Content $RetrievedFileSavePath
    "      Encoded Key Value                        : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PrivateKey.EncodedKeyValue | Add-Content $RetrievedFileSavePath
    "      Encoded Parameters                       : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PrivateKey.EncodedParameters | Add-Content $RetrievedFileSavePath
    "   Public Key                                  : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey | Add-Content $RetrievedFileSavePath
    "      Key                                      : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key | Add-Content $RetrievedFileSavePath
    "         Public Only                           : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.PublicOnly | Add-Content $RetrievedFileSavePath
    "         Csp Key Container Info                : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo | Add-Content $RetrievedFileSavePath
    "            Machine Key Store                  : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.MachineKeyStore | Add-Content $RetrievedFileSavePath
    "            Provider Name                      : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.ProviderName | Add-Content $RetrievedFileSavePath
    "            Provider Type                      : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.ProviderType | Add-Content $RetrievedFileSavePath
    "            Key Container Name                 : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.KeyContainerName | Add-Content $RetrievedFileSavePath
    "            Unique Key Container Name          : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.UniqueKeyContainerName | Add-Content $RetrievedFileSavePath
    "            Key Number                         : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.KeyNumber | Add-Content $RetrievedFileSavePath
    "            Exportable                         : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.Exportable | Add-Content $RetrievedFileSavePath
    "            Hardware Device                    : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.HardwareDevice | Add-Content $RetrievedFileSavePath
    "            Removable                          : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.Removable | Add-Content $RetrievedFileSavePath
    "            Accessible                         : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.Accessible | Add-Content $RetrievedFileSavePath
    "            Protected                          : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.Protected | Add-Content $RetrievedFileSavePath
    "            Randomly Generated                 : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.RandomlyGenerated | Add-Content $RetrievedFileSavePath
    "            Crypto Key Security                : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity | Add-Content $RetrievedFileSavePath
    "               Path                            : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.Path | Add-Content $RetrievedFileSavePath
    "               Owner                           : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.Owner | Add-Content $RetrievedFileSavePath
    "               Group                           : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.Group | Add-Content $RetrievedFileSavePath
    "               Access                          : Reference Below" | Add-Content $RetrievedFileSavePath
    foreach ($item in $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.Access) {
    "                  Crypto Key Rights            : " + $item.CryptoKeyRights | Add-Content $RetrievedFileSavePath
    "                  Access Control Type          : " + $item.AccessControlType | Add-Content $RetrievedFileSavePath
    "                  Identity Reference           : " + $item.IdentityReference | Add-Content $RetrievedFileSavePath
    "                  Is Inherited                 : " + $item.IsInherited | Add-Content $RetrievedFileSavePath
    "                  Inheritance Flags            : " + $item.InheritanceFlags | Add-Content $RetrievedFileSavePath
    "                  Propagation Flags            : " + $item.PropagationFlags | Add-Content $RetrievedFileSavePath
    "" | Add-Content $RetrievedFileSavePath
    }                
    "               Sddl                            : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.Sddl | Add-Content $RetrievedFileSavePath
    "               Access To String                : Reference Below" | Add-Content $RetrievedFileSavePath
    foreach ($item in $($RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessToString -split "`n")) {
    "                                               : $item" | Add-Content $RetrievedFileSavePath
    }
    "               Access Right Type               : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRightType | Add-Content $RetrievedFileSavePath
    "                  Name                         : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRightType.Name | Add-Content $RetrievedFileSavePath
    "                  Is Public                    : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRightType.IsPublic | Add-Content $RetrievedFileSavePath
    "                  Is Serializable              : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRightType.IsSerializable | Add-Content $RetrievedFileSavePath
    "                  BaseType                     : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRightType.BaseType | Add-Content $RetrievedFileSavePath
    "                     Name                      : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRightType.BaseType.Name | Add-Content $RetrievedFileSavePath
    "                     Is Public                 : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRightType.BaseType.IsPublic | Add-Content $RetrievedFileSavePath
    "                     Is Serializable           : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRightType.BaseType.IsSerializable | Add-Content $RetrievedFileSavePath
    "                     BaseType                  : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRightType.BaseType.BaseType | Add-Content $RetrievedFileSavePath
    "               Access Rule Type                : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType | Add-Content $RetrievedFileSavePath
    "                  Name                         : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType.Name | Add-Content $RetrievedFileSavePath
    "                  Is Public                    : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType.IsPublic | Add-Content $RetrievedFileSavePath
    "                  Is Serializable              : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType.IsSerializable | Add-Content $RetrievedFileSavePath
    "                  BaseType                     : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType.BaseType | Add-Content $RetrievedFileSavePath
    "                     Name                      : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType.BaseType.Name | Add-Content $RetrievedFileSavePath
    "                     Is Public                 : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType.BaseType.IsPublic | Add-Content $RetrievedFileSavePath
    "                     Is Serializable           : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType.BaseType.IsSerializable | Add-Content $RetrievedFileSavePath
    "                     BaseType                  : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType.BaseType.BaseType | Add-Content $RetrievedFileSavePath
    "                        Name                   : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType.BaseType.BaseType.Name | Add-Content $RetrievedFileSavePath
    "                        Is Public              : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType.BaseType.BaseType.IsPublic | Add-Content $RetrievedFileSavePath
    "                        Is Serializable        : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType.BaseType.BaseType.IsSerializable | Add-Content $RetrievedFileSavePath
    "                        BaseType               : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AccessRuleType.BaseType.BaseType.BaseType | Add-Content $RetrievedFileSavePath
    "               Access Rules Protected          : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AreAccessRulesProtected | Add-Content $RetrievedFileSavePath
    "               Access Rules Canonical          : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AreAccessRulesCanonical | Add-Content $RetrievedFileSavePath
    "               Audit Rule Type                 : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType | Add-Content $RetrievedFileSavePath
    "                  Name                         : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType.Name | Add-Content $RetrievedFileSavePath
    "                  Is Public                    : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType.IsPublic | Add-Content $RetrievedFileSavePath
    "                  Is Serializable              : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType.IsSerializable | Add-Content $RetrievedFileSavePath
    "                  BaseType                     : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType.BaseType | Add-Content $RetrievedFileSavePath
    "                     Name                      : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType.BaseType.Name | Add-Content $RetrievedFileSavePath
    "                     Is Public                 : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType.BaseType.IsPublic | Add-Content $RetrievedFileSavePath
    "                     Is Serializable           : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType.BaseType.IsSerializable | Add-Content $RetrievedFileSavePath
    "                     BaseType                  : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType.BaseType.BaseType | Add-Content $RetrievedFileSavePath
    "                        Name                   : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType.BaseType.BaseType.Name | Add-Content $RetrievedFileSavePath
    "                        Is Public              : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType.BaseType.BaseType.IsPublic | Add-Content $RetrievedFileSavePath
    "                        Is Serializable        : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType.BaseType.BaseType.IsSerializable | Add-Content $RetrievedFileSavePath
    "                        BaseType               : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AuditRuleType.BaseType.BaseType.BaseType | Add-Content $RetrievedFileSavePath
    "               Audit Rules Protected           : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AreAuditRulesProtected | Add-Content $RetrievedFileSavePath
    "               Audit Rules Canonical           : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.CspKeyContainerInfo.CryptoKeySecurity.AreAuditRulesCanonical | Add-Content $RetrievedFileSavePath
    "         Key Size                              : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.KeySize | Add-Content $RetrievedFileSavePath
    "         Key Exchange Algorithm                : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.KeyExchangeAlgorithm | Add-Content $RetrievedFileSavePath
    "         Signature Algorithm                   : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.SignatureAlgorithm | Add-Content $RetrievedFileSavePath
    "         Persist Key In Csp                    : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.PersistKeyInCsp | Add-Content $RetrievedFileSavePath
    "         Legal Key Sizes                       : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.LegalKeySizes | Add-Content $RetrievedFileSavePath
    "            MinSize                            : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.LegalKeySizes.MinSize | Add-Content $RetrievedFileSavePath
    "            MaxSize                            : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.LegalKeySizes.MaxSize | Add-Content $RetrievedFileSavePath
    "            SkipSize                           : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Key.LegalKeySizes.SkipSize | Add-Content $RetrievedFileSavePath
    "      Oid Friendly Name                        : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Oid.FriendlyName | Add-Content $RetrievedFileSavePath
    "      Oid Value                                : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.Oid.Value | Add-Content $RetrievedFileSavePath
    "      Encoded Key Value                        : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.EncodedKeyValue | Add-Content $RetrievedFileSavePath
    "         Oid Friendly Name                     : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.EncodedKeyValue.Oid.FriendlyName | Add-Content $RetrievedFileSavePath
    "         Oid Value                             : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.EncodedKeyValue.Oid.Value | Add-Content $RetrievedFileSavePath
#                "         Raw Data                              : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.EncodedKeyValue.RawData | Add-Content $RetrievedFileSavePath
    "      Encoded Parameters                       : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.EncodedParameters | Add-Content $RetrievedFileSavePath
    "         Oid Friendly Name                     : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.EncodedParameters.Oid.FriendlyName | Add-Content $RetrievedFileSavePath
    "         Oid Value                             : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.EncodedParameters.Oid.Value | Add-Content $RetrievedFileSavePath
#                "         Raw Data                              : " + $RetrievedFileAuthenticodeSignature.SignerCertificate.PublicKey.EncodedParameters.RawData | Add-Content $RetrievedFileSavePath
    
    Add-Type -Assembly 'System.IO.Compression.FileSystem'
    if ($ADS) { 
        $RetrievedFileToUpdate = [System.IO.Compression.ZipFile]::Open("$AdsUpdateName", 'update')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($RetrievedFileToUpdate, $RetrievedFileSavePath, "File Details.txt",'Optimal')
    }
    else {
        $RetrievedFileToUpdate = [System.IO.Compression.ZipFile]::Open("$LocalSavePath\$($File.BaseName) [MD5=$RetrievedFileHashMD5].zip", 'update')
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($RetrievedFileToUpdate, $RetrievedFileSavePath, "File Details.txt",'Optimal')    
    }
    #[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($RetrievedFileToUpdate, $RetrievedFileSavePath, "File Details (Properties, File Hashes, Authenticode Signature).txt",'Optimal')
    #[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($RetrievedFileToUpdate, "$LocalSavePath\File Details (Properties).csv", "File Details (Properties).csv",'Optimal')
    #[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($RetrievedFileToUpdate, "$LocalSavePath\File Details (Properties).xml", "File Details (Properties).xml",'Optimal')
    #[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($RetrievedFileToUpdate, "$LocalSavePath\File Details (Authenticode Signature).csv", "File Details (Authenticode Signature).csv",'Optimal')
    #[System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($RetrievedFileToUpdate, "$LocalSavePath\File Details (Authenticode Signature).xml", "File Details (Authenticode Signature).xml",'Optimal')
    $RetrievedFileToUpdate.Dispose()
    
    Remove-Item $RetrievedFileSavePath -Force
    #Remove-Item "$LocalSavePath\File Details (Properties).csv", "File Details (Properties).csv" -Force
    #Remove-Item "$LocalSavePath\File Details (Properties).xml", "File Details (Properties).xml" -Force
    #Remove-Item "$LocalSavePath\File Details (Authenticode Signature).csv", "File Details (Authenticode Signature).csv" -Force
    #Remove-Item "$LocalSavePath\File Details (Authenticode Signature).xml", "File Details (Authenticode Signature).xml" -Force
}
 