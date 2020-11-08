$ExecutionStartTime = Get-Date
$CollectionName = "Event Logs - Event IDs To Monitor"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$EventLogsEventIDsToMonitorCheckListBoxCheckedItems = $EventLogsEventIDsToMonitorCheckListBox.CheckedItems
$EventLogsMaximumCollectionTextBoxText = $EventLogsMaximumCollectionTextBox.Text
$EventLogsStartTimePickerChecked       = $EventLogsStartTimePicker.Checked
$EventLogsStopTimePickerChecked        = $EventLogsStopTimePicker.Checked
$EventLogsStartTimePickerValue         = $EventLogsStartTimePicker.Value
$EventLogsStopTimePickerValue          = $EventLogsStopTimePicker.Value


function Query-EventLogLogsEventIDsIndividualSelectionSessionBased {
    param(
        $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
        $EventLogsMaximumCollectionTextBoxText,
        $EventLogsStartTimePickerChecked,
        $EventLogsStopTimePickerChecked,
        $EventLogsStartTimePickerValue,
        $EventLogsStopTimePickerValue,
        [switch]$RPC,
        $TargetComputer,
        $Script:Credential
    )
    # Variables begins with an open "(
    $EventLogsEventIDsToMonitorCheckListBoxFilter = '('
    foreach ($Checked in $EventLogsEventIDsToMonitorCheckListBoxCheckedItems) {
        # Get's just the EventID from the checkbox
        $Checked = $($Checked -split " ")[0]

        $EventLogsEventIDsToMonitorCheckListBoxFilter += "(EventCode='$Checked') OR "
    }
    # Replaces the ' OR ' at the end of the varable with a closing )"
    $Filter = $EventLogsEventIDsToMonitorCheckListBoxFilter -replace " OR $",")"

    # Builds the Event Log Query Command
    $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
    if ($EventLogsMaximumCollectionTextBoxText -eq $null -or $EventLogsMaximumCollectionTextBoxText -eq '' -or $EventLogsMaximumCollectionTextBoxText -eq 0) { $EventLogQueryMax = $null}
    else { $EventLogQueryMax = "-First $($EventLogsMaximumCollectionTextBoxText)" }
    if ( $EventLogsStartTimePickerChecked -and $EventLogsStopTimePickerChecked ) {
        $EventLogQueryFilter = @"
-Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePickerValue)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStopTimePickerValue)))'))"
"@
    }
    else { $EventLogQueryFilter = "-Filter `"$Filter`""}
    $EventLogQueryPipe = @"
| Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
"@

    if ($RPC){
        Invoke-Expression -Command "$EventLogQueryCommand -ComputerName $TargetComputer -Credential `$Script:Credential $EventLogQueryFilter $EventLogQueryPipe"

    "$EventLogQueryCommand -ComputerName $TargetComputer -Credential `$Script:Credential $EventLogQueryFilter $EventLogQueryPipe"|ogv
    }
    else {
        Invoke-Expression "$EventLogQueryCommand $EventLogQueryFilter $EventLogQueryPipe"
    }
}


