param(
    $AuthentiCode,
    $FilePath,
    $Subject = "CN=PoSh-EasyWin By Dan Komnick (high101bro)"
)

Write-Host "[!] " -ForegroundColor Red -NoNewline
Write-Host "Generate New Certificate? " -ForegroundColor Cyan -NoNewline
$yn = Read-host "(y/N)"

#$CertScope = 'CurrentUser'
$CertScope = 'LocalMachine'

switch -Wildcard ($yn) {
    y* {
        Write-Host "[!] " -ForegroundColor Red -NoNewline
        Write-Host "Are you sure? You should avoid changing your AuthentiCode often." -ForegroundColor Cyan -NoNewline
        $yn = Read-host "(sure/)N"

        switch -Wildcard ($yn) {
            sure {
                Write-Host ""
                Write-Host "#########################" -ForegroundColor Yellow
                Write-Host "# Remove Previous Certs #" -ForegroundColor Yellow
                Write-Host "#########################" -ForegroundColor Yellow
                $CertLocations = @(
                    "Cert:\$CertScope\My",
                    "Cert:\$CertScope\Root",
                    "Cert:\$CertScope\TrustedPublisher"
                )
                Get-ChildItem $CertLocations | Where-Object {$_.Subject -eq $Subject} | Remove-Item
                Get-ChildItem $(Get-Location) "PoSh-EasyWin_Public_Certificate.cer" | Remove-Item

                Write-Host ""
                Write-Host "########################" -ForegroundColor Yellow
                Write-Host "# Generate Certificate #" -ForegroundColor Yellow
                Write-Host "########################" -ForegroundColor Yellow
                $Params = @{
                    Subject           = $Subject
                    Type              = "CodeSigningCert"
                    KeySpec           = "Signature"
                    KeyUsage          = "DigitalSignature"
                    FriendlyName      = "High101Bro Certificate"
                    NotAfter          = [datetime]::now.AddYears(10)
                    CertStoreLocation = "Cert:\$CertScope\My"
                }

                $SigningCertificate = New-SelfSignedCertificate @Params


                Export-Certificate -FilePath "PoSh-EasyWin_Public_Certificate.cer" -Cert $SigningCertificate
                #Import-Certificate -FilePath "PoSh-EasyWin_Public_Certificate.cer" -CertStoreLocation "Cert:\$CertScope\My"
                Import-Certificate -FilePath "PoSh-EasyWin_Public_Certificate.cer" -CertStoreLocation "Cert:\$CertScope\Root"
                Import-Certificate -FilePath "PoSh-EasyWin_Public_Certificate.cer" -CertStoreLocation "Cert:\$CertScope\TrustedPublisher"

                #######################
                # Alternative  Method #
                #######################
                    # Write-Host "#############################################" -ForegroundColor Yellow
                    # Write-Host "# Add certificate to root certificate store #" -ForegroundColor Yellow
                    # Write-Host "#############################################" -ForegroundColor Yellow
                    # ## Create an object to represent the $CertScope\Root certificate store.
                    # $rootStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("Root","$CertScope")
                    # ## Open the root certificate store for reading and writing.
                    # $rootStore.Open("ReadWrite")
                    # ## Add the certificate stored in the $SigningCertificate variable.
                    # $rootStore.Add($SigningCertificate)
                    # ## Close the root certificate store.
                    # $rootStore.Close()

                    # Write-Host "###########################################################" -ForegroundColor Yellow
                    # Write-Host "# Add certificate to trusted publishers certificate store #" -ForegroundColor Yellow
                    # Write-Host "###########################################################" -ForegroundColor Yellow
                    # ## Create an object to represent the $CertScope\TrustedPublisher certificate store.
                    # $publisherStore = [System.Security.Cryptography.X509Certificates.X509Store]::new("TrustedPublisher","$CertScope")
                    # ## Open the TrustedPublisher certificate store for reading and writing.
                    # $publisherStore.Open("ReadWrite")
                    # ## Add the certificate stored in the $SigningCertificate variable.
                    # $publisherStore.Add($SigningCertificate)
                    # ## Close the TrustedPublisher certificate store.
                    # $publisherStore.Close()

                Write-Host ""
                Write-Host "##############################" -ForegroundColor Yellow
                Write-Host "# Checkings for Certificates #" -ForegroundColor Yellow
                Write-Host "##############################" -ForegroundColor Yellow
                # Confirm if the self-signed Authenticode certificate exists in the computer's Personal, Root, and Trusted Publishers certificate store
                Get-ChildItem $CertLocations | Where-Object {$_.Subject -eq $Subject}
            }
        }
    }
}



if (-not $FilePath) {
    $FilePath = Get-ChildItem . -Recurse
}
if (-not $AuthentiCode) {
    $AuthentiCode = Get-ChildItem -Path "Cert:\$CertScope\My" | Where-Object {$_.Subject -eq $Subject}
}

