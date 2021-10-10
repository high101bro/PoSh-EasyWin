$ExecutionStartTime = Get-Date
$CollectionName = "Sysinternals AutoRuns Collection"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

$AutorunsName                   = 'Autoruns'
$AutorunsExecutable             = "$AutorunsName.exe"
$LocalPathForAutorunsExecutable = "$ExternalPrograms\$AutorunsExecutable"
$TargetFolder                   = "C:\Windows\Temp"

New-Item "$script:IndividualHostResults\Autoruns" -Type Directory

# Renames Autoruns Process name in order to obfuscate deployent
if ($SysinternalsAutorunsRenameProcessTextBox.text -ne 'Autoruns') {
    Copy-Item -Path "$LocalPathForAutorunsExecutable" -Destination "$ExternalPrograms\$($SysinternalsAutorunsRenameProcessTextBox.text).exe" -Force
    $AutorunsName                   = "$($SysinternalsAutorunsRenameProcessTextBox.text)"
    $AutorunsExecutable             = "$($SysinternalsAutorunsRenameProcessTextBox.text).exe"
    $LocalPathForAutorunsExecutable = "$ExternalPrograms\$AutorunsExecutable"
}


Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Executing Autoruns"
$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copying over $AutorunsExecutable to:")
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Copying over $AutorunsExecutable to:"
$PoShEasyWin.Refresh()


$script:ProgressBarEndpointsProgressBar.Value = 0
foreach ($Session in $PSSession) {
    try {
        Copy-Item -Path $LocalPathForAutorunsExecutable -Destination "$TargetFolder" -ToSession $Session -Force -ErrorAction Stop
        $ResultsListBox.Items.insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
        Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $LocalPathForAutorunsExecutable -Destination '$TargetFolder' -ToSession $Session -Force -ErrorAction Stop"
        $PoShEasyWin.Refresh()
    }
    catch {
        $ResultsListBox.Items.insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copy Error: $($_.Exception)")
        Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Copy Error: $($_.Exception)"
        $PoShEasyWin.Refresh()
        break
    }
    $script:ProgressBarEndpointsProgressBar.Value += 1
    $PoShEasyWin.Refresh()
}

if ($SysinternalsAutorunsRenameProcessTextBox.text -ne 'Autoruns') {
    # Removes the local renamed copy of Autoruns
    Remove-Item "$ExternalPrograms\$($SysinternalsAutorunsRenameProcessTextBox.text).exe" -Force
}

$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Executing Autoruns on:")
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Executing $AutorunsExecutable on:"
$PoShEasyWin.Refresh()
$script:ProgressBarEndpointsProgressBar.Value = 0
foreach ($Session in $PSSession) {
    Invoke-Command -ScriptBlock {
        param(
            $RemoteDrive,
            $TargetFolder,
            $AutorunsName
        )
        Start-Process -NoNewWindow -FilePath "$TargetFolder\$AutorunsName.exe" -ArgumentList "/AcceptEULA -a $TargetFolder\$AutorunsName.arn"
    } -ArgumentList @($RemoteDrive,$TargetFolder,$AutorunsName) -Session $Session
    $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
    Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Start-Process -NoNewWindow -Wait -FilePath '$TargetFolder\$AutorunsName.exe' -ArgumentList '/AcceptEULA -a $TargetFolder\$AutorunsName.arn'"
    $PoShEasyWin.Refresh()
    $script:ProgressBarEndpointsProgressBar.Value += 1
    $PoShEasyWin.Refresh()
}
# Delay needed to ensure Tool has time to start
$SecondsToCheck = $ExternalProgramsTimoutOutTextBox.Text

