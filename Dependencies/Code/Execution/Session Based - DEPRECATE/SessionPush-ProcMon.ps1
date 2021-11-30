$ExecutionStartTime = Get-Date
$CollectionName = "Sysinternals Procmon Collection"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[+] Executing Procmon"

$ProcmonName                   = 'Procmon'
$ProcmonExecutable             = "$ProcmonName.exe"
$LocalPathForProcmonExecutable = "$ExternalPrograms\$ProcmonExecutable"
$RemoteTargetDirectory         = "c:\Windows\Temp"

New-Item "$script:IndividualHostResults\Procmon" -Type Directory


$ProcmonDuration = switch ($script:SysinternalsProcessMonitorTimeComboBox.text) {
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


# Renames Procmon Process name in order to obfuscate deployent
if ($SysinternalsProcmonRenameProcessTextBox.text -ne 'Procmon') {
    Copy-Item -Path "$LocalPathForProcmonExecutable" -Destination "$ExternalPrograms\$($SysinternalsProcmonRenameProcessTextBox.text).exe" -Force
    $ProcmonName                   = "$($SysinternalsProcmonRenameProcessTextBox.text)"
    $ProcmonExecutable             = "$($SysinternalsProcmonRenameProcessTextBox.text).exe"
    $LocalPathForProcmonExecutable = "$ExternalPrograms\$ProcmonExecutable"
}


Function Get-SessionDiskSpace {
    try { $HD = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop }
    catch {
        $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Unable to connect to get diskspace.")
        $PoShEasyWin.Refresh()
        continue
    }
    if(!$HD) { throw }
    $FreeSpace = [math]::round(($HD.FreeSpace/1gb),2)
    return $FreeSpace
}

# Process monitor generates enormous amounts of data.
# To try and offer some protections, the script won't run if the source or target have less than 500MB free
$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Verifying free diskspace on localhost and endpoints (500 MB)")
Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Verifying free diskspace on localhost and endpoints"
$PoShEasyWin.Refresh()
$script:ProgressBarEndpointsProgressBar.Value = 0


$ConnectedPSSessions    = @()
$DisconnectedPSSessions = @()
foreach ($Session in $PSSession) {
    if((Invoke-Command -ScriptBlock ${function:Get-SessionDiskSpace} -Session $Session) -lt 0.5) {
        $Session | Disconnect-PSSession
        $DisconnectedPSSessions += $Session
        $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName) - Session disconnected to avoid filling disk")
        Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Session disconnected to avoid filling disk"
        $PoShEasyWin.Refresh()
    }
    else { $ConnectedPSSessions += $Session }
    $script:ProgressBarEndpointsProgressBar.Value += 1
    $PoShEasyWin.Refresh()
}

