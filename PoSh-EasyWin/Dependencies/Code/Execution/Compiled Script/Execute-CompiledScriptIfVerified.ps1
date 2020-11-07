if ($CommandReviewEditVerifyCheckbox.checked){
    New-Item -Type Directory -Path $script:CollectionSavedDirectoryTextBox.Text -ErrorAction SilentlyContinue

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Compiled Queries To Target Hosts")
    #$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $($TargetComputer)")

    $ExecutionStartTime = Get-Date
    # Clear any PoSh-EasyWin Jobs
    $ClearJobs = Get-Job -Name 'PoSh-EasyWin*'
    $ClearJobs | Stop-Job
    $ClearJobs | Receive-Job -Force
    $ClearJobs | Remove-Job -Force

    # Each command to each target host is executed on it's own process thread, which utilizes more memory overhead on the localhost [running PoSh-EasyWin] and produces many more network connections to targets [noisier on the network].
    Foreach ($TargetComputer in $script:ComputerList) {
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Sent to $($TargetComputer): `r`n$($script:CommandReviewEditRichTextbox.text)"

        # Executes the compiled jobs
        $script:CommandReviewEditRichTextboxText = $script:CommandReviewEditRichTextbox.text
        Start-Job -Name "PoSh-EasyWin: $CommandName -- $TargetComputer" -ScriptBlock {
            param($TargetComputer, $script:CommandReviewEditRichTextboxText, $script:Credential)
            # Available priority values: Low, BelowNormal, Normal, AboveNormal, High, RealTime
            [System.Threading.Thread]::CurrentThread.Priority = 'High'
            ([System.Diagnostics.Process]::GetCurrentProcess()).PriorityClass = 'High'

            Invoke-Expression -Command $script:CommandReviewEditRichTextboxText
        } -InitializationScript $null -ArgumentList @($TargetComputer, $script:CommandReviewEditRichTextboxText, $script:Credential)
    }

    # Checks Jobs for completion
    # This is similar to the Monitor-Job function, but specific to execution of compiled commands
    # Start: Job Monitoring
    $TargetComputerCount = $script:ComputerList.count
    $CompletedJobs = @()
    $ResultsListBox.Items.Insert(0,"")

        Start-Sleep -Seconds 1
        # The number of Jobs created by PoSh-EasyWin
        $PoShEasyWinJobs = Get-Job -Name "PoSh-EasyWin:*"
        $script:ProgressBarEndpointsProgressBar.minimum   = 0
        $script:ProgressBarEndpointsProgressBar.maximum   = $PoShEasyWinJobs.count

        While ($TargetComputerCount -gt 0) {
            foreach ($Job in $PoShEasyWinJobs) {
                if (($Job.State -eq 'Completed') -and ($Job.Name -notin $CompletedJobs)) {
                    $TargetComputerCount -= 1
                    $CompletedJobs += $Job.Name
                    #$script:ProgressBarEndpointsProgressBar.value = $CompletedJobs.count
                    $script:ProgressBarEndpointsProgressBar.Increment(1)
                    Start-Sleep -Milliseconds 250
                    $CollectionCommandEndTime  = Get-Date
                    $CollectionCommandDiffTime = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime
                    #$ResultsListBox.Items.RemoveAt(0)
                    #note: .split(@('--'),'none') allows me to split on "--", which is two characters
                    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$($CollectionCommandDiffTime)]  Completed: $(($Job.Name).split(@('--'),'none')[-1].trim())")
                }
            }
            Start-Sleep -Seconds 1
        }

        # Extracts individual query data from each jobs
        $CollectionTypes = @()
        foreach ($Job in $PoShEasyWinJobs) {
            if ($Job.Name -ne '' -and $Job.Command -ne '' -and $Job.Name -ne $null -and $Job.Command -ne $null) {
                # Writes output of single query collection as multiple separate files
                # Excludes system properties that begin with __

                $QueryFileName = $(($Job.Name -split ':')[1]).Trim()
                $ReceivedJob   = $(Receive-Job -Name "$($Job.Name)")
                Foreach ($key in $($ReceivedJob.keys)){
                    $Type     = (($ReceivedJob[$key]['Name'] -split '--').trim())[0]
                    $Query    = (($ReceivedJob[$key]['Name'] -split '--').trim())[1]
                    $Hostname = (($ReceivedJob[$key]['Name'] -split '--').trim())[2]
                    $SavePath = "$script:IndividualHostResults\$Query"

                    # Creates the directory to save the results to
                    New-Item -ItemType Directory -Path $SavePath -Force

                    # Saves results
                    $ReceivedJob[$key]['Results'] | Select-Object -Property * -ExcludeProperty __* | Export-Csv "$SavePath\$($Query) - $($Type) - $($Hostname).csv" -NoTypeInformation

                    # Creates a list of each type of collection, this is to be used later for compiling results
                    if ("$SavePath\$($Query) - $($Type)*.csv" -notin $CollectionTypes) { $CollectionTypes += "$SavePath\$($Query) - $($Type)*.csv" }
                }
            }
            Remove-Job -Name "$($Job.Name)" -Force
        } # End: Job Monitoring

        # This allows the Endpoint progress bar to appear completed momentarily
    $script:ProgressBarEndpointsProgressBar.Maximum = 1; $script:ProgressBarEndpointsProgressBar.Value = 1; Start-Sleep -Milliseconds 250

    # Compile results
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Compiling CSV Results From Target Hosts")
    foreach ($Collection in $CollectionTypes) {
        $CompiledFileName = "$(($Collection).split('\')[-1].split('*')[0])"
        Compile-CsvFiles -LocationOfCSVsToCompile $Collection -LocationToSaveCompiledCSV "$($script:CollectionSavedDirectoryTextBox.Text)\$($CompiledFileName).csv"
        Compile-XmlFiles -LocationOfXmlsToCompile $Collection -LocationToSaveCompiledXml "$($script:CollectionSavedDirectoryTextBox.Text)\$($CompiledFileName).xml"

        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Compiling CSV Files"
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "$($script:CollectionSavedDirectoryTextBox.Text)\$((($Command.Name) -split ' -- ')[1]) - $($Command.Type).csv"
    }

    Completed-QueryExecution
}
else {
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("ALERT: Query Cancelled!")
    $ResultsListBox.Items.Insert(0,"ALERT: The query has been cancelled!")
}

