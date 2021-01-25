$ExecutionStartTime = Get-Date
$CollectionName = "Event Logs - Event IDs To Monitor"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName"

$EventLogsEventIDsToMonitorCheckListBoxCheckedItems = $EventLogsEventIDsToMonitorCheckListBox.CheckedItems
$EventLogsMaximumCollectionTextBoxText = $EventLogsMaximumCollectionTextBox.Text
$EventLogsStartTimePickerChecked       = $EventLogsStartTimePicker.Checked
$EventLogsStopTimePickerChecked        = $EventLogsStopTimePicker.Checked
$EventLogsStartTimePickerValue         = $EventLogsStartTimePicker.Value
$EventLogsStopTimePickerValue          = $EventLogsStopTimePicker.Value


Invoke-Command -ScriptBlock {
    param($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue)
    function Query-EventLogLogsEventIDsIndividualSelectionSessionBased {
        param(
            $EventLogsEventIDsToMonitorCheckListBoxCheckedItems,
            $EventLogsMaximumCollectionTextBoxText,
            $EventLogsStartTimePickerChecked,
            $EventLogsStopTimePickerChecked,
            $EventLogsStartTimePickerValue,
            $EventLogsStopTimePickerValue
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
        $EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryFilter $EventLogQueryPipe"
        Invoke-Expression $EventLogQueryBuild
    }

    Query-EventLogLogsEventIDsIndividualSelectionSessionBased -EventLogsEventIDsToMonitorCheckListBoxCheckedItems $EventLogsEventIDsToMonitorCheckListBoxCheckedItems -EventLogsMaximumCollectionTextBoxText $EventLogsMaximumCollectionTextBoxText -EventLogsStartTimePickerChecked $EventLogsStartTimePickerChecked -EventLogsStopTimePickerChecked $EventLogsStopTimePickerChecked -EventLogsStartTimePickerValue $EventLogsStartTimePickerValue -EventLogsStopTimePickerValue $EventLogsStopTimePickerValue
} -ArgumentList @($EventLogsEventIDsToMonitorCheckListBoxCheckedItems,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue) -Session $PSSession `
| Set-Variable SessionData
$SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
$SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
Remove-Variable -Name SessionData -Force


$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()


$script:ProgressBarQueriesProgressBar.Value += 1
$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500


