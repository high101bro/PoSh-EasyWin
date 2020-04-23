$CollectionCommandStartTime = Get-Date
$CollectionName = "Alternate Data Stream Search"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$OutputFilePath      = "$($script:CollectionSavedDirectoryTextBox.Text)\Alternate Data Streams"
$DirectoriesToSearch = $FileSearchAlternateDataStreamDirectoryRichTextbox.Lines
$MaximumDepth        = $FileSearchAlternateDataStreamMaxDepthTextbox.text


#Invoke-Command -ScriptBlock {Get-Process} -Session $PSSession | Export-Csv -Path $OutputFilePath -NoTypeInformation -Force
Invoke-Command -ScriptBlock {
    param($DirectoriesToSearch,$MaximumDepth,$GetChildItemDepth)
    function Get-AlternateDataStreamSearch {
        param($DirectoriesToSearch,$MaximumDepth)
        if ([int]$MaximumDepth -gt 0) {
            Invoke-Expression $GetChildItemDepth
            
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
            $Ads | Add-Member -MemberType NoteProperty -Name StreamData -Value $AdsData
            if     (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamData -match 'ZoneID=0')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 0] Local Machine Zone: The most trusted zone for content that exists on the local computer." }
            elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamData -match 'ZoneID=1')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 1] Local Intranet Zone: For content located on an organization’s intranet." }
            elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamData -match 'ZoneID=2')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 2] Trusted Sites Zone: For content located on Web sites that are considered more reputable or trustworthy than other sites on the Internet." }
            elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamData -match 'ZoneID=3')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 3] Internet Zone: For Web sites on the Internet that do not belong to another zone." }
            elseif (($Ads.Stream -eq 'Zone.Identifier') -and ($Ads.StreamData -match 'ZoneID=4')) { $Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 4] Restricted Sites Zone: For Web sites that contain potentially-unsafe content." }
            else {$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "N/A"}
            $Ads | Add-Member -MemberType NoteProperty -Name StreamDataSample -Value $(($AdsData | Out-String)[0..100] -join "")
            $Ads | Add-Member -MemberType NoteProperty -Name FileSize -Value $(
                if     ($Ads.Length -gt 1000000000) { "$([Math]::Round($($Ads.Length / 1gb),2)) GB" }
                elseif ($Ads.Length -gt 1000000)    { "$([Math]::Round($($Ads.Length / 1mb),2)) MB" }
                elseif ($Ads.Length -gt 1000)       { "$([Math]::Round($($Ads.Length / 1kb),2)) KB" }
                elseif ($Ads.Length -le 1000)       { "$($Ads.Length) Bytes" }
            )
        }
        $AdsFound
    }
    Get-AlternateDataStreamSearch -DirectoriesToSearch $DirectoriesToSearch -MaximumDepth $MaximumDepth
} -ArgumentList @($DirectoriesToSearch,$MaximumDepth,$GetChildItemDepth) -Session $PSSession | Select-Object -Property PSComputerName, FileName, Length, FileSize, Stream, @{Name="StreamDataSample";Expression={$($($_.StreamData | Out-String)[0..100] -join '')}}, ZoneId `
| Set-Variable SessionData
# note...properties selected elsewhere: PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer
$SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
$SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
Remove-Variable -Name SessionData -Force

$FileSearchAlternateDataStreamDirectoryExtractStreamDataButton.BackColor = 'LightGreen'

$ResultsListBox.Items.RemoveAt(1)
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $CollectionCommandStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value   += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500