Write-Host ""
Write-Host "##############################" -ForegroundColor Yellow
Write-Host "# Verify Signing Certificate #" -ForegroundColor Yellow
Write-Host "##############################" -ForegroundColor Yellow
Write-Host ""
Write-Host "[!] " -ForegroundColor Red -NoNewline
Write-Host "Signing Scripts with: " -ForegroundColor Cyan
Write-Host "$AuthentiCode" -ForegroundColor White
Write-Host ""
Write-Host "[!] " -ForegroundColor Red -NoNewline
Write-Host "Do You Want To Sign the Scripts with the above Certificate? " -ForegroundColor Cyan -NoNewline
$Prompt = Read-Host "(y/n)"
Write-Host ""

$script:TotalScripts = 0
$SignIt = {
    Foreach ($Script in $FilePath) {
        $AuthenticodeSignature = Get-AuthenticodeSignature -FilePath $script.FullName -ErrorAction SilentlyContinue
        if (
            ($script | Where-Object {$_.Extension -eq '.ps1'}) -and
            ($AuthenticodeSignature.status -ne 'Valid')
        ) {
            $script:TotalScripts += 1
            Set-AuthenticodeSignature -FilePath $Script.FullName -Certificate $AuthentiCode -OutVariable SignStatus | Out-Null


            if ($SignStatus.Status -eq 'Valid') {
                # Write-Host -ForegroundColor Yellow $
                Write-Host "[+] " -ForegroundColor Yellow -NoNewline
                Write-Host "Successful Signing [" -ForegroundColor Cyan -NoNewline
                Write-Host "$($SignStatus.Status)" -ForegroundColor Yellow -NoNewline
                Write-Host "]: " -ForegroundColor Cyan -NoNewline
                Write-Host "$Script" -ForegroundColor White
            }
            else {
                Write-Host "[-] " -ForegroundColor Red -NoNewline
                Write-Host "Issue With Signing [" -ForegroundColor Cyan -NoNewline
                Write-Host "$($SignStatus.Status)" -ForegroundColor Yellow -NoNewline
                Write-Host "]: " -ForegroundColor Cyan -NoNewline
                Write-Host "$Script" -ForegroundColor White
            }
        }
        elseif ($script | Where-Object {$_.Extension -eq '.ps1'}) {
            Write-Host "[=] " -ForegroundColor Green -NoNewline
            Write-Host "Previously Signed! [" -ForegroundColor Cyan -NoNewline
            Write-Host "$($AuthenticodeSignature.Status)" -ForegroundColor Yellow -NoNewline
            Write-Host "]: " -ForegroundColor Cyan -NoNewline
            Write-Host "$Script" -ForegroundColor White
        }
    }
}

Write-Host ""
Write-Host "#######################" -ForegroundColor Yellow
Write-Host "# Signing Certifictes #" -ForegroundColor Yellow
Write-Host "#######################" -ForegroundColor Yellow
Write-Host ""

switch -Wildcard ($Prompt) {
    y* {
        Invoke-Command $SignIt
        Write-Host ""
        Write-Host "[!] " -ForegroundColor Red -NoNewline
        Write-Host "Completed Signing $script:TotalScripts Scripts: " -ForegroundColor Cyan -NoNewline
        Write-Host "Goodbye..." -ForegroundColor White
        Write-Host ""
        exit
    }
    n* {
        Write-Host "[!] " -ForegroundColor Red -NoNewline
        Write-Host "Exiting Script: " -ForegroundColor Cyan -NoNewline
        Write-Host "Goodbye..." -ForegroundColor White
        Write-Host ""
        exit
    }
    * {
        Write-Host "[!] " -ForegroundColor Red -NoNewline
        Write-Host "ERROR: " -ForegroundColor Cyan -NoNewline
        Write-Host "Invalid Entry..." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "[!] " -ForegroundColor Red -NoNewline
        Write-Host "Do You Want To Continue? " -ForegroundColor Cyan -NoNewline
        $Prompt = Read-Host "(y/n)"

    }

}







# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUncfaO+oZAp2uGdtInetru6fw
# frKgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUzPr4tY6OygV6Qn9S29mAGG8HW6MwDQYJKoZI
# hvcNAQEBBQAEggEAhTu0odeId3Vl0Bj5TWy3zrLYC7R0H/hY7ACStfPD0f7ZfY1k
# UiuOHRbN9vCIGATT3/z7blh/EsnupumEcMYHAEdB0w5jHEY5RGEx1IezEJpuClDd
# /LNXRyvZcXKRsjQXsyabtxBBj4sUKD2uRfZfPclbsz4VXPtfRHArTbqbaB6eV+lr
# z8RgHvatJNkmgzObF5hc9/EiUHosT1KUiu8+xVAYglaFh9DAaKV8EOEZrhYJ+jim
# yRn+gcnhzVPjXIvusypdo1z/Bugv4pumBpXVl2D/+JiflJoArz91rF8QE4AyMh1N
# hZzebEMjEI04ubMsiTFkAReMb3M7l4YN89MlOw==
# SIG # End signature block
