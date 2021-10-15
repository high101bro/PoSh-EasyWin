# Query-EventLog -CollectionName $Query.Name -Filter $Query.Filter
$ExecutionStartTime = Get-Date

$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: Event Log Name .evtx Retrieval")

$script:ProgressBarEndpointsProgressBar.Value = 0

$EventLogNameEVTXMaximumCollectionTextBoxText = $script:EventLogNameEVTXMaximumCollectionTextBox.Text
$EventLogNameEVTXLogNameSelectionComboBoxSelectedItem = $EventLogNameEVTXLogNameSelectionComboBox.SelectedItem
$EventLogNameEVTXStartTimePickerChecked = $script:EventLogNameEVTXStartTimePicker.Checked
$EventLogNameEVTXStopTimePickerChecked = $script:EventLogNameEVTXStopTimePicker.Checked
$EventLogNameEVTXStartTimePickerValue = $script:EventLogNameEVTXStartTimePicker.Value
$EventLogNameEVTXStopTimePickerValue = $script:EventLogNameEVTXStopTimePicker.Value
$EventLogNameEVTXEventIDsManualEntryTextboxFilter = $script:EventLogNameEVTXEventIDsManualEntryTextbox.Text
$EndpointSavePath = "C:\windows\temp\$($EventLogNameEVTXLogNameSelectionComboBoxSelectedItem.replace('/','-')).evtx"

if ($EventLogNameEVTXWinRMRadioButton.Checked) {
    $script:CollectionName = "$($EventLogNameEVTXLogNameSelectionComboBoxSelectedItem -replace '/','-')"
}


