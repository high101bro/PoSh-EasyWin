# The end of the collection script
Function Completed-QueryExecution {

    # Updates the value of the most recent queried computers
    # Used to ask if you want to conduct rpc,smb,winrm checks again if the currnet computerlist doens't match the history
    $script:ComputerListHistory         = $script:ComputerList
    if ($script:RpcCommandCount   -gt 0) { Set-variable RpcCommandCountHistory   -Scope script -Value $true -Force } else { Set-variable RpcCommandCountHistory   -Scope script -Value $false -Force }
    if ($script:SmbCommandCount   -gt 0) { Set-variable SmbCommandCountHistory   -Scope script -Value $true -Force } else { Set-variable SmbCommandCountHistory   -Scope script -Value $false -Force }
    if ($script:WinRmCommandCount -gt 0) { Set-variable WinRmCommandCountHistory -Scope script -Value $true -Force } else { Set-variable WinRmCommandCountHistory -Scope script -Value $false -Force }

    $CollectionTimerStop = Get-Date
    $ResultsListBox.Items.Insert(0,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss'))  Finished Executing Commands")

    if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) {
        Start-Sleep -Seconds 3
        Generate-NewRollingPassword
        $ResultsListBox.Items.Insert(1,"$(($CollectionTimerStop).ToString('yyyy/MM/dd HH:mm:ss'))  Rolled Password For Account: $($script:PoShEasyWinAccount)")
        $TotalElapsedTimeOrder = @(2,3,4)
    }
    else {$TotalElapsedTimeOrder = @(1,2,3)}


    # Check for and remove empty direcotires
    #$EmtpyDir = "$($script:CollectionSavedDirectoryTextBox.Text)\"
    #do {
    #    $Dirs = Get-ChildItem $EmtpyDir -Directory -Recurse `
    #    | Where-Object { (Get-ChildItem $_.FullName).count -eq 0 } `
    #    | Select-Object -ExpandProperty FullName
    #    $Dirs | Foreach-Object { Remove-Item $_ }
    #} while ($Dirs.count -gt 0)


    $StatusListBox.Items.Clear()
    if     ($CountCommandQueries -eq 1 -and $script:ComputerList.Count -eq 1) { $StatusListBox.Items.Add("Completed Executing $($CountCommandQueries) Command to $($script:ComputerList.Count) Endpoint") }
    elseif ($CountCommandQueries -gt 1 -and $script:ComputerList.Count -eq 1) { $StatusListBox.Items.Add("Completed Executing $($CountCommandQueries) Commands to $($script:ComputerList.Count) Endpoint") }
    elseif ($CountCommandQueries -eq 1 -and $script:ComputerList.Count -gt 1) { $StatusListBox.Items.Add("Completed Executing $($CountCommandQueries) Command to $($script:ComputerList.Count) Endpoints") }
    elseif ($CountCommandQueries -eq 1 -and $script:ComputerList.Count -gt 1) { $StatusListBox.Items.Add("Completed Executing $($CountCommandQueries) Commands to $($script:ComputerList.Count) Endpoints") }


    $CollectionTime = New-TimeSpan -Start $CollectionTimerStart -End $CollectionTimerStop
    $ResultsListBox.Items.Insert($TotalElapsedTimeOrder[0],"   $CollectionTime  Total Elapsed Time")
    $ResultsListBox.Items.Insert($TotalElapsedTimeOrder[1],"====================================================================================================")
    $ResultsListBox.Items.Insert($TotalElapsedTimeOrder[2],"")


    # Ensures that the Progress Bars are full at the end of collection
    $script:ProgressBarEndpointsProgressBar.Maximum = 1
    $script:ProgressBarEndpointsProgressBar.Value   = 1
    $script:ProgressBarQueriesProgressBar.Maximum   = 1
    $script:ProgressBarQueriesProgressBar.Value     = 1

    # Plays a Sound When finished
    [system.media.systemsounds]::Exclamation.play()

    Execute-TextToSpeach

    $OpenCsvResultsButton.BackColor = 'LightGreen'
    $OpenXmlResultsButton.BackColor = 'LightGreen'

    #Deselect-AllComputers
    Deselect-AllCommands

    # Garbage Collection to free up memory
    [System.GC]::Collect()
}


