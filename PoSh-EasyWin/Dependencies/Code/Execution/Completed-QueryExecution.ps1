# The end of the collection script
Function Completed-QueryExecution {
    $CollectionTimerStop = Get-Date
    $ResultsListBox.Items.Insert(0,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss'))  Finished Collecting Data!")

    if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) { 
        Generate-NewRollingPassword
        $ResultsListBox.Items.Insert(1,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss'))  Rolled Password For Account: $($script:CredentialManagementPasswordRollingAccountTextBox.text)")
        $TotalElapsedTimeOrder = @(2,3,4)
    }
    else {$TotalElapsedTimeOrder = @(1,2,3)}

    $StatusListBox.Items.Clear()
    if ($CountCommandQueries -eq 1 -and $ComputerList.Count -eq 1) { $StatusListBox.Items.Add("Completed Executing $($CountCommandQueries) Command to $($ComputerList.Count) Endpoint") }
    elseif ($CountCommandQueries -gt 1 -and $ComputerList.Count -eq 1) { $StatusListBox.Items.Add("Completed Executing $($CountCommandQueries) Commands to $($ComputerList.Count) Endpoint") }
    elseif ($CountCommandQueries -eq 1 -and $ComputerList.Count -gt 1) { $StatusListBox.Items.Add("Completed Executing $($CountCommandQueries) Command to $($ComputerList.Count) Endpoints") }
    elseif ($CountCommandQueries -eq 1 -and $ComputerList.Count -gt 1) { $StatusListBox.Items.Add("Completed Executing $($CountCommandQueries) Commands to $($ComputerList.Count) Endpoints") }

    $CollectionTime = New-TimeSpan -Start $CollectionTimerStart -End $CollectionTimerStop
    $ResultsListBox.Items.Insert($TotalElapsedTimeOrder[0],"   $CollectionTime  Total Elapsed Time")
    $ResultsListBox.Items.Insert($TotalElapsedTimeOrder[1],"====================================================================================================")
    $ResultsListBox.Items.Insert($TotalElapsedTimeOrder[2],"")

    # Ensures that the Progress Bars are full at the end of collection
    $script:ProgressBarEndpointsProgressBar.Maximum = 1
    $script:ProgressBarEndpointsProgressBar.Value   = 1
    $script:ProgressBarQueriesProgressBar.Maximum   = 1
    $script:ProgressBarQueriesProgressBar.Value     = 1

    if ($NoGUI){
        #Write-Progress -Activity Updating -Status 'Completed' -PercentComplete $ProgressBarEndpointsCommandLine -CurrentOperation Endpoints
        Write-Progress -Id 1 -Activity Updating -Status 'Task Completed! ' -PercentComplete $ProgressBarQueriesCommandLine -CurrentOperation "Please be patient as queries are being executed..."
    }
    # Plays a Sound When finished
    [system.media.systemsounds]::Exclamation.play()

    Execute-TextToSpeach

    $OpenCsvResultsButton.BackColor = 'LightGreen'
    $OpenXmlResultsButton.BackColor = 'LightGreen'

    Deselect-AllComputers
    Deselect-AllCommands
}