if ((Get-SessionDiskSpace) -lt 0.5) {
    Get-PSSession | Remove-PSSession
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Aborted Procmon Execution")
    $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      Localhost has less than 500 MB free - Aborting to avoid filling disk")
    Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Env:ComputerName)" -Message "Localhost has less than 500 MB free - Aborting to avoid filling disk"
    $PoShEasyWin.Refresh()
    [system.media.systemsounds]::Exclamation.play()
    Start-Sleep -Seconds 1
}
else {
    if (($PSSession).count -gt 0) {
        $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copying over $ProcmonExecutable to:")
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Copying over $ProcmonExecutable to:"
        $PoShEasyWin.Refresh()
        $script:ProgressBarEndpointsProgressBar.Value = 0
        foreach ($Session in $PSSession) {
            try {
                # Attempts to send a copy of Procmon to the endpoints
                Copy-Item -Path $LocalPathForProcmonExecutable -Destination "$RemoteTargetDirectory" -ToSession $Session -Force -ErrorAction Stop
                $ResultsListBox.Items.insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path $LocalPathForProcmonExecutable -Destination '$RemoteTargetDirectory' -ToSession $Session -Force -ErrorAction Stop"
                $PoShEasyWin.Refresh()
            }
            catch {
                # If an error occurs, it will display it
                $ResultsListBox.Items.insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))         Copy Error: $($_.Exception)")
                Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Copy Error: $($_.Exception)"
                $PoShEasyWin.Refresh()
                break
            }
            $script:ProgressBarEndpointsProgressBar.Value += 1
            $PoShEasyWin.Refresh()
        }
        if ($SysinternalsProcmonRenameProcessTextBox.text -ne 'Procmon') {
            # Removes the local renamed copy of Procmon
            Remove-Item "$ExternalPrograms\$($SysinternalsProcmonRenameProcessTextBox.text).exe" -Force
        }

        $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Executing Procmon on:")
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Executing Procmon on:"
        $PoShEasyWin.Refresh()
        $script:ProgressBarEndpointsProgressBar.Value = 0
        foreach ($Session in $PSSession) {
            try {
                Invoke-Command -ScriptBlock {
                    param(
                        $RemoteTargetDirectory,
                        $ProcmonExecutable,
                        $ProcmonDuration,
                        $ProcmonName
                    )
                    Start-Process -Filepath "$RemoteTargetDirectory\$ProcmonExecutable" -ArgumentList @("/AcceptEULA /BackingFile $RemoteTargetDirectory\$ProcmonName /RunTime $ProcmonDuration /Quiet")
                    #Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList @("$RemoteTargetDirectory\$ProcmonExecutable /AcceptEULA /BackingFile $RemoteTargetDirectory\Procmon /RunTime $ProcmonDuration /Quiet")
                } -ArgumentList @($RemoteTargetDirectory,$ProcmonExecutable,$ProcmonDuration,$ProcmonName) -Session $Session

                $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
                #Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Invoke-WmiMethod -Class Win32_Process -Name Create -ArgumentList @(`"$RemoteTargetDirectory\$ProcmonExecutable /AcceptEULA -a $RemoteTargetDirectory\Procmon.pml`")"
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message  "Start-Process -Filepath '$RemoteTargetDirectory\$ProcmonExecutable' -ArgumentList @('/AcceptEULA /BackingFile $RemoteTargetDirectory\$ProcmonName /RunTime $ProcmonDuration /Quiet')"
                $script:ProgressBarEndpointsProgressBar.Value += 1
                $PoShEasyWin.Refresh()
            }
            catch {
                # If an error occurs, it will display it
                $ResultsListBox.Items.insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))         Execution Error: $($_.Exception)")
                Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Executions Error: $($_.Exception)"
                $PoShEasyWin.Refresh()
                break
            }
        }

        $script:ProgressBarEndpointsProgressBar.Value = 0
        $ProcmonCompletedEndpoints = @()
        $FirstCheck = $true
        $SecondsToCheck = $ExternalProgramsTimoutOutTextBox.Text

        while ($true) {
            if ($FirstCheck -eq $true) {
                foreach ( $sec in (($ProcmonDuration + $SecondsToCheck)..1)) {
                    if ($FirstCheck -eq $false) {$ResultsListBox.Items.RemoveAt(2)}
                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Gathering Process Monitoring Data, Checking in $sec")
                    $PoShEasyWin.Refresh()
                    Start-Sleep -Seconds 1
                    $FirstCheck = $false
                }
            }
            else {
                foreach ( $sec in (($SecondsToCheck)..1)) {
                    $ResultsListBox.Items.RemoveAt(2)
                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Gathering Process Monitoring Data, Checking in $Sec")
                    $PoShEasyWin.Refresh()
                    Start-Sleep -Seconds 1
                }
            }
            $ResultsListBox.Items.RemoveAt(2)
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Gathering Process Monitoring Data")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Checking Procmon every $SecondsToCheck Seconds"
            $PoShEasyWin.Refresh()


            foreach ($Session in $PSSession) {
                if ($Session.ComputerName -notin $ProcmonCompletedEndpoints) {
                    if ( $( Invoke-Command -ScriptBlock {param($ProcmonName) Get-Process $ProcmonName } -ArgumentList $ProcmonName -Session $Session )) {
                        $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      Still Running on $($Session.ComputerName)")
                        Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Invoke-Command -ScriptBlock {param($ProcmonName) Get-Process Procmon } -ArguementList $ProcmonName -Session $Session"
                        $PoShEasyWin.Refresh()
                    }
                    else {
                        if (-not (Test-Path "$script:IndividualHostResults\Procmon\Procmon-$($Session.ComputerName).pml")) {
                            try {
                                # Attempts to retrieve a copy of the results from the remote hosts
                                $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      [!] Copying Procmon data from $($Session.ComputerName) for analysis")
                                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Copy-Item -Path '$RemoteTargetDirectory\Procmon.pml' -Destination '$script:IndividualHostResults\Procmon' -FromSession $Session -Force -ErrorAction Stop"
                                $PoShEasyWin.Refresh()
                                Copy-Item -Path "$RemoteTargetDirectory\$ProcmonName.pml" -Destination "$script:IndividualHostResults\Procmon" -FromSession $Session -Force
                                Rename-Item "$script:IndividualHostResults\Procmon\$ProcmonName.pml" "$script:IndividualHostResults\Procmon\Procmon-$($Session.ComputerName).pml" -Force
                                $FileSize = [math]::round(((Get-Item "$script:IndividualHostResults\Procmon\Procmon-$($Session.ComputerName).pml").Length/1mb),2)
                                $ResultsListBox.Items.Insert(4,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          Procmon-$($Session.ComputerName).pml is $FileSize MB")
                                $PoShEasyWin.Refresh()
                            }
                            catch {
                                # If an error occurs, it will display it
                                $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Copy Error: $($_.Exception)")
                                Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Copy Error: $($_.Exception)"
                                $PoShEasyWin.Refresh()
                                break
                            }

                            try {
                                # Attempts to remove Procmon and the results
                                $ResultsListBox.Items.Insert(5,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))          Cleaning up Procmon and data file from $($Session.ComputerName)")
                                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Remove-Item '$RemoteTargetDirectory\$ProcmonName.pml' -Force"
                                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Remove-Item '$RemoteTargetDirectory\$ProcmonName.exe' -Force"
                                $PoShEasyWin.Refresh()
                                Start-Sleep -Seconds 3
                                Invoke-Command -ScriptBlock {
                                    param(
                                        $RemoteTargetDirectory,
                                        $ProcmonName
                                    )
                                    Remove-Item -Path "$RemoteTargetDirectory\$ProcmonName.pml" -Force
                                    Remove-Item -Path "$RemoteTargetDirectory\$ProcmonName.exe" -Force
                                } -ArgumentList @($RemoteTargetDirectory,$ProcmonName) -Session $Session
                            }
                            catch {
                                # If a error occurs, it will display it
                                $ResultsListBox.Items.Insert(5,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Remove Error: $($_.Exception)")
                                Create-LogEntry -LogFile $LogFile -TargetComputer "[!] Remove Error: $($_.Exception)"
                                $PoShEasyWin.Refresh()
                                break
                            }
                            $ProcmonCompletedEndpoints += $Session.ComputerName
                            $script:ProgressBarEndpointsProgressBar.Value += 1
                            $PoShEasyWin.Refresh()
                        }
                    }
                }
            }
            # Breaks the loop once all endpoints have finished
            if ($ProcmonCompletedEndpoints.count -eq $PSSession.count) {
                break
            }
            # Not supported
            elseif ((Get-Date) -gt ( ($ExecutionStartTime).addseconds(([int]$script:OptionJobTimeoutSelectionComboBox.text) + $ProcmonDuration))) {
                $ResultsListBox.Items.Insert(3,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))      [!] Timeout: $CollectionName ($([int]$script:OptionJobTimeoutSelectionComboBox.Text) Seconds)")
                $PoShEasyWin.Refresh()
                break
            }
        }
    }
}

