# This function is created within a string variable as it is used with an an agrument for Invoke-Command
# It is initialized below with an Invoke-Expression

$GetFileHash = @'
function Get-FileHash{
    param (
        [string]$Path,
        [string]$Algorithm
    )
    if ($Algorithm -eq 'MD5') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'SHA1') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA1CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'SHA256') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA256CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'SHA384') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA384CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'SHA512') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.SHA512CryptoServiceProvider
    }
    elseif ($Algorithm -eq 'RIPEMD160') {
        $HashAlgorithm = New-Object -TypeName System.Security.Cryptography.RIPEMD160Managed
    }


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
'@
Invoke-Expression -Command $GetFileHash



