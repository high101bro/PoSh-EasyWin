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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3JsfWlm8kEO3tjkEuc8zhJYI
# m6ygggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUy96sRaPivPCv8shW1uNL1P0VDlwwDQYJKoZI
# hvcNAQEBBQAEggEAeLrBcEmH2VZ8kNaTrZbiWZljqjcYbUDlS8JdiA/+OCJVaYRN
# 0Ju4XXo8jxLBvQAN2l7inQhPVzixbW7u9MlZsaCh/V622UDkez6MmKIp0oYxM8Ni
# RedGgjTH5T05K2HPfbsmu0UTXLRuIppSHHqdaeE2MVcj+A0HdjDuNxvGjBj9+3R3
# r17ycKti+M+6EkmSETE7asBHH4lwx2b7qfVW1zFB10eHt+mYYGXrHnXbi6MIoF+I
# f1pwW6+CKqi1g5pjsi6gZzvJ7CEbcd5y7+23IWvFdIy00vbWPmWceUy1TyT3gq5z
# 7UaEg+JsR572hApCGw7eCRHF2fM8AgSePWkdMA==
# SIG # End signature block
