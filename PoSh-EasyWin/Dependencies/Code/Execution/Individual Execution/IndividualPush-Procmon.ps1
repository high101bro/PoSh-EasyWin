# Executes RPC/DCOM based commands if the RPC Radio Button is Checked
if ($ExternalProgramsRPCRadioButton.checked) {
    $CollectionName = "Procmon"
    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


    $ProcMonDuration = switch ($script:SysinternalsProcessMonitorTimeComboBox.text) {
        '5 Seconds'   {5}
        '10 Seconds'  {10}
        '15 Seconds'  {15}
        '30 Seconds'  {30}
        '1 Minute'    {60}
        '2 Minutes'   {120}
        '3 Minutes'   {180}
        '4 Minutes'   {240}
        '5 Minutes'   {360}
        Default       {5}
    }

    # Collect Remote host Disk Space
    # Diskspace is calculated on local and target hosts to determine if there's a risk
    # Procmon is copied over to the target host, and data is gathered there and then exported back
    # The Procmon program and capture file are deleted
    Function Get-DiskSpace {
        param([string] $TargetComputer)
        try {
            $HD = Get-WmiObject Win32_LogicalDisk -ComputerName $TargetComputer -Filter "DeviceID='C:'" -ErrorAction Stop
            Create-LogEntry -TargetComputer $TargetComputer -LogFile $LogFile -Message "Get-DiskSpace:  Get-WmiObject Win32_LogicalDisk -ComputerName $TargetComputer -Filter `"DeviceID='C:'`" -ErrorAction Stop"
        }
        catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Unable to connect to $TargetComputer. $_")
            continue
        }
        if (!$HD) { throw }
        $FreeSpace = [math]::round(($HD.FreeSpace/1gb),2)
        return $FreeSpace
    }

    $ProcmonName                   = 'ProcMon'
    $ProcmonExecutable             = "$ProcmonName.exe"
    $AdminShare                    = 'C$'
    $RemoteDrive                   = 'C:'
    $LocalPathForProcmonExecutable = "$ExternalPrograms\Procmon.exe"
    $TargetFolder                  = "Windows\Temp"

    New-Item -Type Directory -Path $script:CollectionSavedDirectoryTextBox.Text -ErrorAction SilentlyContinue

    # Renames Procmon Process name in order to obfuscate deployent
    if ($SysinternalsProcmonRenameProcessTextBox.text -ne 'Procmon') {
        Copy-Item -Path "$LocalPathForProcmonExecutable" -Destination "$ExternalPrograms\$($SysinternalsProcmonRenameProcessTextBox.text).exe" -Force
        $ProcmonName                   = "$($SysinternalsProcmonRenameProcessTextBox.text)"
        $ProcmonExecutable             = "$($SysinternalsProcmonRenameProcessTextBox.text).exe"
        $LocalPathForProcmonExecutable = "$ExternalPrograms\$ProcmonExecutable"
    }


    foreach ($TargetComputer in $script:ComputerList) {
        $ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) Collecting $CollectionName - $TargetComputer")
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

        # Process monitor generates enormous amounts of data.
        # To try and offer some protections, the script won't run if the source or target have less than 500MB free
        $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Verifying free diskspace on localhost and endpoints")
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Verifying free diskspace on localhost and endpoints"
        $PoShEasyWin.Refresh()
        if ( $(Get-DiskSpace -TargetComputer $TargetComputer) -lt 0.5) {
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] $TargetComputer has less than 500MB free - aborting as precaution")
            Create-LogEntry -LogFile $LogFile -TargetComputer "[!] $TargetComputer has less than 500MB free - aborting as precaution"
            break
        }

        if ( $(Get-DiskSpace -TargetComputer $Env:ComputerName) -lt 0.5 ) {
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Local computer has less than 500MB free - aborting as precaution")
            Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Local computer ($Env:ComputerName) has less than 500MB free - aborting as precaution"
            break
        }

        $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [+] Copying $ProcmonName to $TargetComputer")
        try {
            Copy-Item $LocalPathForProcmonExecutable "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop
            Create-LogEntry -TargetComputer $TargetComputer -LogFile $LogFile -Message "Copy-Item $LocalPathForProcmonExecutable `"\\$TargetComputer\$AdminShare\$TargetFolder`" -Force -ErrorAction Stop "
        }
        catch {
            $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copy Error: $($_.Exception)")
            Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Copy Error: $($_.Exception)"
            $PoShEasyWin.Refresh()
            break
        }

        # Process monitor must be launched as a separate process otherwise the sleep and terminate commands below would never execute and fill the disk
        $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Starting process monitor on $TargetComputer")
        ### $Command = Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/AcceptEULA $script:Credential -s \\$TargetComputer $RemoteDrive\$TargetFolder\$ProcmonExecutable /AcceptEULA /BackingFile $RemoteDrive\$TargetFolder\$TargetComputer /RunTime 10 /Quiet" -PassThru | Out-Null
        ### $Command = Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/AcceptEULA -s \\$TargetComputer $RemoteDrive\$TargetFolder\$ProcmonExecutable /AcceptEULA /BackingFile `"$RemoteDrive\$TargetFolder\$ProcmonName-$TargetComputer`" /RunTime $ProcMonDuration /Quiet" -PassThru | Out-Null
        ### $Command
        Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList "$RemoteDrive\$TargetFolder\$ProcmonExecutable /AcceptEULA /BackingFile $RemoteDrive\$TargetFolder\$ProcmonName /RunTime $ProcMonDuration /Quiet"

        Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "$($SysinternalsProcessMonitorCheckbox.Name)"
        #Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "$Command"
        Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList `"$RemoteDrive\$TargetFolder\$ProcmonExecutable /AcceptEULA /BackingFile $RemoteDrive\$TargetFolder\$ProcmonName /RunTime $ProcMonDuration /Quiet`""

        $FirstCheck      = $true
        $SecondsToCheck  = $ExternalProgramsCheckTimeTextBox.Text

        while ($true) {
            # Results listbox count down visual
            if ($FirstCheck -eq $true) {
                foreach ( $sec in (($ProcMonDuration + $SecondsToCheck)..1)) {
                    if ($FirstCheck -eq $false) {$ResultsListBox.Items.RemoveAt(2)}
                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Procmon Configuration, Checking in $sec")
                    $PoShEasyWin.Refresh()
                    Start-Sleep -Seconds 1
                    $FirstCheck = $false
                }
            }
            else {
                foreach ( $sec in (($SecondsToCheck)..1)) {
                    $ResultsListBox.Items.RemoveAt(2)
                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Procmon Configuration, Checking in $Sec")
                    $PoShEasyWin.Refresh()
                    Start-Sleep -Seconds 1
                }
            }
            $ResultsListBox.Items.RemoveAt(2)
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Procmon Collection")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Checking if Promon is finished every $SecondsToCheck Seconds"
            $PoShEasyWin.Refresh()


            if ( $(Get-WmiObject -Class Win32_Process -ComputerName $TargetComputer | Where-Object ProcessName -match "Procmon") ) {
                $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Checking ProcMon Status on $TargetComputer (Every 30 Seconds)"
                $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] $Message")
                Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message $Message
                Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "Get-WmiObject -Class Win32_Process -ComputerName $TargetComputer | Where-Object ProcessName -match `"Procmon`""
            }
            else {
                $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [+] Copying $ProcmonName data to local machine for analysis")
                try {
                    Copy-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$ProcmonName.pml" "$script:IndividualHostResults\$CollectionName" -Force -ErrorAction Stop
                    Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "Copy-Item `"\\$TargetComputer\$AdminShare\$TargetFolder\$ProcmonName.pml`" `"$script:IndividualHostResults\$CollectionName`" -Force -ErrorAction Stop"
                }
                catch { $_ }

                $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [-] Removing $ProcmonName executable and data file from $TargetComputer")

                Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$ProcmonName.pml" -Force
                Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "Remove-Item `"\\$TargetComputer\$AdminShare\$TargetFolder\$ProcmonName.pml`" -Force"

                Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$ProcmonExecutable" -Force
                Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "Remove-Item `"\\$TargetComputer\$AdminShare\$TargetFolder\$ProcmonName.exe`" -Force"

                Rename-Item "$script:IndividualHostResults\$CollectionName\$ProcmonName.pml" "$script:IndividualHostResults\$CollectionName\ProcMon-$TargetComputer.pml" -Force
                $FileSize = [math]::round(((Get-Item "$script:IndividualHostResults\$CollectionName\ProcMon-$TargetComputer.pml").Length/1mb),2)
                $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] ..\ProcMon-$TargetComputer.pml is $FileSize MB.")

                #$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Launching $ProcmonName and loading collected log data")
                #if(Test-Path("$script:IndividualHostResults\$CollectionName\ProcMon-$TargetComputer.pml")) { & $LocalPathForProcmonExecutable /openlog $script:IndividualHostResults\$CollectionName\ProcMon-$TargetComputer.pml }
                break
            }
        }


        $CollectionCommandEndTime1  = Get-Date
        $CollectionCommandDiffTime1 = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime1
        $ResultsListBox.Items.RemoveAt(1)
        $ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime1]  $CollectionName - $TargetComputer")
    }

    if ($SysinternalsProcmonRenameProcessTextBox.text -ne 'Procmon') {
        # Removes the local renamed copy of Procmon
        Remove-Item "$ExternalPrograms\$($SysinternalsProcmonRenameProcessTextBox.text).exe" -Force
    }

    $SysinternalsProcmonButton.BackColor = 'LightGreen'

    $CollectionCommandEndTime0  = Get-Date
    $CollectionCommandDiffTime0 = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime0
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime0]  $CollectionName")
}

