$CollectionName = "Alternate Data Streams"
$ExecutionStartTime = Get-Date

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

$DirectoriesToSearch = $FileSearchAlternateDataStreamDirectoryRichTextbox.Lines
$MaximumDepth        = $FileSearchAlternateDataStreamMaxDepthTextbox.text

$script:MonitorJobScriptBlock = {
    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

        if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
            if (!$script:Credential) { Create-NewCredentials }
            Invoke-Command -ScriptBlock ${function:Search-AlternateDataStream} `
            -ArgumentList @($DirectoriesToSearch,$MaximumDepth) `
            -ComputerName $TargetComputer `
            -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
            -Credential $script:Credential
        }
        else {
            Invoke-Command -ScriptBlock ${function:Search-AlternateDataStream} `
            -ArgumentList @($DirectoriesToSearch,$MaximumDepth) `
            -ComputerName $TargetComputer `
            -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
        }
    }
}
Invoke-Command -ScriptBlock $script:MonitorJobScriptBlock

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
$SearchString = ''
foreach ($item in $DirectoriesToSearch) {$SearchString += "$item`n" }

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
Maximum Depth:
===========================================================================
$MaximumDepth

===========================================================================
Directories To Search:
===========================================================================
$($SearchString.trim())

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript $script:MonitorJobScriptBlock -SmithFlag 'RetrieveADS' -InputValues $InputValues
}

elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
    Monitor-Jobs -CollectionName $CollectionName -SaveProperties @"
@('PSComputerName', 'FileName', 'Stream', 'StreamDataSample', 'ZoneId' , 'Length')
"@
    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
}


$FileSearchAlternateDataStreamDirectoryExtractStreamDataButton.BackColor = 'LightGreen'

$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

