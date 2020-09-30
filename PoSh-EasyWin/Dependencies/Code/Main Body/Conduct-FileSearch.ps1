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