# Executes WinRM based commands over PSSessions if the WinRM Radio Button is Checked
elseif ($ExternalProgramsWinRMRadioButton.checked) {
    New-Item -Type Directory -Path $script:CollectionSavedDirectoryTextBox.Text -ErrorAction SilentlyContinue

    $PSSession = New-PSSession -ComputerName $script:ComputerList | Sort-Object ComputerName
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "WinRM Collection Started to $($PSSession.count) Endpoints"
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $($PSSession.ComputerName -join ', ')"

    # Unchecks hosts that do not have a session established
    . "$Dependencies\Code\Execution\Session Based\Uncheck-ComputerTreeNodesWithoutSessions.ps1"

    if ($PSSession.count -eq 1) {
        $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Session Created to $($PSSession.count) Endpoint")
    }
    elseif ($PSSession.count -gt 1) {
        $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Sessions Created to $($PSSession.count) Endpoints")
    }
    else {
        $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Unabled to push Sysmon because a WinRM sessions could not be established")
        [system.media.systemsounds]::Exclamation.play()
    }
    $PoShEasyWin.Refresh()

    $script:ProgressBarQueriesProgressBar.Maximum   = $CountCommandQueries
    $script:ProgressBarEndpointsProgressBar.Maximum = ($PSSession.ComputerName).Count


    if ($PSSession.count -ge 1) {
        . "$Dependencies\Code\Execution\Session Based\SessionPush-Procmon.ps1"
    }
    Get-PSSession | Remove-PSSession
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remove-PSSession -ComputerName $($PSSession.ComputerName -join ', ')"

}





