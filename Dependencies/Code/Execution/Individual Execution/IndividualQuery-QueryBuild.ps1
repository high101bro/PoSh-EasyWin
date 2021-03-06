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

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
$SearchString = ''
#foreach ($item in $NetworkConnectionSearchDNSCache) {$SearchString += "$item`n" }

$InputValues = @"
===========================================================================
Collection Name:
===========================================================================
$CollectionName

===========================================================================
Execution Time:
===========================================================================
$ExecutionStartTime

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoints:
===========================================================================
$($EndpointString.trim())

===========================================================================
UNDER DEVELOPMENT
===========================================================================
$($SearchString.trim())

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -InputValues $InputValues
}
elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
    Monitor-Jobs -CollectionName $CollectionName
    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
}


$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")


