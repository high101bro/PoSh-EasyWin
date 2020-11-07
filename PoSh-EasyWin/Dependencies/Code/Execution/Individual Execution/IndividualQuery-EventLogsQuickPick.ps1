#BATMAN######################Query-EventLog -CollectionName $Query.Name -Filter $Query.Filter

$ExecutionStartTime = Get-Date

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: Event ID Quick Selection")

$script:ProgressBarEndpointsProgressBar.Value = 0

$EventLogsMaximumCollectionTextBoxText = $EventLogsMaximumCollectionTextBox.Text
$EventLogsStartTimePickerChecked       = $EventLogsStartTimePicker.Checked
$EventLogsStopTimePickerChecked        = $EventLogsStopTimePicker.Checked
$EventLogsStartTimePickerValue         = $EventLogsStartTimePicker.Value
$EventLogsStopTimePickerValue          = $EventLogsStopTimePicker.Value

function Query-EventLogLogsEventIDsManualEntrySessionBased {
    param(
        $Filter,
        $EventLogsMaximumCollectionTextBoxText,
        $EventLogsStartTimePickerChecked,
        $EventLogsStopTimePickerChecked,
        $EventLogsStartTimePickerValue,
        $EventLogsStopTimePickerValue
    )
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
    $EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryFilter $EventLogQueryPipe"
    Invoke-Expression $EventLogQueryBuild
}









if ($EventLogWinRMRadioButton.Checked) {
    if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
        if (!$script:Credential) { Create-NewCredentials }

        foreach ($Query in $script:EventLogQueries) {
            if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
                $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")

                Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                        -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                        -TargetComputer $TargetComputer
                Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

                $CollectionName = "Event Logs - $($Query.Name)"

                foreach ($TargetComputer in $script:ComputerList) {
                    Invoke-Command -ScriptBlock ${function:Query-EventLogLogsEventIDsManualEntrySessionBased} `
                    -ArgumentList @($Query.Filter,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                    -Credential $script:Credential
                }
                Monitor-Jobs -CollectionName $CollectionName -MonitorMode
                #Commented out because the above -MonitorMode implementation doesn't save files individually
                #Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
            }
        }
    }
    else {

        foreach ($Query in $script:EventLogQueries) {
            if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
                $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")

                Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                        -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                        -TargetComputer $TargetComputer
                Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

                $CollectionName = "Event Logs - $($Query.Name)"

                foreach ($TargetComputer in $script:ComputerList) {
                    Invoke-Command -ScriptBlock ${function:Query-EventLogLogsEventIDsManualEntrySessionBased} `
                    -ArgumentList @($Query.Filter,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) `
                    -ComputerName $TargetComputer `
                    -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
                }
                Monitor-Jobs -CollectionName $CollectionName -MonitorMode
                #Commented out because the above -MonitorMode implementation doesn't save files individually
                #Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
            }
        }
    }
}
else {
    if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
        if (!$script:Credential) { Create-NewCredentials }

        foreach ($Query in $script:EventLogQueries) {
            if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
                $CollectionName = "Event Logs - $($Query.Name)"
                $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")

                Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                        -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                        -TargetComputer $TargetComputer
                Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

                foreach ($TargetComputer in $script:ComputerList) {
                    Start-Job -ScriptBlock {
                        param(
                            $Filter,
                            $EventLogsMaximumCollectionTextBoxText,
                            $EventLogsStartTimePickerChecked,
                            $EventLogsStopTimePickerChecked,
                            $EventLogsStartTimePickerValue,
                            $EventLogsStopTimePickerValue,
                            $TargetComputer,
                            $script:Credential
                        )
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
                    -ArgumentList $Query.Filter, $EventLogsMaximumCollectionTextBoxText, $EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer,$script:Credential
                }
                Monitor-Jobs -CollectionName $CollectionName -MonitorMode
                #Commented out because the above -MonitorMode implementation doesn't save files individually
                #Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
            }
        }
    }
    else {
        foreach ($Query in $script:EventLogQueries) {
            if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
                $CollectionName = "Event Logs - $($Query.Name)"
                $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")

                Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                        -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                        -TargetComputer $TargetComputer
                Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

                foreach ($TargetComputer in $script:ComputerList) {
                    Start-Job -ScriptBlock {
                        param(
                            $Filter,
                            $EventLogsMaximumCollectionTextBoxText,
                            $EventLogsStartTimePickerChecked,
                            $EventLogsStopTimePickerChecked,
                            $EventLogsStartTimePickerValue,
                            $EventLogsStopTimePickerValue,
                            $TargetComputer
                        )
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
                    -ArgumentList $Query.Filter, $EventLogsMaximumCollectionTextBoxText, $EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer
                }
                Monitor-Jobs -CollectionName $CollectionName -MonitorMode
                #Commented out because the above -MonitorMode implementation doesn't save files individually
                #Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
            }
        }
    }
}


