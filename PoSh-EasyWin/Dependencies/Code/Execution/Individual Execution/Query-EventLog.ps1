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
        param($EventLogsMaximumCollectionTextBox,$EventLogsStartTimePicker,$EventLogsStopTimePicker,$Filter)

        # Builds the Event Log Query Command
        $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
        ###$EventLogQueryComputer = "-ComputerName $TargetComputer"


        # Code to set the amount of data to return
        if ($EventLogsMaximumCollectionTextBox.Text -eq $null -or $EventLogsMaximumCollectionTextBox.Text -eq '' -or $EventLogsMaximumCollectionTextBox.Text -eq 0) {
            $EventLogQueryMax = $null
        }
        else { $EventLogQueryMax = "-First $($EventLogsMaximumCollectionTextBox.Text)" }


        # Code to include calendar start/end datetimes if checked
        if ( $EventLogsStartTimePicker.Checked -and $EventLogsStopTimePicker.Checked ) {
            $EventLogQueryFilter = @"
-Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePicker.Value)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStopTimePicker.Value)))'))"
"@
        }
        else { $EventLogQueryFilter = "-Filter `"$Filter`""}


        # Code to select and format properties
        $EventLogQueryPipe = @"
| Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
"@

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
                -ArgumentList @($EventLogsMaximumCollectionTextBox,$EventLogsStartTimePicker,$EventLogsStopTimePicker,$Filter) `
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
                -ArgumentList @($EventLogsMaximumCollectionTextBox,$EventLogsStartTimePicker,$EventLogsStopTimePicker,$Filter) `
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


    Monitor-Jobs -CollectionName $CollectionName -MonitorMode
    #Commented out because the above -MonitorMode implementation doesn't save files individually
    #Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime

    $CollectionCommandEndTime  = Get-Date
    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime


    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")
}