# Reconnections to sessions that were disconnected becuase of limited space on endpoints
if ($DisconnectedPSSessions.Count -gt 0) {
    $ResultsListBox.Items.Insert(2,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [!] Reconnecting to Disconnected Sessions:")
    Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "[!] Reconnecting to Disconnected Sessions:"
    foreach ($Session in $DisconnectedPSSessions) {
        $Session | Connect-PSSession
        $ResultsListBox.Items.Insert(3,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))      $($Session.ComputerName)")
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "    $($Session.ComputerName)"
        $PoShEasyWin.Refresh()
    }
}

$SysinternalsProcmonButton.BackColor = 'LightGreen'

$ResultsListBox.Items.RemoveAt(1)
$ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value += 1
Start-Sleep -match 500



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUzamSrOLwYdrIMC4jj2Ue+vdG
# oiGgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQU3PB3P8PrrPYXB1/ZqW3/TJVEV88wDQYJKoZI
# hvcNAQEBBQAEggEAl7wQCy7o9JfYHLtazkxwfn0KB5V/FVpBO9+lkxCPbU9EGouc
# 8/RETdC13f3WpIGJgCAed9HIk8xu2OACjV0FSHsG5EJrW7O+j40D8wFWrHXFum7y
# nN/nIobWUvwuaYcmmcIxiAnx6GH9wcFznDNLryu/kmghu60xWQhxYgcGsUh5SBxH
# eJHrVH40vqdETn/mbj1RhNW0d6/4MlRmNp+O798yslTJf+EOLbn2aQqArmo8wR4k
# 1/PS5Qlk4W+BcJZOh1jJsGx3fs4yREeELi+coEN25xj9jnw7QCG84I3S58O/QSHg
# UNelHnz8laJlGOx1kpZoOU5NAJerQfwfGhDDyQ==
# SIG # End signature block