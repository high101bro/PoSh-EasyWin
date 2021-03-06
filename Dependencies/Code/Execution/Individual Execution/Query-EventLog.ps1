function Query-EventLog {
    param(
        $CollectionName,
        $Filter
    )
    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")








    function Compiled-EventLogCommand {
        param($script:EventLogsMaximumCollectionTextBox,$script:EventLogsStartTimePicker,$script:EventLogsStopTimePicker,$Filter)

        # Builds the Event Log Query Command
        $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
        ###$EventLogQueryComputer = "-ComputerName $TargetComputer"


        # Code to set the amount of data to return
        if ($script:EventLogsMaximumCollectionTextBox.Text -eq $null -or $script:EventLogsMaximumCollectionTextBox.Text -eq '' -or $script:EventLogsMaximumCollectionTextBox.Text -eq 0) {
            $EventLogQueryMax = $null
        }
        else { $EventLogQueryMax = "-First $($script:EventLogsMaximumCollectionTextBox.Text)" }


        # Code to include calendar start/end datetimes if checked
        if ( $script:EventLogsStartTimePicker.Checked -and $script:EventLogsStopTimePicker.Checked ) {
            $EventLogQueryFilter = @"
-Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogsStartTimePicker.Value)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($script:EventLogsStopTimePicker.Value)))'))"
"@
        }
        else { $EventLogQueryFilter = "-Filter `"$Filter`""}


        # Code to select and format properties
        $EventLogQueryPipe = @"
| Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
"@

        # TODO Batman... look into why Get-AccountLogonActivity is here... 
        Invoke-Expression -Command "Invoke-Command -ScriptBlock `${function:Get-AccountLogonActivity} -ArgumentList @(`$AccountsStartTimePickerValue,`$AccountsStopTimePickerValue) -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"
    }













    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName


        if ($EventLogWinRMRadioButton.Checked) {
            if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
                if (!$script:Credential) { Create-NewCredentials }

                Invoke-Command -ScriptBlock ${function:Compiled-EventLogCommand} `
                -ArgumentList @($script:EventLogsMaximumCollectionTextBox,$script:EventLogsStartTimePicker,$script:EventLogsStopTimePicker,$Filter) `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)" `
                -Credential $script:Credential
                ${function:Compiled-EventLogCommand} | ogv
                #                 Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock `${function:Get-AccountLogonActivity} -ArgumentList @(`$AccountsStartTimePickerValue,`$AccountsStopTimePickerValue) -ComputerName $TargetComputer -AsJob -JobName 'PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)' -Credential `$script:Credential"

                #$EventLogQueryBuild = "Invoke-Command -Credential $script:Credential $EventLogQueryComputer -ScriptBlock { $EventLogQueryCommand $EventLogQueryFilter } $EventLogQueryPipe"
                #Start-Job -ScriptBlock {
                #    param(
                #        $EventLogQueryBuild,
                #        $script:Credential
                #    )
                #    Invoke-Expression -Command "$EventLogQueryBuild $script:Credential"
                #} -ArgumentList @($EventLogQueryBuild,$script:Credential) `
                #-Name "PoSh-EasyWin: $CollectionName -- $TargetComputer"
            }
            else {
                Invoke-Command -ScriptBlock ${function:Compiled-EventLogCommand} `
                -ArgumentList @($script:EventLogsMaximumCollectionTextBox,$script:EventLogsStartTimePicker,$script:EventLogsStopTimePicker,$Filter) `
                -ComputerName $TargetComputer `
                -AsJob -JobName "PoSh-EasyWin: $($CollectionName) -- $($TargetComputer)"

                #$EventLogQueryBuild = "Invoke-Command $EventLogQueryComputer -ScriptBlock { $EventLogQueryCommand $EventLogQueryFilter } $EventLogQueryPipe"
                ##write-host $EventLogQueryBuild
                #Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer" -ScriptBlock {
                #    param(
                #        $EventLogQueryBuild
                #    )
                #    Invoke-Expression -Command "$EventLogQueryBuild"
                #} -ArgumentList @($EventLogQueryBuild,$null)
            }
            #Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "$EventLogQueryBuild"
        }
        elseif ($EventLogRPCRadioButton.Checked) {
            if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
                #$EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryComputer $EventLogQueryFilter -Credential $script:Credential $EventLogQueryPipe"
                #Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer" -ScriptBlock {
                #    param(
                #        $EventLogQueryBuild
                #    )
                #    Invoke-Expression -Command "$EventLogQueryBuild"
                #} -ArgumentList @($EventLogQueryBuild,$null)
            }
            else {
                #$EventLogQueryBuild = "$EventLogQueryCommand $EventLogQueryComputer $EventLogQueryFilter $EventLogQueryPipe"
                #Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer" -ScriptBlock {
                #    param(
                #        $EventLogQueryBuild
                #    )
                #    Invoke-Expression -Command "$EventLogQueryBuild"
                #} -ArgumentList @($EventLogQueryBuild,$null)
            }
            #Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "$EventLogQueryBuild"
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

