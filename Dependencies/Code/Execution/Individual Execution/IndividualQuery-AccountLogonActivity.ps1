$ExecutionStartTime = Get-Date
$CollectionName = "Account Logon Activity"

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$AccountsStartTimePickerValue = $AccountsStartTimePicker.Value
$AccountsStopTimePickerValue  = $AccountsStopTimePicker.Value
$AccountActivityTextboxtext = $AccountActivityTextbox.lines | Where-Object {$_ -ne ''}

function MonitorJobScriptBlock {
    param(
        $ExecutionStartTime,
        $CollectionName,
        $AccountsStartTimePickerValue,
        $AccountsStopTimePickerValue,
        $AccountActivityTextboxtext        
    )

    foreach ($TargetComputer in $script:ComputerList) {
        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }

            Invoke-Command -ScriptBlock ${function:Get-AccountLogonActivity} `
            -ArgumentList @($AccountsStartTimePickerValue,$AccountsStopTimePickerValue,$AccountActivityTextboxtext) `
            -ComputerName $TargetComputer `
            -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
            -Credential $script:Credential

            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `${function:Get-AccountLogonActivity} -ArgumentList @(`$AccountsStartTimePickerValue,`$AccountsStopTimePickerValue,`$AccountActivityTextboxtext) -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
        }
        else {
            Invoke-Command -ScriptBlock ${function:Get-AccountLogonActivity} `
            -ArgumentList @($AccountsStartTimePickerValue,$AccountsStopTimePickerValue,$AccountActivityTextboxtext) `
            -ComputerName $TargetComputer `
            -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `${function:Get-AccountLogonActivity} -ArgumentList @(`$AccountsStartTimePickerValue,`$AccountsStopTimePickerValue,`$AccountActivityTextboxtext) -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)'"
        }
    }
}
Invoke-Command -ScriptBlock ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$AccountsStartTimePickerValue,$AccountsStopTimePickerValue,$AccountActivityTextboxtext)

$EndpointString = ''
foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}
$SearchString = ''
foreach ($item in $AccountActivityTextboxtext) {$SearchString += "$item`n" }

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
Event Start DateTime:
===========================================================================
$AccountsStartTimePickerValue

===========================================================================
Event End DateTime:
===========================================================================
$AccountsStopTimePickerValue

===========================================================================
Accounts:
===========================================================================
$SearchString

"@

if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
    Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SMITH -SmithScript ${function:MonitorJobScriptBlock} -ArgumentList @($ExecutionStartTime,$CollectionName,$AccountsStartTimePickerValue,$AccountsStopTimePickerValue,$AccountActivityTextboxtext) -InputValues $InputValues
}
elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
    Monitor-Jobs -CollectionName $CollectionName
    Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
}


$CollectionCommandEndTime  = Get-Date
$CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")