$script:ProgressBarEndpointsProgressBar.Value = 0
$AutoRunsCompletedEndpoints = @()
$FirstCheck = $true
while ($true) {
    if ($FirstCheck -eq $true) {
        foreach ( $sec in ($SecondsToCheck..1)) {
            if ($FirstCheck -eq $false) {$ResultsListBox.Items.RemoveAt(2)}
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Gathering Autoruns data, Checking in $sec")
            $PoShEasyWin.Refresh()
            Start-Sleep -Seconds 1
            $FirstCheck = $false
        }
    }
    else {
        foreach ( $sec in (($SecondsToCheck)..1)) {
            $ResultsListBox.Items.RemoveAt(2)
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Gathering Autoruns data, Checking in $Sec")
            $PoShEasyWin.Refresh()
            Start-Sleep -Seconds 1
        }
    }
    $ResultsListBox.Items.RemoveAt(2)
    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Gathering Autoruns data")
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Checking Autoruns every $SecondsToCheck Seconds"
    $PoShEasyWin.Refresh()

    foreach ($Session in $PSSession) {

        if ($Session.ComputerName -notin $AutoRunsCompletedEndpoints) {
            if ($( Invoke-Command -ScriptBlock {param($AutorunsName); Get-Process $AutorunsName } -ArgumentList $AutorunsName -Session $Session )) {
                $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      Still Running on $($Session.ComputerName)")
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Invoke-Command -ScriptBlock {param(`$AutorunsName); Get-Process $AutorunsName } -ArguementList `$AutorunsName -Session $Session"
                $PoShEasyWin.Refresh()
            }
            else {
                if (-not (Test-Path "$script:IndividualHostResults\Autoruns\$AutorunsName-$($Session.ComputerName).arn")) {
                    try {
                        # Attempts to send a copy of Autoruns to the endpoints
                        $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      [!] Copying Autoruns data from $($Session.ComputerName) for analysis")
                        Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path '$TargetFolder\Autoruns.arn' -Destination '$script:IndividualHostResults\Autoruns' -FromSession $Session -Force -ErrorAction Stop"
                        $PoShEasyWin.Refresh()
                        Copy-Item -Path "$TargetFolder\$AutorunsName.arn" -Destination "$script:IndividualHostResults\Autoruns" -FromSession $Session -Force -ErrorAction Stop
                        Rename-Item "$script:IndividualHostResults\Autoruns\$AutorunsName.arn" "$script:IndividualHostResults\Autoruns\Autoruns-$($Session.ComputerName).arn" -Force
                        $FileSize = [math]::round(((Get-Item "$script:IndividualHostResults\Autoruns\Autoruns-$($Session.ComputerName).arn").Length/1mb),2)
                        $ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          Autoruns-$($Session.ComputerName).arn is $FileSize MB")
                        $PoShEasyWin.Refresh()
                    }
                    catch {
                        # If an error occurs, it will display it
                        $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Copy Error: $($_.Exception)")
                        Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Copy Error: $($_.Exception)"
                        $PoShEasyWin.Refresh()
                        break
                    }

                    try {
                        $ResultsListBox.Items.Insert(5,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          Cleaning up Autoruns and data file from $($Session.ComputerName)")
                        Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Remove-Item '$TargetFolder\$AutorunsName.arn' -Force"
                        Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Remove-Item '$TargetFolder\$AutorunsName.exe' -Force"
                        $PoShEasyWin.Refresh()
                        Start-Sleep -Seconds 3
                        Invoke-Command -ScriptBlock {
                            param($RemoteDrive,$TargetFolder,$AutorunsName)
                            Remove-Item -Path "$TargetFolder\$AutorunsName.arn" -Force
                            Remove-Item -Path "$TargetFolder\$AutorunsName.exe" -Force
                        } -ArgumentList @($RemoteDrive,$TargetFolder,$AutorunsName) -Session $Session
                    }
                    catch {
                        # If an error occurs, it will display it
                        $ResultsListBox.Items.Insert(5,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Remove Error: $($_.Exception)")
                        Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Remove Error: $($_.Exception)"
                        $PoShEasyWin.Refresh()
                        break
                    }
                    $AutoRunsCompletedEndpoints += $Session.ComputerName
                    $script:ProgressBarEndpointsProgressBar.Value += 1
                    $PoShEasyWin.Refresh()

                }
            }
        }
    }
    # Breaks the loop once all endpoints have finished
    if ($AutoRunsCompletedEndpoints.count -eq $PSSession.count) {
        break
    }
    # Not supported
    elseif ((Get-Date) -gt ( ($ExecutionStartTime).addseconds([int]$script:OptionJobTimeoutSelectionComboBox.text))) {
        $ResultsListBox.Items.Insert(3,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))      [!] Timeout: $CollectionName ($([int]$script:OptionJobTimeoutSelectionComboBox.Text) Seconds)")
        $PoShEasyWin.Refresh()
        break
    }
}
$ResultsListBox.Items.RemoveAt(1)
$ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$SysinternalsAutorunsButton.BackColor = 'LightGreen'

$script:ProgressBarQueriesProgressBar.Value += 1
$PoShEasyWin.Refresh()
Start-Sleep -match 500