foreach ($TargetComputer in $script:ComputerList) {
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $($script:CollectionSavedDirectoryTextBox.Text) `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $script:CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $script:CollectionName

    $LocalSavePath = "$($script:CollectionSavedDirectoryTextBox.Text)\$script:CollectionName\$TargetComputer - $script:CollectionName.evtx"

    Start-Job -Name "PoSh-EasyWin: $script:CollectionName -- $TargetComputer $DateTime" -ScriptBlock {
        param(
            $ComputerListProvideCredentialsCheckBoxChecked,
            $script:Credential,
            $TargetComputer,
            $EventLogNameEVTXMaximumCollectionTextBoxText,
            $EventLogNameEVTXLogNameSelectionComboBoxSelectedItem,
            $EventLogNameEVTXStartTimePickerChecked,
            $EventLogNameEVTXStopTimePickerChecked,
            $EventLogNameEVTXStartTimePickerValue,
            $EventLogNameEVTXStopTimePickerValue,
            $EventLogNameEVTXEventIDsManualEntryTextboxFilter,
            $EndpointSavePath,
            $LocalSavePath
        )


        if ($ComputerListProvideCredentialsCheckBoxChecked) {
            if (!$script:Credential) { $script:Credential = Get-Credential }
            $Session = New-PSSession -ComputerName $TargetComputer -Credential $script:Credential
        }
        else {
            $Session = New-PSSession -ComputerName $TargetComputer
        }

        #$EventLog = wevtutil enum-logs | Out-GridView -Title "Event Logs" -OutputMode 'Single'
        $EventLog = $EventLogNameEVTXLogNameSelectionComboBoxSelectedItem

        #$DateTimeStart = (get-date).AddDays(-30).ToString('yyyy-MM-ddThh:mm:ss')
        $DateTimeStart = $EventLogNameEVTXStartTimePickerValue.ToString('yyyy-MM-ddThh:mm:ss')

        #$DateTimeStop = (get-date).ToString('yyyy-MM-ddThh:mm:ss')
        $DateTimeStop = $EventLogNameEVTXStopTimePickerValue.ToString('yyyy-MM-ddThh:mm:ss')

        $IdFilterList = $EventLogNameEVTXEventIDsManualEntryTextboxFilter.split("`r`n") | Where-Object {$_ -ne '' -and $_ -ne $null}

        $OverWrite = $true

        #wevtutil export-log $EventLog $EndpointSavePath /q:"* [System [(EventID=1014) or (EventID=7040) ] [TimeCreated [@SystemTime >= '$DateTimeStart' and @SystemTime < '$DateTimeStop'] ] ]” /ow:$OverWrite

        $EventLogQueryCommand = @"
wevtutil export-log '$EventLog' '$EndpointSavePath' /q:"* 
"@
         $EventLogQueryCommand += '[System '

        # Note: Not implemented yet
        #$EventLogNameEVTXMaximumCollectionTextBoxText
        
        if ($IdFilterList.count -gt 0) {

            $EventLogQueryCommand += '[ '
            if ($IdFilterList.count -eq 1) {
                $EventLogQueryCommand += "(EventID=$($IdFilterList))"
            }
            elseif ($IdFilterList.count -gt 1) {
                $FirstID = $true
                foreach ($Id in $IdFilterList) {
                    if ($FirstID) {
                        $EventLogQueryCommand += "(EventID=$($Id))"
                        $FirstID = $false
                    }
                    else {
                        $EventLogQueryCommand += " or (EventID=$($Id))"
                    }
                }
            }
            $EventLogQueryCommand += ' ]'
        }

#         if ( $EventLogNameEVTXStartTimePickerChecked -and $EventLogNameEVTXStopTimePickerChecked ) {
#             $EventLogQueryCommand += @'
# [TimeCreated [@SystemTime >= '$DateTimeStart' and @SystemTime < '$DateTimeStop'] ] 
# '@
#         }

         $EventLogQueryCommand += ']'

        $EventLogQueryCommand += '" '

        $EventLogQueryCommand += @"
/ow:$OverWrite
"@

        Invoke-Command -ScriptBlock {
            param($EventLogQueryCommand)
            Invoke-Expression $EventLogQueryCommand
        } -argumentlist @($EventLogQueryCommand,$null) -Session $Session

        Copy-Item -Path $EndpointSavePath -Destination $LocalSavePath -FromSession $Session -Force

        Invoke-Command -ScriptBlock {
            param($EndpointSavePath)
            Remove-Item -Path $EndpointSavePath -Force
        } -argumentlist @($EndpointSavePath,$null) -Session $Session


        $Session | Remove-PSSession

    } -ArgumentList @(
        $script:ComputerListProvideCredentialsCheckBox.checked,
        $script:Credential,
        $TargetComputer,
        $EventLogNameEVTXMaximumCollectionTextBoxText,
        $EventLogNameEVTXLogNameSelectionComboBoxSelectedItem,
        $EventLogNameEVTXStartTimePickerChecked,
        $EventLogNameEVTXStopTimePickerChecked,
        $EventLogNameEVTXStartTimePickerValue,
        $EventLogNameEVTXStopTimePickerValue,
        $EventLogNameEVTXEventIDsManualEntryTextboxFilter,
        $EndpointSavePath,
        $LocalSavePath
    )

    
    
    $InputValues = @"
===========================================================================
Collection Name:
===========================================================================
Event Log Retrieval

===========================================================================
Execution Time:
===========================================================================
$ExecutionStartTime

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoint:
===========================================================================
$TargetComputer

===========================================================================
Start Time:  [$EventLogNameEVTXStartTimePickerChecked]
===========================================================================
$EventLogNameEVTXStartTimePickerValue

===========================================================================
End Time:  [$EventLogNameEVTXStopTimePickerChecked]
===========================================================================
$EventLogNameEVTXStopTimePickerValue

===========================================================================
Event Log Name:
===========================================================================
$EventLogNameEVTXLogNameSelectionComboBoxSelectedItem

===========================================================================
Filters:
===========================================================================
$($script:EventLogNameEVTXEventIDsManualEntryTextbox.Text)

"@


    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        Monitor-Jobs -CollectionName $script:CollectionName -MonitorMode -EVTXSwitch -EVTXLocalSavePath $LocalSavePath -DisableReRun -InputValues $InputValues -NotExportFiles
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
        Monitor-Jobs -CollectionName $script:CollectionName -NotExportFiles
        Post-MonitorJobs -CollectionName $script:CollectionName -CollectionCommandStartTime $ExecutionStartTime
    }
}


























