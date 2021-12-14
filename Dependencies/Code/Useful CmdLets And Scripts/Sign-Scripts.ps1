param(
    $FilePath,
    $Certificate
)

<#
$Params = @{    
Subject           = "CN=PoSh-EasyWin By Dan Komnick (high101bro)"
Type              = "CodeSigningCert"    
KeySpec           = "Signature"     
KeyUsage          = "DigitalSignature"    
FriendlyName      = "Test code signing"    
NotAfter          = [datetime]::now.AddYears(10)    
CertStoreLocation = 'Cert:\CurrentUser\My' }

$SigningCertificate = New-SelfSignedCertificate @Params

Export-Certificate -FilePath "PoSh-EasyWin_Public_Certificate.cer" -Cert $SigningCertificate
Import-Certificate -FilePath "PoSh-EasyWin_Public_Certificate.cer" -CertStoreLocation Cert:\CurrentUser\Root
#>

if (-not $FilePath) {
    $FilePath = Get-ChildItem . -Recurse
}
if (-not $Certificate) {
    $Certificate = Get-ChildItem -Path 'Cert:\CurrentUser\Root\' | Where-Object {$_.Thumbprint -eq 'D78BFEBE3F975656E6200FED8521A1815C41327A'}
}

Write-Host "[!] " -ForegroundColor Red -NoNewline
Write-Host "Signing Scripts with: " -ForegroundColor Cyan
Write-Host "$Certificate" -ForegroundColor White
Write-Host ""
Write-Host "[!] " -ForegroundColor Red -NoNewline
Write-Host "Do You Want To Continue? " -ForegroundColor Cyan -NoNewline
$Prompt = Read-Host "(y/n)"
Write-Host ""

$script:TotalScripts = 0
$SignIt = {
    Foreach ($Script in $FilePath) {
        if ($script | Where-Object {$_.Extension -eq '.ps1'}) {
            $script:TotalScripts += 1
            Set-AuthenticodeSignature $Script.FullName $Certificate -OutVariable SignStatus | Out-Null
            Write-Host "[!] " -ForegroundColor Red -NoNewline
            Write-Host "Signed Script [" -ForegroundColor Cyan -NoNewline
            Write-Host "$($SignStatus.Status)" -ForegroundColor Yellow -NoNewline
            Write-Host "]: " -ForegroundColor Cyan -NoNewline
            Write-Host "$Script" -ForegroundColor White
        }
    }
}

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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUmh+Nv9p8eRc2Vg9jle+fUj17
# K62gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUCdG25RkAMxl4r2t/8yQK9LdDhV0wDQYJKoZI
# hvcNAQEBBQAEggEArR6PDoemr/GADRcaKhTIMnuOYgMpcHIlhkyCjC6P5hdhCoQl
# T36B7920etmssdZQsCz1MAACEeKnPKBzBT7lMHmAX1Ct9usiqAwsliE7X7SrBvtR
# wPTLGTbA4ymVZ3qkV8X5SjOGjRo096gh9fS+SuADzhUoO4sxu0NHapSaGn6eWmWN
# etV9MK3svjZ+cymq6WmPTbzBEGLjofu9liI+/6V0xQzl4EzgbrEAmzghcshlleMq
# 6IyPxliG9InXw/3ULQmKKIMzxOfGztPP8KlukHGD/KJz2xpUwc8E0EReTLsjji3x
# VUonHXUSFUhuJhx/5xj+74qCKQQ8mQ3s62XffA==
# SIG # End signature block
