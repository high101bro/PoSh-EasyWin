function Query-EventLog {
    param(
        $CollectionName,
        $Filter
    )
    $CollectionCommandStartTime = Get-Date 
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")                    
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

        # Builds the Event Log Query Command
        $EventLogQueryCommand  = "Get-WmiObject -Class Win32_NTLogEvent"
        $EventLogQueryComputer = "-ComputerName $TargetComputer"
        if ($EventLogsMaximumCollectionTextBox.Text -eq $null -or $EventLogsMaximumCollectionTextBox.Text -eq '' -or $EventLogsMaximumCollectionTextBox.Text -eq 0) { $EventLogQueryMax = $null}
        else { $EventLogQueryMax = "-First $($EventLogsMaximumCollectionTextBox.Text)" }
        if ( $EventLogsStartTimePicker.Checked -and $EventLogsStopTimePicker.Checked ) {
            $EventLogQueryFilter = @"
-Filter "($Filter and (TimeGenerated>='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStartTimePicker.Value)))') and (TimeGenerated<='$([System.Management.ManagementDateTimeConverter]::ToDmtfDateTime(($EventLogsStopTimePicker.Value)))'))"
"@
        }
        else { $EventLogQueryFilter = "-Filter `"$Filter`""}
        $EventLogQueryPipe = @"
| Select-Object PSComputerName, LogFile, EventIdentifier, CategoryString, @{Name='TimeGenerated';Expression={[Management.ManagementDateTimeConverter]::ToDateTime(`$_.TimeGenerated)}}, Message, Type $EventLogQueryMax
"@
        if ($EventLogWinRMRadioButton.Checked) {
            if ( $ComputerListProvideCredentialsCheckBox.Checked ) {
                $EventLogQueryBuild = "Invoke-Command -Credential $script:Credential $EventLogQueryComputer -ScriptBlock { $EventLogQueryCommand $EventLogQueryFilter } $EventLogQueryPipe"
                Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer" -ScriptBlock {
                    param(
                        $ThreadPriority,
                        $EventLogQueryBuild,
                        $script:Credential
                    )
                    Invoke-Expression -Command "$ThreadPriority"
                    Invoke-Expression -Command "$EventLogQueryBuild $script:Credential"
                } -ArgumentList @($ThreadPriority,$EventLogQueryBuild,$script:Credential)
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

    Monitor-Jobs -CollectionName $CollectionName

    $CollectionCommandEndTime  = Get-Date                    
    $CollectionCommandDiffTime = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime]  $CollectionName")

    Compile-CsvFiles -LocationOfCSVsToCompile   "$($script:IndividualHostResults)\$($CollectionName)\$($CollectionName)*.csv" `
                     -LocationToSaveCompiledCSV "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).csv"

    Compile-XmlFiles -LocationOfXmlsToCompile   "$($script:IndividualHostResults)\$($CollectionName)\$($CollectionName)*.Xml" `
                     -LocationToSaveCompiledXml "$($script:CollectionSavedDirectoryTextBox.Text)\$($CollectionName).Xml"

    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Compiling CSV Files"
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "$($script:CollectionSavedDirectoryTextBox.Text)\$((($Command.Name) -split ' -- ')[1]) - $($Command.Type).csv"
}