$ExecutionStartTime = Get-Date

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: Event ID Quick Selection")
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0

$EventLogsMaximumCollectionTextBoxText   = $EventLogsMaximumCollectionTextBox.Text
$EventLogsStartTimePickerChecked         = $EventLogsStartTimePicker.Checked
$EventLogsStopTimePickerChecked          = $EventLogsStopTimePicker.Checked
$EventLogsStartTimePickerValue           = $EventLogsStartTimePicker.Value
$EventLogsStopTimePickerValue            = $EventLogsStopTimePicker.Value

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


foreach ($Query in $script:EventLogQueries) {
    if ($EventLogsQuickPickSelectionCheckedlistbox.CheckedItems -match $Query.Name) {
        $CollectionName = "Event Logs - $($Query.Name)"
        $OutputFilePath = "$($script:CollectionSavedDirectoryTextBox.Text)\Event Logs - $($Query.Name)"


        $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName ($($Query.Name))")
        $PoShEasyWin.Refresh()


        Invoke-Command -ScriptBlock ${function:Query-EventLogLogsEventIDsManualEntrySessionBased} `
        -ArgumentList $Query.Filter, $EventLogsMaximumCollectionTextBoxText, $EventLogsStartTimePickerChecked, $EventLogsStopTimePickerChecked, $EventLogsStartTimePickerValue, $EventLogsStopTimePickerValue `
        -Session $PSSession `
        | Set-Variable SessionData


        $SessionData | Export-Csv    -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force


        $script:ProgressBarQueriesProgressBar.Value += 1
        $PoShEasyWin.Refresh()


        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName ($($Query.Name))")
        $PoShEasyWin.Refresh()
    }
}


$script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
$PoShEasyWin.Refresh()
Start-Sleep -match 500


