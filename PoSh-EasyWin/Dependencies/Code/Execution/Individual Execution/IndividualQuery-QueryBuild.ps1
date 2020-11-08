$CollectionName = ($script:CustomQueryScriptBlockTextbox.text -split ' ')[0]
$ExecutionStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

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
Monitor-Jobs -CollectionName $CollectionName -MonitorMode
#Commented out because the above -MonitorMode implementation doesn't save files individually
#Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime

$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")


