# Executes RPC/DCOM based commands if the RPC Radio Button is Checked
if ($ExternalProgramsRPCRadioButton.checked) {
    $CollectionName = "Sysmon"
    $CollectionCommandStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Insert(0,"Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    $PoShEasyWin.Refresh()

    # This directory is created by the parent script and is used by most other commands, but it's not needed here
    # Whoopes... don't delete this, because if you push sysmon with other queries you'll delete all the results...
    #Remove-Item -Path $script:CollectionSavedDirectoryTextBox.Text -Recurse -Force -ErrorAction SilentlyContinue

    $SysmonName           = 'Sysmon'
    $SysmonDriverName     = "SysmonDrv"
    $SysmonExecutable     = "$SysmonName.exe"
    $SysmonExecutablePath = "$ExternalPrograms\$SysmonExecutable"
    $AdminShare           = 'c$'
    $LocalDrive           = 'c:'
    $TargetFolder         = "Windows\Temp"
    #$PsExecPath           = "$ExternalPrograms\PsExec.exe"

    # Renames sysmon Service/Process name in order to obfuscate deployent
    if ($SysinternalsSysmonRenameServiceProcessTextBox.text -ne 'Sysmon') {
        Copy-Item -Path "$SysmonExecutablePath" -Destination "$ExternalPrograms\$($SysinternalsSysmonRenameServiceProcessTextBox.text).exe" -Force
        $SysmonName       = "$($SysinternalsSysmonRenameServiceProcessTextBox.text)"
        $SysmonExecutable = "$($SysinternalsSysmonRenameServiceProcessTextBox.text).exe"
        $SysmonExecutablePath = "$ExternalPrograms\$SysmonExecutable"
    }
    # Renames sysmon Driver name in order to obfuscate deployent
    if ($SysinternalsSysmonRenameDriverTextBox.text -ne 'SysmonDrv') {
        $SysmonDriverName = "$($SysinternalsSysmonRenameDriverTextBox.text)"
    }

    foreach ($TargetComputer in $script:ComputerList) {
        $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName - $TargetComputer")
        $PoShEasyWin.Refresh()
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

        # Checks is the sysmon service is already installed, if so it updates the sysmon configuration
        if ($(Get-Service -ComputerName $TargetComputer -Name $SysmonName)){
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] $SysmonName is already an installed service on $TargetComputer")
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $SysmonName to $TargetComputer to update $SysmonName configuration")
            $PoShEasyWin.Refresh()
            try { Copy-Item $SysmonExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop }
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $Script:SysmonXMLName config file to $TargetComputer to be used by $SysmonName")
            $PoShEasyWin.Refresh()
            try { Copy-Item $script:SysmonXMLPath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop }
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Updating $SysmonName configuration on $TargetComputer")
            $PoShEasyWin.Refresh()
            #Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/AcceptEULA -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysmonExecutable -AcceptEULA -c '$LocalDrive\$TargetFolder\$Script:SysmonXMLName' -d $SysmonDriverName" -PassThru | Out-Null
            if ($SysinternalsSysmonRenameDriverTextBox.text -ne 'SysmonDrv' -and ($SysinternalsSysmonRenameDriverTextBox.text).length -ne 0 ) {
                Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList "$LocalDrive\$TargetFolder\$SysmonExecutable -AcceptEULA -c $LocalDrive\$TargetFolder\$Script:SysmonXMLName -d $SysmonDriverName"
                Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message "Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList `"$LocalDrive\$TargetFolder\$SysmonExecutable -AcceptEULA -c $LocalDrive\$TargetFolder\$Script:SysmonXMLName -d $SysmonDriverName`""
            }
            else {
                Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList "$LocalDrive\$TargetFolder\$SysmonExecutable -AcceptEULA -c $LocalDrive\$TargetFolder\$Script:SysmonXMLName"
                Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message "Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList `"$LocalDrive\$TargetFolder\$SysmonExecutable -AcceptEULA -c $LocalDrive\$TargetFolder\$Script:SysmonXMLName`""
            }
            Start-Sleep -Seconds 5

            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Removing $SysmonName executable and $Script:SysmonXMLName from $TargetComputer")
            Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysmonExecutable" -Force
            Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$Script:SysmonXMLName" -Force
        }
        # If sysmon is not a service, it will install sysmon with the selected configuration
        else {
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $SysmonName to $TargetComputer")
            $PoShEasyWin.Refresh()
            try { Copy-Item $SysmonExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop }
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $Script:SysmonXMLName config file to $TargetComputer to be used by $SysmonName")
            $PoShEasyWin.Refresh()
            try { Copy-Item $script:SysmonXMLPath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop }
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Installing $SysmonName on $TargetComputer")
            $PoShEasyWin.Refresh()
            #Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/AcceptEULA -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysmonExecutable /AcceptEULA -i '$LocalDrive\$TargetFolder\$Script:SysmonXMLName' -d $SysmonDriverName" -PassThru | Out-Null
            if ($SysinternalsSysmonRenameDriverTextBox.text -ne 'SysmonDrv' -and ($SysinternalsSysmonRenameDriverTextBox.text).length -ne 0 ) {
                Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList "$LocalDrive\$TargetFolder\$SysmonExecutable -AcceptEULA -i $LocalDrive\$TargetFolder\$Script:SysmonXMLName -d $SysmonDriverName"
                Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message "Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList `"$LocalDrive\$TargetFolder\$SysmonExecutable -AcceptEULA -i $LocalDrive\$TargetFolder\$Script:SysmonXMLName -d $SysmonDriverName`""
            }
            else {
                Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList "$LocalDrive\$TargetFolder\$SysmonExecutable -AcceptEULA -i $LocalDrive\$TargetFolder\$Script:SysmonXMLName"
                Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message "Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList `"$LocalDrive\$TargetFolder\$SysmonExecutable -AcceptEULA -i $LocalDrive\$TargetFolder\$Script:SysmonXMLName`""
            }
            Start-Sleep -Seconds 5

            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Removing $SysmonName executable and $Script:SysmonXMLName from $TargetComputer")
            $PoShEasyWin.Refresh()
            #Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysmonExecutable" -Force
            #Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$Script:SysmonXMLName" -Force
        }
        $CollectionCommandEndTime1  = Get-Date
        $CollectionCommandDiffTime1 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime1
        $ResultsListBox.Items.RemoveAt(1)
        $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime1]  $CollectionName - $TargetComputer")
        $PoShEasyWin.Refresh()
    }

    if ($SysinternalsSysmonRenameServiceProcessTextBox.text -ne 'Sysmon') {
        # Removes the local renamed copy of Sysmon
        Remove-Item "$ExternalPrograms\$($SysinternalsSysmonRenameServiceProcessTextBox.text).exe" -Force
    }
    $CollectionCommandEndTime0  = Get-Date
    $CollectionCommandDiffTime0 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime0
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime0]  $CollectionName")
    $PoShEasyWin.Refresh()
}

