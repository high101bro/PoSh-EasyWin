$ErrorActionPreference = 'SilentlyContinue'

#$env:computername
#$ErrorActionPreference = 'SilentlyContinue'

$SHA256  = [System.Security.Cryptography.HashAlgorithm]::Create("SHA256")
$MD5     = [System.Security.Cryptography.HashAlgorithm]::Create("MD5")
$regkeys = @(
'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run',
'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run',
'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce',
'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServices',
'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce',
'HCCU:\Software\Microsoft\Windows\Curre ntVersion\RunOnce\Setup',
'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon',
'HKLM:\Software\Microsoft\Active Setup\Installed Components',
'HKLM:\System\CurrentControlSet\Servic es\VxD',
'HKCU:\Control Panel\Desktop',
'HKLM:\System\CurrentControlSet\Control\Session Manager',
'HKLM:\System\CurrentControlSet\Services',
'HKLM:\System\CurrentControlSet\Services\Winsock2\Parameters\Protocol_Catalog\Catalog_Entries',
'HKLM:\System\Control\WOW\cmdline',
'HKLM:\System\Control\WOW\wowcmdline',
'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon\Userinit',
'HKLM:\Software\Microsoft\Windows\Curr entVersion\ShellServiceObjectDelayLoad',
'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows\run',
'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows\load',
'HKCU:\Software\Microsoft\Windows\Curre ntVersion\Policies\Explorer\run',
'HLKM:\Software\Microsoft\Windows\Curr entVersion\Policies\Explorer\run'
)
$Startups = @()
foreach ($key in $regkeys) {
    $entry = Get-ItemProperty -Path $key
    $entry = $entry | Select-Object * -ExcludeProperty PSPath, PSParentPath, PSChildName, PSDrive, PSProvider
    #$entry.psobject.Properties |ft
    foreach($item in $entry.PSObject.Properties) {
        $value = $item.value.replace('"', '')
        # The entry could be an actual path
        if(Test-Path $value) {

            $filebytes   = [system.io.file]::ReadAllBytes($value)
            $AuthenticodeSignature = Get-AuthenticodeSignature $value
            $HashObject  = New-Object PSObject -Property @{
                Name     = Split-Path $Value -Leaf
                Path     = $value
                SignatureStatus = $AuthenticodeSignature.Status
                SignatureCompany = ($AuthenticodeSignature.SignerCertificate.SubjectName.Name -split ',')[0].TrimStart('CN=')
                MD5      = [System.BitConverter]::ToString($md5.ComputeHash($filebytes)) -replace "-", "";
                SHA256   = [System.BitConverter]::ToString($sha256.ComputeHash($filebytes)) -replace "-","";
                PSComputerName = $env:COMPUTERNAME
            }
            $Startups += $HashObject
        }
    }
}
$Startups | Select-Object PSComputerName, Name, Path, MD5, SHA256, SignatureStatus, SignatureCompany


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQURVRHPDugWAqkPfBXaWgmMhDb
# x8ugggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUINDXZRYBVe+r0PxukeHrlyXMvOUwDQYJKoZI
# hvcNAQEBBQAEggEAYi1E2pEdSvirtu0Puq9JSX7dBTkGHVmsy5b5AWkwW4+UptvF
# hviMLw1zxYwCrWSkLlgPRYZL82mcZgnKpDRzq/2Xs0nGgnimzGPztB3RjaxljCbs
# n+s/Hljsa9E6G3guN8re3EpXScembMY5h8bWx+BAmgDQuy+xBfcw8C38kHuotQ1n
# HpCzSAiObU9Cnh7mV8X0qiNflaxbSb76cbJRu57QOdQEWJYG666czI/RqLTZD9q8
# SDSJAPiPx8LS6Vz14+jzdfnu2grzodw+7ptuseWNaxSanyj7WSS4dI4prz8M9FcM
# xWH6mHCalL1J117YafkNFU6OpKygnh7zfslpag==
# SIG # End signature block
