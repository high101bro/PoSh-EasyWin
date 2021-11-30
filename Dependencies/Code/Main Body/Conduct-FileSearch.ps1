function Conduct-FileSearch {
    param($DirectoriesToSearch,$FilesToSearch,$MaximumDepth,$GetChildItemDepth,$GetFileHash,$FileHashSelection)

    #Invoke-Expression $GetChildItemDepth
    Function Get-ChildItemDepth {
        Param(
            [String[]]$Path     = $PWD,
            [String]$Filter     = "*",
            [Byte]$Depth        = 255,
            [Byte]$CurrentDepth = 0
        )
        $CurrentDepth++
        Get-ChildItem $Path -Force | ForEach-Object {
            $_ | Where-Object { $_.Name -Like $Filter }
            If ($_.PsIsContainer) {
                If ($CurrentDepth -le $Depth) {
                    # Callback to this function
                    Get-ChildItemDepth -Path $_.FullName -Filter $Filter -Depth $Depth -CurrentDepth $CurrentDepth
                }
            }
        }
    }

    #Invoke-Expression $GetFileHash
    function Get-FileHash{
        param (
            [string]$Path,
            [string]$Algorithm
        )
        if     ($Algorithm -eq 'MD5')       {$HashAlgorithm = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider}
        elseif ($Algorithm -eq 'SHA1')      {$HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider}
        elseif ($Algorithm -eq 'SHA256')    {$HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider}
        elseif ($Algorithm -eq 'SHA384')    {$HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA384CryptoServiceProvider}
        elseif ($Algorithm -eq 'SHA512')    {$HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA512CryptoServiceProvider}
        elseif ($Algorithm -eq 'RIPEMD160') {$HashAlgorithm = New-Object -TypeName System.Security.Cryptography.RIPEMD160Managed}
        $Hash=[System.BitConverter]::ToString($HashAlgorithm.ComputeHash([System.IO.File]::ReadAllBytes($Path)))
        $Properties = @{
            "Path"       = $Path
            "Hash"       = $Hash.Replace("-", "")
            "Algorithm"  = $Algorithm
            "ScriptNote" = 'Get-FileHash Script For Backwards Compatibility'
        }
        $ReturnFileHash = New-Object –TypeName PSObject –Prop $Properties
        return $ReturnFileHash
    }


    if ([int]$MaximumDepth -gt 0) {
        # Older operating systems don't support the -depth parameter, this function was created for backwards compatability
        $AllFiles = @()
        foreach ($Directory in $DirectoriesToSearch){
            $AllFiles += Get-ChildItemDepth -Path "$Directory" -Depth $MaximumDepth -Force -ErrorAction SilentlyContinue
        }
    }
    else {
        $AllFiles = @()
        foreach ($Directory in $DirectoriesToSearch){
            $AllFiles += Get-ChildItem -Path "$Directory" -Force -ErrorAction SilentlyContinue
        }
    }
    $AllFiles = $AllFiles | Sort-Object -Unique

    $foundlist = @()
    foreach ($File in $AllFiles){
        foreach ($SearchItem in $FilesToSearch) {
            if ($FileHashSelection -eq 'Filename') {
                if ($File.name -match $SearchItem.trim()){
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
            if ($FileHashSelection -eq 'MD5') {
                $FileHash = Get-FileHash -Path $($File.FullName) -Algorithm 'MD5'
                if ($FileHash.Hash -eq $SearchItem.trim()){
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHash'          -Value $FileHash.Hash       -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHashAlgorithm' -Value $FileHash.Algorithm  -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'ScriptNote'        -Value $FileHash.ScriptNote -Force
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
            elseif ($FileHashSelection -eq 'SHA1') {
                $FileHash = Get-FileHash -Path $($File.FullName) -Algorithm 'SHA1'
                if ($FileHash.Hash -eq $SearchItem.trim()){
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHash'          -Value $FileHash.Hash       -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHashAlgorithm' -Value $FileHash.Algorithm  -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'ScriptNote'        -Value $FileHash.ScriptNote -Force
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
            elseif ($FileHashSelection -eq 'SHA256') {
                $FileHash = Get-FileHash -Path $($File.FullName) -Algorithm 'SHA256'
                if ($FileHash.Hash -eq $SearchItem.trim()){
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHash'          -Value $FileHash.Hash       -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHashAlgorithm' -Value $FileHash.Algorithm  -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'ScriptNote'        -Value $FileHash.ScriptNote -Force
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
            elseif ($FileHashSelection -eq 'SHA384') {
                $FileHash = Get-FileHash -Path $($File.FullName) -Algorithm 'SHA384'
                if ($FileHash.Hash -eq $SearchItem.trim()){
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHash'          -Value $FileHash.Hash       -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHashAlgorithm' -Value $FileHash.Algorithm  -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'ScriptNote'        -Value $FileHash.ScriptNote -Force
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
            elseif ($FileHashSelection -eq 'SHA512') {
                $FileHash = Get-FileHash -Path $($File.FullName) -Algorithm 'SHA512'
                if ($FileHash.Hash -eq $SearchItem.trim()){
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHash'          -Value $FileHash.Hash       -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHashAlgorithm' -Value $FileHash.Algorithm  -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'ScriptNote'        -Value $FileHash.ScriptNote -Force
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
            elseif ($FileHashSelection -eq 'RIPEMD160') {
                $FileHash = Get-FileHash -Path $($File.FullName) -Algorithm 'RIPEMD160'
                if ($FileHash.Hash -eq $SearchItem.trim()){
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHash'          -Value $FileHash.Hash       -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'FileHashAlgorithm' -Value $FileHash.Algorithm  -Force
                    $File | Add-Member -MemberType NoteProperty -Name 'ScriptNote'        -Value $FileHash.ScriptNote -Force
                    if ($File.FullName -notin $FoundList) { $foundlist += $File }
                }
            }
        }
    }
    return $FoundList
}


# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUYPEyNNt1nRQJzXA25bdmQN8S
# 8z+gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUlsVATWyyRJMsJdIfdi9HKsohXXowDQYJKoZI
# hvcNAQEBBQAEggEAycxM6ZSXzLu1ShvL2I7GZj/45h94UKfl2BB/lar0DpJvJObc
# 7dD5w9jv/QjUXN0tmfjDSH1k+iKkesl55wpxQ3xOytWywB+mOC/2KT+woL7woHTZ
# tUoZGesasu3jKQlkQWoXq60DaxzASFQI0gqMe8X5uuF+mF8midqUXIkBzpN9dWZQ
# LKvlz5XcKp1oT/fV/tQM/EqZHEGpiSmcYybhgptancs4WxMQqIENsVsw56d96gcZ
# AVUoH3GpTC903+6GgWIagNHEf9Nv+dcHgtbAPbS/P/4yDILnPhpb9SFSM+qMN/Uk
# Vi3Ufhis2T+VGIprKVCUsD/2E0BRXn6+rMUo2w==
# SIG # End signature block
