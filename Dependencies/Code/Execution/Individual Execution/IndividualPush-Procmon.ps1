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
        ### $Command = Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "-AcceptEULA $script:Credential -s \\$TargetComputer $RemoteDrive\$TargetFolder\$ProcmonExecutable -AcceptEULA /BackingFile $RemoteDrive\$TargetFolder\$TargetComputer /RunTime 10 /Quiet" -PassThru | Out-Null
        ### $Command = Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "-AcceptEULA -s \\$TargetComputer $RemoteDrive\$TargetFolder\$ProcmonExecutable -AcceptEULA /BackingFile `"$RemoteDrive\$TargetFolder\$ProcmonName-$TargetComputer`" /RunTime $ProcMonDuration /Quiet" -PassThru | Out-Null
        ### $Command
        Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList "$RemoteDrive\$TargetFolder\$ProcmonExecutable -AcceptEULA /BackingFile $RemoteDrive\$TargetFolder\$ProcmonName /RunTime $ProcMonDuration /Quiet"

        Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "$($SysinternalsProcessMonitorCheckbox.Name)"
        #Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "$Command"
        Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList `"$RemoteDrive\$TargetFolder\$ProcmonExecutable -AcceptEULA /BackingFile $RemoteDrive\$TargetFolder\$ProcmonName /RunTime $ProcMonDuration /Quiet`""

        $FirstCheck      = $true
        $SecondsToCheck  = $ExternalProgramsTimoutOutTextBox.Text

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

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Executing: Procmon")

    $script:ProgressBarEndpointsProgressBar.Value = 0

    $CollectionName = "Sysinternals Procmon"

    $LocalSavePath = "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName"

    New-Item -Type Directory -Path $LocalSavePath -ErrorAction SilentlyContinue


    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $($script:CollectionSavedDirectoryTextBox.Text) `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

        $ProcmonName                   = 'Procmon'
        $ProcmonExecutable             = "$ProcmonName.exe"
        $LocalPathForProcmonExecutable = "$ExternalPrograms\$ProcmonExecutable"
        $RemoteTargetDirectory         = "c:\Windows\Temp"
        
        
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

        Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer $DateTime" -ScriptBlock {
            param(
                $ComputerListProvideCredentialsCheckBox,
                $script:Credential,
                $TargetComputer,
                $CollectionName,
                $LocalSavePath,
                $ExternalPrograms,
                $RemoteTargetDirectory,
                $ProcmonDuration,
                $ProcmonExecutable,
                $ProcmonName,
                $LocalPathForProcmonExecutable,
                $SysinternalsProcmonRenameProcessTextBox
            )


            if ($ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { $script:Credential = Get-Credential }
                $Session = New-PSSession -ComputerName $TargetComputer -Credential $script:Credential
            }
            else {
                $Session = New-PSSession -ComputerName $TargetComputer
            } 
                        
            
            # Renames Procmon Process name in order to obfuscate deployent
            if ($SysinternalsProcmonRenameProcessTextBox.text -ne 'Procmon') {
                Copy-Item -Path "$LocalPathForProcmonExecutable" -Destination "$ExternalPrograms\$($SysinternalsProcmonRenameProcessTextBox.text).exe" -Force
                $ProcmonName                   = "$($SysinternalsProcmonRenameProcessTextBox.text)"
                $ProcmonExecutable             = "$($SysinternalsProcmonRenameProcessTextBox.text).exe"
                $LocalPathForProcmonExecutable = "$ExternalPrograms\$ProcmonExecutable"
            }
            
            
            Function Get-SessionDiskSpace {
                $HD = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='C:'" -ErrorAction Stop
                if(!$HD) { throw }
                $FreeSpace = [math]::round(($HD.FreeSpace/1gb),2)
                return $FreeSpace
            }
                       
            
            if( (Invoke-Command -ScriptBlock ${function:Get-SessionDiskSpace} -Session $Session) -lt 0.5 -or (Get-SessionDiskSpace) -lt 0.5) {
                $Session | Remove-PSSession
            }
            else {
                # Attempts to send a copy of Procmon to the endpoints
                Copy-Item -Path "$LocalPathForProcmonExecutable" -Destination "$RemoteTargetDirectory" -ToSession $Session -Force -ErrorAction Stop

                if ($SysinternalsProcmonRenameProcessTextBox.text -ne 'Procmon') {
                    # Removes the local renamed copy of Procmon
                    Remove-Item "$ExternalPrograms\$($SysinternalsProcmonRenameProcessTextBox.text).exe" -Force
                }
        
                Invoke-Command -ScriptBlock {
                    param(
                        $RemoteTargetDirectory,
                        $ProcmonExecutable,
                        $ProcmonDuration,
                        $ProcmonName
                    )
                    Start-Process -Filepath "$RemoteTargetDirectory\$ProcmonExecutable" -ArgumentList @("-AcceptEULA", "/BackingFile", "$RemoteTargetDirectory\$ProcmonName", "/RunTime", "$ProcmonDuration", "/Quiet")

                } -ArgumentList @($RemoteTargetDirectory,$ProcmonExecutable,$ProcmonDuration,$ProcmonName) -Session $Session


                $TimeOutTimer = 0            
                while ($true) {
                    while ($TimeOutTimer -lt $ProcmonDuration) {
                        $TimeOutTimer++
                        Start-Sleep -Seconds 1
                    }
                    Start-Sleep -Seconds 1
                    $TimeOutTimer++
    
                    
                    if ( (Invoke-Command -ScriptBlock { param($RemoteTargetDirectory,$ProcmonName);  (-not $(Get-Process $ProcmonName -ea SilentlyContinue) -and $(Get-Item "$RemoteTargetDirectory\$ProcmonName.pml"  -ea SilentlyContinue) ) } -ArgumentList @($RemoteTargetDirectory,$ProcmonName)  -Session $Session) ) {
                        Start-Sleep -Seconds 1

                        Copy-Item -Path "$RemoteTargetDirectory\$ProcmonName.pml" -Destination "$LocalSavePath\Procmon-$($TargetComputer).pml" -FromSession $Session -Force

                        Invoke-Command -ScriptBlock {
                            param(
                                $RemoteTargetDirectory,
                                $ProcmonName
                            )
                            Remove-Item -Path $RemoteTargetDirectory\$ProcmonName.pml -Force
                            Remove-Item -Path $RemoteTargetDirectory\$ProcmonName.exe -Force
                        } -ArgumentList @($RemoteTargetDirectory,$ProcmonName) -Session $Session

                        break
                    }
                }
            }                        

            $Session | Remove-PSSession

        } -ArgumentList @(
            $ComputerListProvideCredentialsCheckBox,
            $script:Credential,
            $TargetComputer,
            $CollectionName,
            $LocalSavePath,
            $ExternalPrograms,
            $RemoteTargetDirectory,
            $ProcmonDuration,
            $ProcmonExecutable,
            $ProcmonName,
            $LocalPathForProcmonExecutable,
            $SysinternalsProcmonRenameProcessTextBox
        )


        $EndpointString = ''
        foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}

        $InputValues = @"
===========================================================================
Collection Name:
===========================================================================
$CollectionName

===========================================================================
Execution Time:
===========================================================================
$ExecutionStartTime

===========================================================================
Credentials:
===========================================================================
$($script:Credential.UserName)

===========================================================================
Endpoint:
===========================================================================
$EndpointString

===========================================================================
Promon Process Name:
===========================================================================
$($SysinternalsProcmonRenameProcessTextBox.text)

===========================================================================
Collection Duration:
===========================================================================
$script:SysinternalsProcessMonitorTimeComboBox

===========================================================================
Timeout:
===========================================================================
$($script:OptionJobTimeoutSelectionComboBox.Text)

"@


    }
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -ProcmonSwitch -ProcmonLocalPath $LocalSavePath -ComputerName $script:ComputerList -DisableReRun -InputValues $InputValues -NotExportFiles
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
        Monitor-Jobs -CollectionName $CollectionName -NotExportFiles
        Post-MonitorJobs -CollectionName $CollectionName -CollectionCommandStartTime $ExecutionStartTime
    }
}

Update-EndpointNotes




# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqzOQxjhpPliF16IlU/kOfej2
# a+CgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUXI8xC1x0hod/ZfpTXVXBWMvMoqIwDQYJKoZI
# hvcNAQEBBQAEggEAslLmoYXWNxLKnd76RSNYB5WuO4tCssc9fnxzut+M/Tzvngz4
# b/9woPWGHMf0BE2bIS05Yx6LGdqgTY7A7SACVdtN+EMYah0zp2oEL/VnXnuv5TAy
# czv+1Njd2rS74cRJkw+LksuWKH1Nd/io7T+Bb5en2owLMYWYG3fcQtXQBHctR/76
# iHIRFbaKWaO3SP+Rxgh9uHG00MLCnwtuB5qh6lPYXHLPo8xL8azjWifot9EclKoc
# LDEUTG2edbWYjxFtoTxX6eA9vF28cPldyYECfX8kYv5g/vhZ52KyS4O/jGEUBL6W
# 1xhL1ALi5cgZTsvIczacxiNeQGDWkVHmlWojbw==
# SIG # End signature block
