function Query-AlternateDataStream {
    $CollectionName = "Alternate Data Stream"
    $CollectionCommandStartTime = Get-Date 
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")                    
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        param(
            $CollectedDataTimeStampDirectory, 
            $IndividualHostResults, 
            $CollectionName, 
            $TargetComputer
        )
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        $DirectoriesToSearch = $FileSearchAlternateDataStreamDirectoryTextbox.Text -split "`r`n"
        $MaximumDepth        = $FileSearchAlternateDataStreamMaxDepthTextbox.text

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $QueryCredentialParam = ", $script:Credential"
            $QueryCredential      = "-Credential $script:Credential"
        }
        else {
            $QueryCredentialParam = $null
            $QueryCredential      = $null        
        }
$QueryJob = @"
        Start-Job -Name "PoSh-ACME: `$(`$CollectionName) -- `$(`$TargetComputer)" -ScriptBlock {
            param(`$DirectoriesToSearch, `$TargetComputer, `$MaximumDepth, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
            [System.Threading.Thread]::CurrentThread.Priority = 'High'
            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

            foreach (`$DirectoryPath in `$DirectoriesToSearch) {
                `$FilesFound = Invoke-Command -ComputerName `$TargetComputer $QueryCredential -ScriptBlock {
                    param(`$DirectoryPath, `$MaximumDepth, `$TargetComputer)

                    $GetChildItemRecurse

                    Get-ChildItemRecurse -Path `$DirectoryPath -Depth `$MaximumDepth
                } -ArgumentList @(`$DirectoryPath, `$MaximumDepth, `$TargetComputer)
                    
                `$AdsFound = `$FilesFound | ForEach-Object { Get-Item `$_.FullName -Force -Stream * -ErrorAction SilentlyContinue } | Where-Object stream -ne ':`$DATA'
                foreach (`$Ads in `$AdsFound) {
                    `$AdsData = Get-Content -Path "`$(`$Ads.FileName)" -Stream "`$(`$Ads.Stream)"
                    `$Ads | Add-Member -MemberType NoteProperty -Name PSComputerName -Value `$TargetComputer
                    `$Ads | Add-Member -MemberType NoteProperty -Name StreamData -Value `$AdsData
                    if     ((`$Ads.Stream -eq 'Zone.Identifier') -and (`$Ads.StreamData -match 'ZoneID=0')) { `$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 0] Local Machine Zone: The most trusted zone for content that exists on the local computer." }
                    elseif ((`$Ads.Stream -eq 'Zone.Identifier') -and (`$Ads.StreamData -match 'ZoneID=1')) { `$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 1] Local Intranet Zone: For content located on an organization’s intranet." }
                    elseif ((`$Ads.Stream -eq 'Zone.Identifier') -and (`$Ads.StreamData -match 'ZoneID=2')) { `$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 2] Trusted Sites Zone: For content located on Web sites that are considered more reputable or trustworthy than other sites on the Internet." }
                    elseif ((`$Ads.Stream -eq 'Zone.Identifier') -and (`$Ads.StreamData -match 'ZoneID=3')) { `$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 3] Internet Zone: For Web sites on the Internet that do not belong to another zone." }
                    elseif ((`$Ads.Stream -eq 'Zone.Identifier') -and (`$Ads.StreamData -match 'ZoneID=4')) { `$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "[ZoneID 4] Restricted Sites Zone: For Web sites that contain potentially-unsafe content." }
                    else {`$Ads | Add-Member -MemberType NoteProperty -Name ZoneID -Value "N/A"}                           
                }
            }        
            `$AdsFound | Select-Object -Property PSComputerName, FileName, Stream, @{Name="StreamDataSample";Expression={`$(`$(`$_.StreamData | Out-String)[0..100] -join '')}}, ZoneId , Length | Export-CSV "`$(`$IndividualHostResults)\`$(`$CollectionName)\`$(`$CollectionName)-`$(`$TargetComputer).csv" -NoTypeInformation
        } -ArgumentList @(`$DirectoriesToSearch, `$TargetComputer, `$MaximumDepth, `$IndividualHostResults, `$CollectionName $QueryCredentialParam)
"@
    Invoke-Expression -Command $QueryJob
    }
    Monitor-Jobs
    $CollectionCommandEndTime  = Get-Date                    
    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
    Compile-CsvFiles -LocationOfCSVsToCompile   "$($IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($CollectedDataTimeStampDirectory)\$($CollectionName).csv"
}