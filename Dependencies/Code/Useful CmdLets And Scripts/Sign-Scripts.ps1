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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU4GJLWO4vwuagb4KUGBv7PYMg
# LV2gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUj12g8EAVxDlKXuPFHMsBQfHF4/gwDQYJKoZI
# hvcNAQEBBQAEggEAWaBvz51K39Xt7+nSEjZT7+0RHFqV3WAP3WDZfPcCppgR9emX
# Q0OSmsZTpZ/6h5JFRWQuvjKaoMIQQRwp0lSAcL6BVoXESXC61zCT5pmW9kqG+FXp
# iGk07gxKKlzqirGrk80v02Tjw83heBYpKSOqRDoeEoWi4spDupfvj7JYpQO46/WN
# 0azBloBLNnEYfHDlk83M56pXhuuzuPyx11V8UYKAO73L3MeIUpU9g6PbFjGMtfiZ
# 9Oywy5su4U/vEUJCvXCfiyBlrzwhkBmbOtkKpWlwWdXxAfopvbkBB9fk0df1JeDj
# bCyzCpHDelXcUDNP7OelFiihVprv7Y+cqtiCYw==
# SIG # End signature block