# Executes WinRM based commands over PSSessions if the WinRM Radio Button is Checked
elseif ($ExternalProgramsWinRMRadioButton.checked) {
    New-Item -Type Directory -Path $script:CollectionSavedDirectoryTextBox.Text -ErrorAction SilentlyContinue

    if ($ComputerListProvideCredentialsCheckBox.Checked) {
        if (!$script:Credential) { Create-NewCredentials }
            $PSSession = New-PSSession -ComputerName $script:ComputerList -Credential $script:Credential
    }
    else {
        $PSSession = New-PSSession -ComputerName $script:ComputerList
    }

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
        $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  Unable to push Sysmon because a WinRM sessions could not be established")
        [system.media.systemsounds]::Exclamation.play()
    }
    $PoShEasyWin.Refresh()

    $script:ProgressBarQueriesProgressBar.Maximum   = $CountCommandQueries
    $script:ProgressBarEndpointsProgressBar.Maximum = ($PSSession.ComputerName).Count


    if ($PSSession.count -ge 1) {
        . "$Dependencies\Code\Execution\Session Based\SessionPush-SysMon.ps1"
    }
    Get-PSSession | Remove-PSSession
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remove-PSSession -ComputerName $($PSSession.ComputerName -join ', ')"

    $SysinternalsAutorunsButton.BackColor = 'LightGreen'
}




