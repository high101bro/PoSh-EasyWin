function Query-EventLog {
    param(
        $CollectionName,
        $Filter
    )
    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

        # Builds the Event Log Query Command
        $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
        $EventLogQueryComputer = "-ComputerName $TargetComputer"
        if ($script:EventLogsMaximumCollectionTextBox.Text -eq $null -or $script:EventLogsMaximumCollectionTextBox.Text -eq '' -or $script:EventLogsMaximumCollectionTextBox.Text -eq 0) { $EventLogQueryMax = $null}
        else { $EventLogQueryMax = "-First $($script:EventLogsMaximumCollectionTextBox.Text)" }
        if ( $script:EventLogsStartTimePicker.Checked -and $script:EventLogsStopTimePicker.Checked ) {
            $EventLogQueryFilter = @"
-Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogsStartTimePicker.Value)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogsStopTimePicker.Value)))'))"
"@
        }
        else { $EventLogQueryFilter = "-Filter `"$Filter`""}
        $EventLogQueryPipe = @"
| Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
"@
        if ($EventLogWinRMRadioButton.Checked) {
            if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
                $EventLogQueryBuild = "Invoke-Command -Credential $script:Credential $EventLogQueryComputer -ScriptBlock { $EventLogQueryCommand $EventLogQueryFilter } $EventLogQueryPipe"
                Start-Job -ScriptBlock {
                    param(
                        $ThreadPriority,
                        $EventLogQueryBuild,
                        $script:Credential
                    )
                    Invoke-Expression -Command "$ThreadPriority"
                    Invoke-Expression -Command "$EventLogQueryBuild $script:Credential"
                } -ArgumentList @($ThreadPriority,$EventLogQueryBuild,$script:Credential) `
                -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer"
            }
            else {
                $EventLogQueryBuild = "Invoke-Command $EventLogQueryComputer -ScriptBlock { $EventLogQueryCommand $EventLogQueryFilter } $EventLogQueryPipe"
                #write-host $EventLogQueryBuild
                Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer" -ScriptBlock {
                    param(
                        $ThreadPriority,
                        $EventLogQueryBuild
                    )
                    Invoke-Expression -Command "$ThreadPriority"
                    Invoke-Expression -Command "$EventLogQueryBuild"
                } -ArgumentList @($ThreadPriority,$EventLogQueryBuild)
            }
            Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "$EventLogQueryBuild"
        }
        elseif ($EventLogRPCRadioButton.Checked) {
            if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
                $EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryComputer $EventLogQueryFilter -Credential $script:Credential $EventLogQueryPipe"
                Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer" -ScriptBlock {
                    param(
                        $ThreadPriority,
                        $EventLogQueryBuild
                    )
                    Invoke-Expression -Command "$ThreadPriority"
                    Invoke-Expression -Command "$EventLogQueryBuild"
                } -ArgumentList @($ThreadPriority,$EventLogQueryBuild)
            }
            else {
                $EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryComputer $EventLogQueryFilter $EventLogQueryPipe"
                Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer" -ScriptBlock {
                    param(
                        $ThreadPriority,
                        $EventLogQueryBuild
                    )
                    Invoke-Expression -Command "$ThreadPriority"
                    Invoke-Expression -Command "$EventLogQueryBuild"
                } -ArgumentList @($ThreadPriority,$EventLogQueryBuild)
            }
            Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "$EventLogQueryBuild"
        }
    }


    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
        Monitor-Jobs -CollectionName $CollectionName
        Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
    }

    
    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime


    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
}

