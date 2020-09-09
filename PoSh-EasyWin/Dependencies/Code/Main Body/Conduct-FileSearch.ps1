function Conduct-FileSearch {
    param($DirectoriesToSearch,$FilesToSearch,$MaximumDepth,$GetChildItemDepth,$GetFileHash,$FileHashSelection)
    if ([int]$MaximumDepth -gt 0) {
        Invoke-Expression $GetChildItemDepth
        Invoke-Expression $GetFileHash
        
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