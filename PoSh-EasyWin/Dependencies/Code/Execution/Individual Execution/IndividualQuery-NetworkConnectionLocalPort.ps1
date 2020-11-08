$CollectionName = "Network Connection - Local Port"
$ExecutionStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
foreach ($TargetComputer in $script:ComputerList) {
    param(
        $script:CollectedDataTimeStampDirectory,
        $script:IndividualHostResults,
        $CollectionName,
        $TargetComputer
    )
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName


    $NetworkConnectionSearchLocalPort = $NetworkConnectionSearchLocalPortRichTextbox.Lines
    #$NetworkConnectionSearchLocalPort = @()
    #foreach ($Port in $($NetworkConnectionSearchLocalPortRichTextbox.Text).split("`r`n")){ $NetworkConnectionSearchLocalPort += $Port }


    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Create-NewCredentials }

        Invoke-Command -ScriptBlock ${function:Query-NetworkConnection} `
        -ArgumentList @($null,$null,$NetworkConnectionSearchLocalPort,$null) `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -Credential $script:Credential `
        | Select-Object PSComputerName, *
    }
    else {
        Invoke-Command -ScriptBlock ${function:Query-NetworkConnection} `
        -ArgumentList @($null,$null,$NetworkConnectionSearchLocalPort,$null) `
        -ComputerName $TargetComputer `
        -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        | Select-Object PSComputerName, *
    }
}

Monitor-Jobs -CollectionName $CollectionName -MonitorMode
#Commented out because the above -MonitorMode implementation doesn't save files individually
#Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime

$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")


