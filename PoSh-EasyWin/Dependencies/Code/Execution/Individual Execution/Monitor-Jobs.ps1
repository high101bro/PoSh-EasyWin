function Monitor-Jobs {
    param(
        $CollectionName,
        [String]$SaveProperties
    )
    # Initially updates statistics
    $StatisticsResults = Get-PoShEasyWinStatistics
    $StatisticsNumberOfCSVs.text = $StatisticsResults        

    $SleepMilliSeconds = 250
    $script:ProgressBarEndpointsProgressBar.Value = 0
    
    # Sets the job timeout value, so they don't run forever
    $JobsTimer  = [int]$($OptionJobTimeoutSelectionComboBox.Text)

    # This is how often the statistics page updates, be default it is 20 which is 5 Seconds (250 ms x 4)
    $StatisticsUpdateInterval      = (1000 / $SleepMilliSeconds) * $OptionStatisticsUpdateIntervalCombobox.text
    $StatisticsUpdateIntervalCount = 0

    # The number of Jobs created by PoSh-EasyWin
    $JobsCount = (Get-Job -Name "PoSh-EasyWin:*").count                  
    $script:ProgressBarEndpointsProgressBar.Maximum = $JobsCount

    if ($NoGUI) { 
        $ProgressBarQueriesCommandLine = 0
        $ProgressBarQueriesCommandLineMaximum = ($script:CommandsCheckedBoxesSelected).count 
    }

    $Done = 0
    
    do {
        # Updates Statistics 
        $StatisticsUpdateIntervalCount++
        if (($StatisticsUpdateIntervalCount % $StatisticsUpdateInterval) -eq 0) {
            $StatisticsResults = Get-PoShEasyWinStatistics
            $StatisticsNumberOfCSVs.text = $StatisticsResults        
        }
        
        # The number of Jobs created by PoSh-EasyWin
        $CurrentJobs = Get-Job -Name "PoSh-EasyWin:*"
          
        # Calcualtes and formats time elaspsed
        $CurrentTime = Get-Date
        $Timecount   = $ExecutionStartTime - $CurrentTime        
        $Hour        = [Math]::Truncate($Timecount)
        $Minute      = ($CollectionTime - $Hour) * 60
        $Second      = [int](($Minute - ([Math]::Truncate($Minute))) * 60)
        $Minute      = [Math]::Truncate($Minute)
        $Timecount   = [datetime]::Parse("$Hour`:$Minute`:$Second")

        # Provides updates on the jobs
        $ResultsListBox.Items.Insert(0,"Running Jobs:  $($JobsCount - $Done)")        
        $ResultsListBox.Items.Insert(1,"Current Time:  $($CurrentTime)")
        $ResultsListBox.Items.Insert(2,"Elasped Time:  $($Timecount -replace '-','')")
        $ResultsListBox.Items.Insert(3,"")

        # This is how often PoSoh-EasyWin's GUI will refresh when provide the status of the jobs
        # Default have is 250 ms. If you change this, be sure to update the $StatisticsUpdateInterval variarible within this function
        Start-Sleep -MilliSeconds $SleepMilliSeconds
        $ResultsListBox.Refresh()
        
        # Checks if the current job is running too long and stops it
        foreach ($Job in $CurrentJobs) {
            # Gets the results from jobs that are completed, saves them, and deletes the job
            if ( $Job.State -eq 'Completed' ) {
                $Done++
                $script:ProgressBarEndpointsProgressBar.Value = $Done
                if ($NoGUI){
                    $ProgressBarQueriesCommandLine   += $Done
                    Write-Progress -Id 1 -Activity Updating -Status "Query: $CollectionName" -PercentComplete ($ProgressBarQueriesCommandLine / $ProgressBarQueriesCommandLineMaximum * 100) -CurrentOperation "Please be patient as queries are being executed..."
                }

                $JobName     = $Job.Name  -replace 'PoSh-EasyWin: ',''
                $JobReceived = $Job | Receive-Job #-Keep 

                if ($job.Location -notmatch $(($Job.Name -split ' ')[-1]) ) {
                    if ($SaveProperties) {
                        # This is needed because when jobs are started locally that use inovke-command, the localhost is used as the PSComputerName becuase it started the job rather than the invoke-command to a remote computer
                        $JobReceived | Select-Object @{n='PSComputerName';e={"$(($Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue | Select-Object $(iex $SaveProperties) | Export-CSV    "$($script:IndividualHostResults)\$CollectionName\$JobName.csv" -NoTypeInformation
                        $JobReceived | Select-Object @{n='PSComputerName';e={"$(($Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue | Select-Object $(iex $SaveProperties) | Export-Clixml "$($script:IndividualHostResults)\$CollectionName\$JobName.xml" 
                    }
                    else {
                        # This is needed because when jobs are started locally that use inovke-command, the localhost is used as the PSComputerName becuase it started the job rather than the invoke-command to a remote computer
                        $JobReceived | Select-Object @{n='PSComputerName';e={"$(($Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue | Export-CSV    "$($script:IndividualHostResults)\$CollectionName\$JobName.csv" -NoTypeInformation
                        $JobReceived | Select-Object @{n='PSComputerName';e={"$(($Job.Name -split ' ')[-1])"}},* -ErrorAction SilentlyContinue | Export-Clixml "$($script:IndividualHostResults)\$CollectionName\$JobName.xml" 
                    }
                }
                else {
                    if ($SaveProperties) {
                        $JobReceived | Select-Object $(iex $SaveProperties) | Export-CSV    "$($script:IndividualHostResults)\$CollectionName\$JobName.csv" -NoTypeInformation
                        $JobReceived | Select-Object $(iex $SaveProperties) | Export-Clixml "$($script:IndividualHostResults)\$CollectionName\$JobName.xml" 
                    }
                    else {
                        $JobReceived | Export-CSV    "$($script:IndividualHostResults)\$CollectionName\$JobName.csv" -NoTypeInformation
                        $JobReceived | Export-Clixml "$($script:IndividualHostResults)\$CollectionName\$JobName.xml" 
                    }
                }
                $Job | Remove-Job -Force
            }

            elseif ($Job.PSBeginTime -lt $(Get-Date).AddSeconds(-$JobsTimer)) {
                $TimeStamp = $(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')
                $ResultsListBox.Items.insert(5,"$($TimeStamp)   - Job Timed Out: $((($Job | Select-Object -ExpandProperty Name) -split '-')[-1])")
                $JobsKillTime = Get-Date
                $Job | Stop-Job 
                $Job | Receive-Job 
                $Job | Remove-Job -Force
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message " - Job [TIMED OUT]: `"$($Job.Name)`" - Started at $($Job.PSBeginTime) - Ran for $($JobsKillTime - $Job.PSBeginTime)"
                break
            }
        }

        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)  
    } while ($Done -lt $JobsCount)

    # Logs Jobs Beginning and Ending Times
    foreach ($Job in $CurrentJobs) {
        if ($($Job.PSEndTime -ne $null)) {
           # $TimeStamp = $(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')
            #$ResultsListBox.Items.insert(1,"$($TimeStamp)   - Job Completed: $((($Job | Select-Object -ExpandProperty Name) -split ' ')[-1])")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "$($TimeStamp)  Job [COMPLETED]: `"$($Job.Name)`" - Started at $($Job.PSBeginTime) - Ended at $($Job.PSEndTime)"
        }
    }

    # Updates Statistics One last time
    $StatisticsResults           = Get-PoShEasyWinStatistics
    $StatisticsNumberOfCSVs.text = $StatisticsResults        
    Get-Job -Name "PoSh-EasyWin:*" | Remove-Job -Force -ErrorAction SilentlyContinue
    $PoShEasyWin.Refresh()
    Start-Sleep -Seconds 1
}