$CollectionName = "Alternate Data Streams"
$ExecutionStartTime = Get-Date

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

foreach ($TargetComputer in $script:ComputerList) {
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

    $DirectoriesToSearch = $FileSearchAlternateDataStreamDirectoryRichTextbox.Lines
    $MaximumDepth        = $FileSearchAlternateDataStreamMaxDepthTextbox.text

    if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
        if (!$script:Credential) { Create-NewCredentials }
        Invoke-Command -ScriptBlock ${function:Get-AlternateDataStream} `
        -ArgumentList @($DirectoriesToSearch,$MaximumDepth) `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -Credential $script:Credential
    }
    else {
        Invoke-Command -ScriptBlock ${function:Get-AlternateDataStream} `
        -ArgumentList @($DirectoriesToSearch,$MaximumDepth) `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
    }
}
#Note... properties selected elsewhere: PSComputerName, Mode, Length, Name, Extension, Attributes, FullName, CreationTime, LastWriteTime, LastAccessTime, BaseName, Directory, PSIsContainer
Monitor-Jobs -CollectionName $CollectionName -MonitorMode
#Monitor-Jobs -CollectionName $CollectionName -SaveProperties @"
#@('PSComputerName', 'FileName', 'Stream', 'StreamDataSample', 'ZoneId' , 'Length')
#"@

#Commented out because the above -MonitorMode implementation doesn't save files individually
#Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime

$FileSearchAlternateDataStreamDirectoryExtractStreamDataButton.BackColor = 'LightGreen'

$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

