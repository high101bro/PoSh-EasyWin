$ExecutionStartTime = Get-Date
$CollectionName = "Accounts Currently Logged In via PowerShell Session"

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0


foreach ($TargetComputer in $script:ComputerList) {
    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Create-NewCredentials }

        Start-Job -ScriptBlock {
            param($TargetComputer,$script:Credential)
            Get-WSManInstance -ComputerName $TargetComputer -ResourceURI Shell -Enumerate -Credential $script:Credential | Select-Object *
        } `
        -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -ArgumentList @($TargetComputer,$script:Credential)

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Get-WSManInstance -ComputerName $TargetComputer -ResourceURI Shell -Enumerate -Credential $script:Credential"
    }
    else {
        Start-Job -ScriptBlock {
            param($TargetComputer)
            Get-WSManInstance -ComputerName $TargetComputer -ResourceURI Shell -Enumerate
        } `
        -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
        -ArgumentList @($TargetComputer,$null)

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Get-WSManInstance -ComputerName $TargetComputer -ResourceURI Shell -Enumerate"
    }
}
Monitor-Jobs -CollectionName $CollectionName -MonitorMode
#Commented out because the above -MonitorMode implementation doesn't save files individually
#Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime

$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

