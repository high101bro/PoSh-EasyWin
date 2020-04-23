function Monitor-Jobs {
    # Initially updates statistics
    $StatisticsResults = Get-PoShACMEStatistics
    $StatisticsNumberOfCSVs.text = $StatisticsResults        

    $SleepMilliseconds = 250
    $ProgressBarEndpointsProgressBar.Value = 0
    $JobsLaunch = Get-Date 
    
    # Sets the job timeout value, so they don't run forever
    $JobsTimer  = [int]$($OptionJobTimeoutSelectionComboBox.Text)

    # This is how often the statistics page updates, be default it is 20 which is 5 seconds (250 ms x 4)
    $StatisticsUpdateInterval      = (1000 / $SleepMilliseconds) * $OptionStatisticsUpdateIntervalCombobox.text
    $StatisticsUpdateIntervalCount = 0

    do {
        # Updates Statistics 
        $StatisticsUpdateIntervalCount++
        if (($StatisticsUpdateIntervalCount % $StatisticsUpdateInterval) -eq 0) {
            $StatisticsResults = Get-PoShACMEStatistics
            $StatisticsNumberOfCSVs.text = $StatisticsResults        
        }
        
        # The number of Jobs created by PoSh-ACME
        $CurrentJobs                = Get-Job -Name "PoSh-ACME:*"
        $jobscount                  = $CurrentJobs.count                  
        $ProgressBarEndpointsProgressBar.Maximum = $jobscount

        # Gets the results from jobs that are completed
        $CurrentJobs | Receive-Job -Force

        # Counts the total of completed jobs for each update
        $done = 0
        foreach ($job in $CurrentJobs) { if ($($job.state) -eq "Completed") {$done++} }
        $ProgressBarEndpointsProgressBar.Value = $done 
        
        # Calcualtes and formats time elaspsed
        $CurrentTime = Get-Date
        $Timecount   = $JobsLaunch - $CurrentTime        
        $hour        = [Math]::Truncate($Timecount)
        $minute      = ($CollectionTime - $hour) * 60
        $second      = [int](($minute - ([Math]::Truncate($minute))) * 60)
        $minute      = [Math]::Truncate($minute)
        $Timecount   = [datetime]::Parse("$hour`:$minute`:$second")

        # Provides updates on the jobs
        $ResultsListBox.Items.Insert(0,"Running Jobs:  $($jobscount - $done)")        
        $ResultsListBox.Items.Insert(1,"Current Time:  $($currentTime)")
        $ResultsListBox.Items.Insert(2,"Elasped Time:  $($Timecount -replace '-','')")
        $ResultsListBox.Items.Insert(3,"")
        $ExecutionStatusCheckedListBox.Items.Add("$JobsHosts")

        # This is how often PoSoh-ACME's GUI will refresh when provide the status of the jobs
        # Default have is 250 ms. If you change this, be sure to update the $StatisticsUpdateInterval variarible within this function
        Start-Sleep -Milliseconds $SleepMilliseconds
        $ResultsListBox.Refresh()

        # Checks if the current job is running too long and stops it
        foreach ($Job in $CurrentJobs) {
            if ($Job.PSBeginTime -lt $(Get-Date).AddSeconds(-$JobsTimer)) {
                $TimeStamp = $(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')
                $ResultsListBox.Items.insert(5,"$($TimeStamp)   - Job Timed Out: $((($Job | Select-Object -ExpandProperty Name) -split '-')[-1])")
                $JobsKillTime = Get-Date
                $Job | Stop-Job 
                $Job | Receive-Job -Force 
                $Job | Remove-Job -Force
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message " - Job [TIMED OUT]: `"$($Job.Name)`" - Started at $($Job.PSBeginTime) - Ran for $($JobsKillTime - $Job.PSBeginTime)"
                break
            }
        }
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)
        $ResultsListBox.Items.RemoveAt(0)  
    } while ($done -lt $jobscount)

    # Logs Jobs Beginning and Ending Times
    foreach ($Job in $CurrentJobs) {
        if ($($Job.PSEndTime -ne $null)) {
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message " - Job [COMPLETED]: `"$($Job.Name)`" - Started at $($Job.PSBeginTime) - Ended at $($Job.PSEndTime)"
        }
    }

    # Updates Statistics One last time
    $StatisticsResults = Get-PoShACMEStatistics
    $StatisticsNumberOfCSVs.text = $StatisticsResults        
    Get-Job -Name "PoSh-ACME:*" | Remove-Job -Force -ErrorAction SilentlyContinue
    $PoShACME.Refresh()
    Start-Sleep -Seconds 1
}