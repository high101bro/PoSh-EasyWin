<#
    .Description
    This iterates though the commands selected and determines how to exactly execute them
    based off their labeled protocol and command type.
#>
Foreach ($Command in $script:CommandsCheckedBoxesSelected) {
    $script:ProgressBarEndpointsProgressBar.Value = 0
    $ProgressBarEndpointsCommandLine = 0

    $ExecutionStartTime = Get-Date
    $CollectionName = $Command.Name
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Executing: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
    $PoShEasyWin.Refresh()

    if ($Command.Type -eq "(WinRM) Script") {
        $CommandString = "$($Command.Command)"
        $script:OutputFileFileType = "csv"
    }
    elseif ($Command.Type -eq "(WinRM) PoSh") {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $script:OutputFileFileType = "csv"
    }
    elseif ($Command.Type -eq "(WinRM) WMI") {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $script:OutputFileFileType = "csv"
    }
    #elseif ($Command.Type -eq "(WinRM) CMD") {
    #    $CommandString = "$($Command.Command)"
    #    $script:OutputFileFileType = "txt"
    #}


    #elseif ($Command.Type -eq "(RPC) PoSh") {
    #    $CommandString = "$($Command.Command) | Select-Object -Property @{n='PSComputerName';e={`$TargetComputer}}, $($Command.Properties)"
    #    $script:OutputFileFileType = "csv"
    #}
    elseif (($Command.Type -eq "(RPC) WMI") -and ($Command.Command -match "Get-WmiObject")) {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $script:OutputFileFileType = "csv"
    }
    #elseif ($Command.Type -eq "(RPC) CMD") {
    #    $CommandString = "$($Command.Command)"
    #    $script:OutputFileFileType = "txt"
    #}




    elseif ($Command.Type -eq "(SMB) PoSh") {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $script:OutputFileFileType = "txt"
    }
    elseif ($Command.Type -eq "(SMB) WMI") {
        $CommandString = "$($Command.Command) | Select-Object -Property $($Command.Properties)"
        $script:OutputFileFileType = "txt"
    }
    elseif ($Command.Type -eq "(SMB) CMD") {
        $CommandString = "$($Command.Command)"
        $script:OutputFileFileType = "txt"
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
        Invoke-Command -FilePath $CommandString -Session $PSSession | Select-Object -Property PSComputerName, * -ExcludeProperty "__*",RunspaceID `
        | Set-Variable SessionData
        $SessionData | Export-Csv -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml"
        Remove-Variable -Name SessionData
    }
    elseif ( $script:OutputFileFileType -eq "csv" ) {
        $OutputFilePath = "$script:CollectedDataTimeStampDirectory\$((($CommandName) -split ' -- ')[1]) - $CommandType"
        Remove-Item -Path "$OutputFilePath.csv" -Force -ErrorAction SilentlyContinue
        Invoke-Command -ScriptBlock { param($CommandString); Invoke-Expression -Command $CommandString } -argumentlist $CommandString -Session $PSSession `
        | Set-Variable SessionData
        $SessionData | Export-Csv -Path "$OutputFilePath.csv" -NoTypeInformation -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force
    }
    elseif ( $script:OutputFileFileType -eq "txt" ) {
        $OutputFilePath = "$script:CollectedDataTimeStampDirectory\$((($CommandName) -split ' -- ')[1]) - $CommandType - $($TargetComputer)"
        Remove-Item -Path "$OutputFilePath.txt" -Force -ErrorAction SilentlyContinue
        Invoke-Command -ScriptBlock { param($CommandString); Invoke-Expression -Command $CommandString } -argumentlist $CommandString -Session $PSSession `
        | Set-Variable SessionData
        $SessionData | Out-File -Path "$OutputFilePath.txt" -Force
        $SessionData | Export-Clixml -Path "$OutputFilePath.xml" -Force
        Remove-Variable -Name SessionData -Force
    }


    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
    $PoShEasyWin.Refresh()


    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Invoke-Command -ScriptBlock { param($CommandString); Invoke-Expression -Command $CommandString } -argumentlist $CommandString -Session `$PSSession"


    $script:ProgressBarQueriesProgressBar.Value   += 1
    $script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
    $PoShEasyWin.Refresh()
    Start-Sleep -match 500
}


