Foreach ($Command in $script:CommandsCheckedBoxesSelected) {
    $script:ProgressBarEndpointsProgressBar.Value = 0
    $ProgressBarEndpointsCommandLine = 0

    $CollectionCommandStartTime = Get-Date
    $CollectionName = $Command.Name
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Executing: $CollectionName")
    $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
    $PoShEasyWin.Refresh()

    if (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Get-WmiObject")) {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $OutputFileFileType = "csv"
    }
    elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Invoke-WmiMethod")) {
        $CommandString = "$($Command.Command)"
        $OutputFileFileType = "txt"
    }
    elseif ($Command.Type -eq "(WinRM) Script") {
        $CommandString = "$($Command.Command)"
        $OutputFileFileType = "csv"
    }
    elseif ($Command.Type -eq "(WinRM) PoSh") {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $OutputFileFileType = "csv"
    }
    elseif ($Command.Type -eq "(WinRM) WMI") {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $OutputFileFileType = "csv"
    }
    elseif ($Command.Type -eq "(WinRM) CMD") {
        $CommandString = "$($Command.Command)"
        $OutputFileFileType = "txt"
    }
    elseif ($Command.Type -eq "(RPC) PoSh") {
        $CommandString = "$($Command.Command) | Select-Object -Property @{n='PSComputerName';e={`$TargetComputer}}, $($Command.Properties)"
        $OutputFileFileType = "csv"
    }
    
    $CommandName = $Command.Name
    $CommandType = $Command.Type

  
    # Checks for the file output type, removes previous results with a file, then executes the commands
    if ( $Command.Type -eq "(WinRM) Script" ) {
        $OutputFilePath = "$script:CollectedDataTimeStampDirectory\$((($CommandName) -split ' -- ')[1]) - $CommandType"
        Remove-Item -Path "$OutputFilePath.csv" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$OutputFilePath.xml" -Force -ErrorAction SilentlyContinue

        #The following string replacements edits the command to be compatible with session based queries witj -filepath
        $CommandString = $CommandString.replace('Invoke-Command -FilePath ','').replace("'","").replace('"','')
        Invoke-Command -FilePath $CommandString -Session $PSSession | Select-Object -Property PSComputerName, * -ExcludeProperty "__*" `
        | Set-Variable SessionData
        $SessionData | Export-Csv -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml"
        Remove-Variable -Name SessionData
    }   
    elseif ( $OutputFileFileType -eq "csv" ) {
        $OutputFilePath = "$script:CollectedDataTimeStampDirectory\$((($CommandName) -split ' -- ')[1]) - $CommandType"
        Remove-Item -Path "$OutputFilePath.csv" -Force -ErrorAction SilentlyContinue
        Invoke-Command -ScriptBlock { param($CommandString); Invoke-Expression -Command $CommandString } -argumentlist $CommandString -Session $PSSession `
        | Set-Variable SessionData
        $SessionData | Export-Csv -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force
    }
    elseif ( $OutputFileFileType -eq "txt" ) {
        $OutputFilePath = "$script:CollectedDataTimeStampDirectory\$((($CommandName) -split ' -- ')[1]) - $CommandType - $($TargetComputer)"
        Remove-Item -Path "$OutputFilePath.txt" -Force -ErrorAction SilentlyContinue
        Invoke-Command -ScriptBlock { param($CommandString); Invoke-Expression -Command $CommandString } -argumentlist $CommandString -Session $PSSession `
        | Set-Variable SessionData
        $SessionData | Out-File -Path "$OutputFilePath.txt" -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force
    }
    $ResultsListBox.Items.RemoveAt(1)
    $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $CollectionCommandStartTime -End (Get-Date))]  $CollectionName")
    $PoShEasyWin.Refresh()

    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Invoke-Command -ScriptBlock { param($CommandString); Invoke-Expression -Command $CommandString } -argumentlist $CommandString -Session `$PSSession"

    $script:ProgressBarQueriesProgressBar.Value   += 1
    $script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
    $PoShEasyWin.Refresh()
    Start-Sleep -match 500

    if ($NoGUI){
        $ProgressBarQueriesCommandLine   += 1
        Write-Progress -Id 1 -Activity Updating -Status "Query: $CollectionName" -PercentComplete ($ProgressBarQueriesCommandLine / $ProgressBarQueriesCommandLineMaximum * 100) -CurrentOperation "Please be patient as queries are being executed..."
    }
}

$AutoCreateDashboardChartButton.BackColor = 'LightGreen'
$AutoCreateMultiSeriesChartButton.BackColor = 'LightGreen'
$BuildChartButton.BackColor = 'LightGreen'
