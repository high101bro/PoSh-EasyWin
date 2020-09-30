$CollectionName = ($script:CustomQueryScriptBlockTextbox.text -split ' ')[0]
$CollectionCommandStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

#$OutputFilePath      = "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName"

foreach ($TargetComputer in $script:ComputerList) {
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName


    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Create-NewCredentials }

        Invoke-Command -ScriptBlock {
            param($script:ShowCommandQueryBuild)
            Invoke-Expression -Command $script:ShowCommandQueryBuild
        } `
        -ArgumentList $script:ShowCommandQueryBuild `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -Credential $script:Credential

        Create-LogEntry -LogFile $LogFile -Message "Invoke-Command -ScriptBlock { param(`$script:ShowCommandQueryBuild) Invoke-Expression -Command $script:ShowCommandQueryBuild } -ComputerName $TargetComputer -ArgumentList `$script:ShowCommandQueryBuild  -Credential `$script:Credential"
    }
    else {
        Invoke-Command -ScriptBlock {
            param($script:ShowCommandQueryBuild)
            Invoke-Expression -Command $script:ShowCommandQueryBuild
        } `
        -ArgumentList $script:ShowCommandQueryBuild `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

        Create-LogEntry -LogFile $LogFile -Message "Invoke-Command -ScriptBlock { param(`$script:ShowCommandQueryBuild) Invoke-Expression -Command $script:ShowCommandQueryBuild } -ComputerName $TargetComputer -ArgumentList `$script:ShowCommandQueryBuild"
    }
}
Monitor-Jobs -CollectionName $CollectionName

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


