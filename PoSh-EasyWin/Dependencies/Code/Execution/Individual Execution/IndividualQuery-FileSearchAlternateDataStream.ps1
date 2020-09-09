$CollectionName = "Alternate Data Streams"
$CollectionCommandStartTime = Get-Date 

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")                    
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

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
Monitor-Jobs -CollectionName $CollectionName -SaveProperties @"
@('PSComputerName', 'FileName', 'Stream', 'StreamDataSample', 'ZoneId' , 'Length')
"@

$FileSearchAlternateDataStreamDirectoryExtractStreamDataButton.BackColor = 'LightGreen'

$CollectionCommandEndTime  = Get-Date                    
$CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

Compile-CsvFiles -LocationOfCSVsToCompile   "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)\$($CollectionName)*.csv" `
                 -LocationToSaveCompiledCSV "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).csv"

Compile-XmlFiles -LocationOfXmlsToCompile   "$($script:CollectionSavedDirectoryTextBox.Text)\Results By Endpoints\$($CollectionName)\$($CollectionName)*.xml" `
                 -LocationToSaveCompiledXml "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).xml"

Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Compiling CSV Files"
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "$($script:CollectionSavedDirectoryTextBox.Text)\$((($Command.Name) -split ' -- ')[1]) - $($Command.Type).csv"
