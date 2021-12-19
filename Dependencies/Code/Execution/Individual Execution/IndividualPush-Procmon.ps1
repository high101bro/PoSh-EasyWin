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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU9A5fvdV4C0lEYaBSBzrrLbUm
# Re2gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUNxOxz3AbQoL/gxVNFSfqP7I+qqYwDQYJKoZI
# hvcNAQEBBQAEggEAcWg75rYU2jtu0vdt7bprcJp+9NgQzMuw/iQlf/Ns3PZJHJKN
# GS2ZfoLuLStwSFEqQcWESmJ/5EYZh6uCazppWug093OeEz6N14ZAvmUXSUv7Em/F
# ya1uqPwf7yY7ITugEFaQ82/ob6DUULijxn1f3p+o0+M9yI19FOfqmTJyOoRLAgc0
# jeSNTbf130gOd142b5fKRw/yW39rcMlWOASEvvrzLgcVOWQTlLEIedCg0dIvLUmZ
# 8nghuuYXnYr5EfdUMhpaEz8p623Whd1e5XmQ5JJ8Uc+yB6ASsK77jxZgCjdUcnqW
# pXGJjB/dQ20xfg6qACN5KcuOmA7C6i91zlqKhw==
# SIG # End signature block