foreach ($TargetComputer in $script:ComputerList) {
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

    if ($EventLogWinRMRadioButton.Checked) {
        if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
            if (!$script:Credential) { Create-NewCredentials }

            Invoke-Command -ScriptBlock ${function:Query-EventLogLogsEventIDsIndividualSelectionSessionBased} `
            -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) `
            -ComputerName $TargetComputer `
            -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
            -Credential $script:Credential
        }
        else {
            Invoke-Command -ScriptBlock ${function:Query-EventLogLogsEventIDsIndividualSelectionSessionBased} `
            -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) `
            -ComputerName $TargetComputer `
            -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
        }
    }
    else {
        if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
            if (!$script:Credential) { Create-NewCredentials }

            Start-Job -ScriptBlock {
                param(
                    $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
                    $EventLogsMaximumCollectionTextBoxText,
                    $EventLogsStartTimePickerChecked,
                    $EventLogsStopTimePickerChecked,
                    $EventLogsStartTimePickerValue,
                    $EventLogsStopTimePickerValue,
                    $TargetComputer,
                    $script:Credential
                )

                # Variables begins with an open "(
                $EventLogsEventIDsToMonitorCheckListBoxFilter = '('
                foreach ($Checked in $EventLogsEventIDsToMonitorCheckListBoxCheckedItems) {
                    # Get's just the EventID from the checkbox
                    $Checked = $($Checked -split " ")[0]

                    $EventLogsEventIDsToMonitorCheckListBoxFilter += "(EventCode='$Checked') OR "
                }
                # Replaces the ' OR ' at the end of the varable with a closing )"
                $Filter = $EventLogsEventIDsToMonitorCheckListBoxFilter -replace " OR $",")"

                # Builds the Event Log Query Command
                $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
                if ($EventLogsMaximumCollectionTextBoxText -eq $null -or $EventLogsMaximumCollectionTextBoxText -eq '' -or $EventLogsMaximumCollectionTextBoxText -eq 0) { $EventLogQueryMax = $null}
                else { $EventLogQueryMax = "-First $($EventLogsMaximumCollectionTextBoxText)" }
                if ( $EventLogsStartTimePickerChecked -and $EventLogsStopTimePickerChecked ) {
                    $EventLogQueryFilter = @"
-Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePickerValue)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStopTimePickerValue)))'))"
"@
                }
                else { $EventLogQueryFilter = "-Filter `"$Filter`""}
                $EventLogQueryPipe = @"
| Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
"@

                Invoke-Expression -Command "$EventLogQueryCommand -ComputerName $TargetComputer -Credential `$Script:Credential $EventLogQueryFilter $EventLogQueryPipe"
            } `
            -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
            -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer,$script:Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param(
                    $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
                    $EventLogsMaximumCollectionTextBoxText,
                    $EventLogsStartTimePickerChecked,
                    $EventLogsStopTimePickerChecked,
                    $EventLogsStartTimePickerValue,
                    $EventLogsStopTimePickerValue,
                    $TargetComputer
                )

                # Variables begins with an open "(
                $EventLogsEventIDsToMonitorCheckListBoxFilter = '('
                foreach ($Checked in $EventLogsEventIDsToMonitorCheckListBoxCheckedItems) {
                    # Get's just the EventID from the checkbox
                    $Checked = $($Checked -split " ")[0]

                    $EventLogsEventIDsToMonitorCheckListBoxFilter += "(EventCode='$Checked') OR "
                }
                # Replaces the ' OR ' at the end of the varable with a closing )"
                $Filter = $EventLogsEventIDsToMonitorCheckListBoxFilter -replace " OR $",")"

                # Builds the Event Log Query Command
                $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
                if ($EventLogsMaximumCollectionTextBoxText -eq $null -or $EventLogsMaximumCollectionTextBoxText -eq '' -or $EventLogsMaximumCollectionTextBoxText -eq 0) { $EventLogQueryMax = $null}
                else { $EventLogQueryMax = "-First $($EventLogsMaximumCollectionTextBoxText)" }
                if ( $EventLogsStartTimePickerChecked -and $EventLogsStopTimePickerChecked ) {
                    $EventLogQueryFilter = @"
-Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePickerValue)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStopTimePickerValue)))'))"
"@
                }
                else { $EventLogQueryFilter = "-Filter `"$Filter`""}
                $EventLogQueryPipe = @"
| Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
"@

                Invoke-Expression -Command "$EventLogQueryCommand -ComputerName $TargetComputer $EventLogQueryFilter $EventLogQueryPipe"
            } `
            -Name "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
            -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer)
        }
    }
}

Monitor-Jobs -CollectionName $CollectionName -MonitorMode
#Commented out because the above -MonitorMode implementation doesn't save files individually
#Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime


