$ExecutionStartTime = Get-Date
$CollectionName = "Accounts Currently Logged In via PowerShell Session"

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0


$script:MonitorJobScriptBlock = {
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
}
Invoke-Command -ScriptBlock $script:MonitorJobScriptBlock

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}

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

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript $script:MonitorJobScriptBlock -InputValues $InputValues
}
elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
    Monitor-Jobs -CollectionName $CollectionName
    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
}


$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

