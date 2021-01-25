function Get-AlternateDataStream {
    param($DirectoriesToSearch,$MaximumDepth)
    if ([int]$MaximumDepth -gt 0) {
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

        # Older operating systems don't support the -depth parameter, needed to create a function to do so for backwards compatability
        #Get-ChildItem -Path $DirectoryPath -Depth $MaximumDepth

        $AllFiles = Get-ChildItemDepth -Path $DirectoriesToSearch -Depth $MaximumDepth
    }
    else {
        $AllFiles = Get-ChildItem -Path $DirectoriesToSearch -Force -ErrorAction SilentlyContinue
    }
    $AdsFound = $AllFiles | ForEach-Object { Get-Item $_.FullName -Force -Stream * -ErrorAction SilentlyContinue } | Where-Object stream -ne ':$DATA'
    foreach ($Ads in $AdsFound) {
        $AdsData = Get-Content -Path "$($Ads.FileName)" -Stream "$($Ads.Stream)"
        $Ads | Add-Member -MemberType NoteProperty -Name PSComputerName -Value $($Env:ComputerName)
        #too much... $Ads | Add-Member -MemberType NoteProperty -Name StreamData -Value $AdsData
        $Ads | Add-Member -MemberType NoteProperty -Name StreamDataSample -Value $(($AdsData | Out-String)[0..1000] -join "")
        if     (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=0')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 0] Local Machine Zone: The most trusted zone for content that exists on the local computer." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=1')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 1] Local Intranet Zone: For content located on an organization’s intranet." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=2')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 2] Trusted Sites Zone: For content located on Web sites that are considered more reputable or trustworthy than other sites on the Internet." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=3')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 3] Internet Zone: For Web sites on the Internet that do not belong to another zone." }
        elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamDataSample -match 'ZoneID=4')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 4] Restricted Sites Zone: For Web sites that contain potentially-unsafe content." }
        else {$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "N/A"}
        $Ads | Add-Member -MemberType NoteProperty -Name FileSize -Value $(
            if     ($Ads.Length -gt 1000000000) { "$([Math]::Round($($Ads.Length / 1gb),2)) GB" }
            elseif ($Ads.Length -gt 1000000)    { "$([Math]::Round($($Ads.Length / 1mb),2)) MB" }
            elseif ($Ads.Length -gt 1000)       { "$([Math]::Round($($Ads.Length / 1kb),2)) KB" }
            elseif ($Ads.Length -le 1000)       { "$($Ads.Length) Bytes" }
        )
    }
    $AdsFound
}

