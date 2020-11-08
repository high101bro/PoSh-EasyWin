$CollectionName = "Event Logs - Event ID Manual Entry"
$ExecutionStartTime = Get-Date

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")

$script:ProgressBarEndpointsProgressBar.Value = 0

$EventLogsEventIDsManualEntryTextboxText = $EventLogsEventIDsManualEntryTextbox.Lines
$EventLogsMaximumCollectionTextBoxText   = $EventLogsMaximumCollectionTextBox.Lines
$EventLogsStartTimePickerChecked         = $EventLogsStartTimePicker.Checked
$EventLogsStopTimePickerChecked          = $EventLogsStopTimePicker.Checked
$EventLogsStartTimePickerValue           = $EventLogsStartTimePicker.Value
$EventLogsStopTimePickerValue            = $EventLogsStopTimePicker.Value

function Query-EventLogLogsEventIDsManualEntrySessionBased {
    param(
        $EventLogsEventIDsManualEntryTextboxText,
        $EventLogsMaximumCollectionTextBoxText,
        $EventLogsStartTimePickerChecked,
        $EventLogsStopTimePickerChecked,
        $EventLogsStartTimePickerValue,
        $EventLogsStopTimePickerValue
    )
    $ManualEntry = $EventLogsEventIDsManualEntryTextboxText
    #$ManualEntry = ($EventLogsEventIDsManualEntryTextboxText).split("`r`n")
    $ManualEntry = $ManualEntry -replace " ","" -replace "a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z",""
    $ManualEntry = $ManualEntry | Where-Object {$_.trim() -ne ""}

    # Variables begins with an open "(
    $EventLogsEventIDsManualEntryTextboxFilter = '('

    foreach ($EventCode in $ManualEntry) {
        $EventLogsEventIDsManualEntryTextboxFilter += "(EventCode='$EventCode') OR "
    }
    # Replaces the ' OR ' at the end of the varable with a closing )"
    $Filter = $EventLogsEventIDsManualEntryTextboxFilter -replace " OR $",")"

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


foreach ($TargetComputer in $script:ComputerList) {
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

    if ($EventLogWinRMRadioButton.Checked) {
        if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
            if (!$script:Credential) { Create-NewCredentials }

            Invoke-Command -ScriptBlock ${function:Query-EventLogLogsEventIDsManualEntrySessionBased} `
            -ArgumentList $EventLogsEventIDsManualEntryTextboxText, $EventLogsMaximumCollectionTextBoxText, $EventLogsStartTimePickerChecked, $EventLogsStopTimePickerChecked, $EventLogsStartTimePickerValue, $EventLogsStopTimePickerValue `
            -ComputerName $TargetComputer `
            -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
            -Credential $script:Credential
        }
        else {
            Invoke-Command -ScriptBlock ${function:Query-EventLogLogsEventIDsManualEntrySessionBased} `
            -ArgumentList $EventLogsEventIDsManualEntryTextboxText, $EventLogsMaximumCollectionTextBoxText, $EventLogsStartTimePickerChecked, $EventLogsStopTimePickerChecked, $EventLogsStartTimePickerValue, $EventLogsStopTimePickerValue `
            -ComputerName $TargetComputer `
            -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"
        }
    }
    else {
        if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
            if (!$script:Credential) { Create-NewCredentials }

            Start-Job -ScriptBlock {
                param(
                    $EventLogsEventIDsManualEntryTextboxText,
                    $EventLogsMaximumCollectionTextBoxText,
                    $EventLogsStartTimePickerChecked,
                    $EventLogsStopTimePickerChecked,
                    $EventLogsStartTimePickerValue,
                    $EventLogsStopTimePickerValue,
                    $TargetComputer,
                    $script:Credential
                )
                $ManualEntry = $EventLogsEventIDsManualEntryTextboxText
                #$ManualEntry = ($EventLogsEventIDsManualEntryTextboxText).split("`r`n")
                $ManualEntry = $ManualEntry -replace " ","" -replace "a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z",""
                $ManualEntry = $ManualEntry | Where-Object {$_.trim() -ne ""}

                # Variables begins with an open "(
                $EventLogsEventIDsManualEntryTextboxFilter = '('

                foreach ($EventCode in $ManualEntry) {
                    $EventLogsEventIDsManualEntryTextboxFilter += "(EventCode='$EventCode') OR "
                }
                # Replaces the ' OR ' at the end of the varable with a closing )"
                $Filter = $EventLogsEventIDsManualEntryTextboxFilter -replace " OR $",")"

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
            -ArgumentList @($EventLogsEventIDsManualEntryTextboxText,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer,$script:Credential)
        }
        else {
            Start-Job -ScriptBlock {
                param(
                    $EventLogsEventIDsManualEntryTextboxText,
                    $EventLogsMaximumCollectionTextBoxText,
                    $EventLogsStartTimePickerChecked,
                    $EventLogsStopTimePickerChecked,
                    $EventLogsStartTimePickerValue,
                    $EventLogsStopTimePickerValue,
                    $TargetComputer
                )
                $ManualEntry = $EventLogsEventIDsManualEntryTextboxText
                #$ManualEntry = ($EventLogsEventIDsManualEntryTextboxText).split("`r`n")
                $ManualEntry = $ManualEntry -replace " ","" -replace "a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z",""
                $ManualEntry = $ManualEntry | Where-Object {$_.trim() -ne ""}

                # Variables begins with an open "(
                $EventLogsEventIDsManualEntryTextboxFilter = '('

                foreach ($EventCode in $ManualEntry) {
                    $EventLogsEventIDsManualEntryTextboxFilter += "(EventCode='$EventCode') OR "
                }
                # Replaces the ' OR ' at the end of the varable with a closing )"
                $Filter = $EventLogsEventIDsManualEntryTextboxFilter -replace " OR $",")"

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
            -ArgumentList @($EventLogsEventIDsManualEntryTextboxText,$EventLogsMaximumCollectionTextBoxText,$EventLogsStartTimePickerChecked,$EventLogsStopTimePickerChecked,$EventLogsStartTimePickerValue,$EventLogsStopTimePickerValue,$TargetComputer)
        }
    }
}
Monitor-Jobs -CollectionName $CollectionName -MonitorMode
#Commented out because the above -MonitorMode implementation doesn't save files individually
#Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime


