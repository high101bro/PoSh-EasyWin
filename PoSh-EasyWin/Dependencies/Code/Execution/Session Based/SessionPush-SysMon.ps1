$CollectionCommandStartTime = Get-Date
$CollectionName = "Sysinternals Sysmon Configuration"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

# This directory is created by the parent script and is used by most other commands, but it's not needed here
# Whoopes... don't delete this, because if you push sysmon with other queries you'll delete all the results...
# Remove-Item -Path $script:CollectionSavedDirectoryTextBox.Text -Recurse -Force -ErrorAction SilentlyContinue

$script:ProgressBarEndpointsProgressBar.Value   = 0

$SysmonName           = "Sysmon"
$SysmonDriverName     = "SysmonDrv"
$SysmonExecutable     = "$SysmonName.exe"
$SysmonExecutablePath = "$ExternalPrograms\$SysmonExecutable"
$TargetFolder         = "C:\Windows\Temp"

# Renames sysmon Service/Process name in order to obfuscate deployent
if ($SysinternalsSysmonRenameServiceProcessTextBox.text -ne 'Sysmon') {
    Copy-Item -Path "$SysmonExecutablePath" -Destination "$ExternalPrograms\$($SysinternalsSysmonRenameServiceProcessTextBox.text).exe" -Force
    $SysmonName           = "$($SysinternalsSysmonRenameServiceProcessTextBox.text)"
    $SysmonExecutable     = "$($SysinternalsSysmonRenameServiceProcessTextBox.text).exe"
    $SysmonExecutablePath = "$ExternalPrograms\$SysmonExecutable"
}
# Renames sysmon Driver name in order to obfuscate deployent
if ($SysinternalsSysmonRenameDriverTextBox.text -ne 'SysmonDrv') {
    $SysmonDriverName = "$($SysinternalsSysmonRenameDriverTextBox.text)"
} 



Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Executing Sysmon"
$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copying over $SysmonExecutable and $Script:SysmonXMLName config file to:")
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Copying over $SysmonExecutable and $Script:SysmonXMLName config file to:"
$PoShEasyWin.Refresh()

foreach ($Session in $PSSession) {
    try { 
        Copy-Item -Path $SysmonExecutablePath -Destination "$TargetFolder" -ToSession $Session -Force -ErrorAction Stop 
        Copy-Item -Path $script:SysmonXMLPath -Destination "$TargetFolder" -ToSession $Session -Force -ErrorAction Stop                 
        $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
        Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $SysmonExecutablePath -Destination $TargetFolder -ToSession $Session -Force -ErrorAction Stop"
        Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $script:SysmonXMLPath -Destination $TargetFolder -ToSession $Session -Force -ErrorAction Stop"
        $PoShEasyWin.Refresh()

        $script:ProgressBarEndpointsProgressBar.Value += 1

        $PoShEasyWin.Refresh()
    }
    catch { 
        $ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copy $SysmonExecutable Error:  $($_.Exception)")
        Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Copy $SysmonExecutable Error: $($_.Exception)"
        $PoShEasyWin.Refresh()
        break
    }
}

if ($SysinternalsSysmonRenameServiceProcessTextBox.text -ne 'Sysmon') {
    # Removes the local renamed copy of Sysmon 
    Remove-Item "$ExternalPrograms\$($SysinternalsSysmonRenameServiceProcessTextBox.text).exe" -Force 
}

$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Configuring Sysmon")
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Configuring Sysmon on:"
$PoShEasyWin.Refresh()

$script:ProgressBarEndpointsProgressBar.Value = 0
foreach ($Session in $PSSession) {
    try {
        if ($SysinternalsSysmonRenameDriverTextBox.text -ne 'SysmonDrv' -and ($SysinternalsSysmonRenameDriverTextBox.text).length -ne 0 ) {
            # Checks if the Sysmon service exists, if not it will install sysmon and log it locally
            Invoke-Command -ScriptBlock {
                param($SysmonName,$SysmonDriverName,$TargetFolder,$SysmonExecutable,$Script:SysmonXMLName)                    
                # Installs Tool if service not detected
                if (-not (Get-Service -Name "$SysmonName")){
                    Start-Process -NoNewWindow -FilePath "$TargetFolder\$SysmonExecutable" -Argumentlist "/AcceptEula -i $TargetFolder\$Script:SysmonXMLName -d $SysmonDriverName"
                }
                # If the Tool service exists, it updates the configuration file
                else {
                    Start-Process -NoNewWindow -FilePath "$TargetFolder\$SysmonExecutable" -Argumentlist "/AcceptEula -c $TargetFolder\$Script:SysmonXMLName -d $SysmonDriverName "
                }
            } -Argumentlist @($SysmonName,$SysmonDriverName,$TargetFolder,$SysmonExecutable,$Script:SysmonXMLName) -Session $Session

            if (-not $(Invoke-Command -ScriptBlock { param($SysmonName); Get-Service -Name "$SysmonName" } -ArgumentList $SysmonName -Session $Session)) {
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Start-Process -NoNewWindow -FilePath `"$TargetFolder\$SysmonExecutable`" -ArgumentList `"/AcceptEula -i $TargetFolder\$Script:SysmonXMLName -d $SysmonDriverName`""
            }
            else {
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Start-Process -NoNewWindow -FilePath `"$TargetFolder\$SysmonExecutable`" -ArgumentList `"/AcceptEula -c $TargetFolder\$Script:SysmonXMLName -d $SysmonDriverName`""
            }
        }
        else {
            Invoke-Command -ScriptBlock {
                param($SysmonName,$SysmonDriverName,$TargetFolder,$SysmonExecutable,$Script:SysmonXMLName)                    
                # Installs Tool if service not detected
                if (-not (Get-Service -Name "$SysmonName")){
                    Start-Process -NoNewWindow -FilePath "$TargetFolder\$SysmonExecutable" -Argumentlist "/AcceptEula -i $TargetFolder\$Script:SysmonXMLName"
                }
                # If the Tool service exists, it updates the configuration file
                else {
                    Start-Process -NoNewWindow -FilePath "$TargetFolder\$SysmonExecutable" -Argumentlist "/AcceptEula -c $TargetFolder\$Script:SysmonXMLName"
                }
            } -Argumentlist @($SysmonName,$SysmonDriverName,$TargetFolder,$SysmonExecutable,$Script:SysmonXMLName) -Session $Session            
            
            if (-not $(Invoke-Command -ScriptBlock { param($SysmonName); Get-Service -Name "$SysmonName" } -ArgumentList $SysmonName -Session $Session)) {
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Start-Process -NoNewWindow -FilePath `"$TargetFolder\$SysmonExecutable`" -ArgumentList `"/AcceptEula -i $TargetFolder\$Script:SysmonXMLName`""
            }
            else {
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Start-Process -NoNewWindow -FilePath `"$TargetFolder\$SysmonExecutable`" -ArgumentList `"/AcceptEula -c $TargetFolder\$Script:SysmonXMLName`""
            }
        }

        $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
        $PoShEasyWin.Refresh()
    }
    catch { 
        $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Execute Sysmon Error:  $($_.Exception)")
        Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Execute Sysmon Error: $($_.Exception)"
        $PoShEasyWin.Refresh()
        break
    }
    $script:ProgressBarEndpointsProgressBar.Value = ($PSSession.ComputerName).Count
}

# Intended to ensure that autoruns has completed execution; this is not needed if using Start-Process with the -Wait parameter

$script:ProgressBarEndpointsProgressBar.Value = 0
$SysmonCompletedEndpoints = @()
$FirstCheck = $true
$SecondsToCheck = $ExternalProgramsCheckTimeTextBox.Text

while ($true) {
    # Results listbox count down visual
    if ($FirstCheck -eq $true) {
        foreach ( $sec in ($SecondsToCheck..1)) {
            if ($FirstCheck -eq $false) {$ResultsListBox.Items.RemoveAt(2)}
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Sysmon Configuration, Checking in $sec")
            $PoShEasyWin.Refresh()
            Start-Sleep -Seconds 1
            $FirstCheck = $false
        }
    }
    else {
        foreach ( $sec in (($SecondsToCheck)..1)) {
            $ResultsListBox.Items.RemoveAt(2)
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Sysmon Configuration, Checking in $Sec")
            $PoShEasyWin.Refresh()
            Start-Sleep -Seconds 1
        }
    }
    $ResultsListBox.Items.RemoveAt(2)
    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Sysmon Configuration")
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Checking if Sysmon is finished every $SecondsToCheck Seconds"
    $PoShEasyWin.Refresh()

    foreach ($Session in $PSSession) {
        if ($Session.ComputerName -notin $SysmonCompletedEndpoints) {
            Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Invoke-Command -ScriptBlock { Get-Service '$SysmonName' } -Session $Session"
            if (( Invoke-Command -ScriptBlock { Get-Service "$SysmonName" } -Session $Session )) {  
                $ResultsListBox.Items.Insert( 3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      Sysmon running on $($Session.ComputerName) - Removing $SysmonExecutable and $Script:SysmonXMLName")
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Sysmon running on $($Session.ComputerName) - Removing $SysmonExecutable and $Script:SysmonXMLName"
                $PoShEasyWin.Refresh()
                try {
                    Invoke-Command -ScriptBlock { 
                        param(
                            $TargetFolder,
                            $SysmonExecutable,
                            $SysmonXMLName
                        )
                        Remove-Item $TargetFolder\$SysmonExecutable -Recurse -Force 
                        Remove-Item $TargetFolder\$SysmonXMLName    -Recurse -Force
                    } -Argumentlist $TargetFolder,$SysmonExecutable,$Script:SysmonXMLName -Session $Session
                    Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Remove-Item $TargetFolder\$SysmonExecutable -Force "
                    Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Remove-Item $TargetFolder\$Script:SysmonXMLName -Force "
                    $PoShEasyWin.Refresh()
                }
                catch { 
                    $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      [!] Cleanup Error:  $($_.Exception)")
                    Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Cleanup Error: $($_.Exception)"
                    $PoShEasyWin.Refresh()
                    break
                }
                $SysmonCompletedEndpoints += $Session.ComputerName
            }
            else {
                $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      NOT Yet Running on $($Session.ComputerName)")
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Invoke-Command -ScriptBlock { Get-Service '$SysmonName' } -Session $Session"
                $PoShEasyWin.Refresh()
            }
            $script:ProgressBarEndpointsProgressBar.Value += 1            
            $PoShEasyWin.Refresh()
        }
    }
    # Breaks the loop when Sysmon is running on All Endpoints or the job time is exceeded
    if ( ((Invoke-Command -ScriptBlock {param($SysmonName) Get-Service -Name "$SysmonName" -ErrorAction SilentlyContinue } -ArgumentList $SysmonName -Session $PSSession).PScomputerName).count -eq $PSSession.count ) {
        break
    }
    # Not supported
    elseif ((Get-Date) -gt ( ($CollectionCommandStartTime).addseconds([int]$script:OptionJobTimeoutSelectionComboBox.text))) {
        $ResultsListBox.Items.Insert(3,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))      [!] Timeout: $CollectionName ($([int]$script:OptionJobTimeoutSelectionComboBox.Text) Seconds)")
        $PoShEasyWin.Refresh()
        break 
    }
}

$ResultsListBox.Items.RemoveAt(1)
$ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $CollectionCommandStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value += 1
$PoShEasyWin.Refresh()
Start-Sleep -match 500