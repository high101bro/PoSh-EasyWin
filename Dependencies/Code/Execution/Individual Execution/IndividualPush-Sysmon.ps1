# Executes RPC/DCOM based commands if the RPC Radio Button is Checked
if ($ExternalProgramsRPCRadioButton.checked) {
    $CollectionName = "Sysmon"
    $ExecutionStartTime = Get-Date
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Insert(0,"Query: $CollectionName")
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
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
        $ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName - $TargetComputer")
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
            try { Copy-Item $SysmonExecutablePath -Force -ErrorAction Stop }
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $Script:SysmonXMLName config file to $TargetComputer to be used by $SysmonName")
            $PoShEasyWin.Refresh()
            try { Copy-Item $script:SysmonXMLPath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop }
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Updating $SysmonName configuration on $TargetComputer")
            $PoShEasyWin.Refresh()
            #Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "-AcceptEULA -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysmonExecutable -AcceptEULA -c '$LocalDrive\$TargetFolder\$Script:SysmonXMLName' -d $SysmonDriverName" -PassThru | Out-Null
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
            #Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "-AcceptEULA -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysmonExecutable -AcceptEULA -i '$LocalDrive\$TargetFolder\$Script:SysmonXMLName' -d $SysmonDriverName" -PassThru | Out-Null
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
        $CollectionCommandDiffTime1 = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime1
        $ResultsListBox.Items.RemoveAt(1)
        $ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime1]  $CollectionName - $TargetComputer")
        $PoShEasyWin.Refresh()
    }

    if ($SysinternalsSysmonRenameServiceProcessTextBox.text -ne 'Sysmon') {
        # Removes the local renamed copy of Sysmon
        Remove-Item "$ExternalPrograms\$($SysinternalsSysmonRenameServiceProcessTextBox.text).exe" -Force
    }
    $CollectionCommandEndTime0  = Get-Date
    $CollectionCommandDiffTime0 = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime0
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime0]  $CollectionName")
    $PoShEasyWin.Refresh()
}

# Executes WinRM based commands over PSSessions if the WinRM Radio Button is Checked
elseif ($ExternalProgramsWinRMRadioButton.checked) {


    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Executing: Sysmon Deployment / Update")

    $script:ProgressBarEndpointsProgressBar.Value = 0

    $CollectionName = "Sysinternals Sysmon"


    New-Item -Type Directory -Path $script:CollectionSavedDirectoryTextBox.Text -ErrorAction SilentlyContinue


    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $($script:CollectionSavedDirectoryTextBox.Text) `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

        $LocalSavePath = "$($script:CollectionSavedDirectoryTextBox.Text)\$CollectionName\$TargetComputer - $CollectionName.evtx"


        Start-Job -Name "PoSh-EasyWin: $CollectionName -- $TargetComputer $DateTime" -ScriptBlock {
            param(
                $ComputerListProvideCredentialsCheckBox,
                $script:Credential,
                $TargetComputer,
                $ExternalPrograms,
                $SysinternalsSysmonRenameServiceProcessTextBox,
                $SysinternalsSysmonRenameDriverTextBox,
                $ExternalProgramsTimoutOutTextBox,
                $script:SysmonXMLPath,
                $script:SysmonXMLName
            )


            if ($ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { $script:Credential = Get-Credential }
                $Session = New-PSSession -ComputerName $TargetComputer -Credential $script:Credential
            }
            else {
                $Session = New-PSSession -ComputerName $TargetComputer
            } 
            
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


            Copy-Item -Path $SysmonExecutablePath -Destination "$TargetFolder" -ToSession $Session -Force -ErrorAction Stop
            Copy-Item -Path $script:SysmonXMLPath -Destination "$TargetFolder" -ToSession $Session -Force -ErrorAction Stop


            if ($SysinternalsSysmonRenameServiceProcessTextBox.text -ne 'Sysmon') {
                # Removes the local renamed copy of Sysmon
                Remove-Item "$ExternalPrograms\$($SysinternalsSysmonRenameServiceProcessTextBox.text).exe" -Force
            }
            

            if ($SysinternalsSysmonRenameDriverTextBox.text -ne 'SysmonDrv' -and ($SysinternalsSysmonRenameDriverTextBox.text).length -ne 0 ) {
                # Checks if the Sysmon service exists, if not it will install sysmon and log it locally
                Invoke-Command -ScriptBlock {
                    param($SysmonName,$SysmonDriverName,$TargetFolder,$SysmonExecutable,$Script:SysmonXMLName)
                    # Installs Tool if service not detected
                    if (-not (Get-Service -Name "$SysmonName")){
                        Start-Process -NoNewWindow -FilePath "$TargetFolder\$SysmonExecutable" -Argumentlist @("-AcceptEULA", "-i", "$TargetFolder\$Script:SysmonXMLName")
                    }
                    # If the Tool service exists, it updates the configuration file
                    else {
                        Start-Process -NoNewWindow -FilePath "$TargetFolder\$SysmonExecutable" -Argumentlist @("-AcceptEULA", "-c", "$TargetFolder\$Script:SysmonXMLName")
                    }
                } -Argumentlist @($SysmonName,$SysmonDriverName,$TargetFolder,$SysmonExecutable,$Script:SysmonXMLName) -Session $Session
            }
            else {
                Invoke-Command -ScriptBlock {
                    param($SysmonName,$SysmonDriverName,$TargetFolder,$SysmonExecutable,$Script:SysmonXMLName)
                    # Installs Tool if service not detected
                    if (-not (Get-Service -Name "$SysmonName")){
                        Start-Process -NoNewWindow -FilePath "$TargetFolder\$SysmonExecutable" -Argumentlist @("-AcceptEULA", "-i", "$TargetFolder\$Script:SysmonXMLName")
                    }
                    # If the Tool service exists, it updates the configuration file
                    else {
                        Start-Process -NoNewWindow -FilePath "$TargetFolder\$SysmonExecutable" -Argumentlist @("-AcceptEULA", "-c", "$TargetFolder\$Script:SysmonXMLName")
                    }
                } -Argumentlist @($SysmonName,$SysmonDriverName,$TargetFolder,$SysmonExecutable,$Script:SysmonXMLName) -Session $Session
            }

            
            $TimeOutTimer = 0            
            while ($true) {
                Start-Sleep -Seconds 1
                $TimeOutTimer++

                if (( Invoke-Command -ScriptBlock { Get-Service "$SysmonName" } -Session $Session )) {
                    Start-Sleep -Seconds 1
                    Invoke-Command -ScriptBlock {
                        param(
                            $TargetFolder,
                            $SysmonExecutable,
                            $Script:SysmonXMLName
                        )
                        Remove-Item "$TargetFolder\$SysmonExecutable"     -Recurse -Force
                        Remove-Item "$TargetFolder\$Script:SysmonXMLName" -Recurse -Force
                    } -Argumentlist @($TargetFolder,$SysmonExecutable,$Script:SysmonXMLName) -Session $Session
                    break
                }
            }


            $Session | Remove-PSSession

        } -ArgumentList @(
            $ComputerListProvideCredentialsCheckBox,
            $script:Credential,
            $TargetComputer,
            $ExternalPrograms,
            $SysinternalsSysmonRenameServiceProcessTextBox,
            $SysinternalsSysmonRenameDriverTextBox,
            $ExternalProgramsTimoutOutTextBox,
            $script:SysmonXMLPath,
            $script:SysmonXMLName
        )

        $EndpointString = ''
        foreach ($item in $script:ComputerList) {$EndpointString += "$item`n"}

        $InputValues = @"
===========================================================================
Collection Name:
===========================================================================
Sysmon Deployment / Update

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
Sysmon Service/Process Name:
===========================================================================
$($SysinternalsSysmonRenameServiceProcessTextBox.text)

===========================================================================
Sysmon Driver Name:
===========================================================================
$($SysinternalsSysmonRenameDriverTextBox.Text)

===========================================================================
Timeout:
===========================================================================
$($script:OptionJobTimeoutSelectionComboBox.Text)

"@


    }
    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Monitor Jobs') {
        Monitor-Jobs -CollectionName $CollectionName -MonitorMode -SysmonSwitch -SysmonName $SysinternalsSysmonRenameServiceProcessTextBox.text -ComputerName $script:ComputerList -DisableReRun -InputValues $InputValues -NotExportFiles
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUrUr7bh8qOf91HR3/CwP41ybW
# a1ygggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUvsjmjW/ZVDZYe6IP6HPdOnzxlykwDQYJKoZI
# hvcNAQEBBQAEggEAWBPtxATQ2wgS8QWxygfazOc5qu7Wk7GMPxo5EaK70hM5kok0
# 6qGwRjoWyHyIuWXbdN2eaIP/r2Bl9SW84kQo7nuG3sRwzaahHfnxKRZX2wl+/VXy
# G4AFyo6ZerRZRV+40+QXoGWGxs84uW4VOinFyj2KxFZD1PzvhBaHJtD3yen+AjLH
# jYuxj/0WpZYxkZoQyAoNc5RXBRxJg1OvhSNoftZ2Efr97Zel1pqxxH/mOUWYNK9m
# 2usLqJFJzjjluM+FPljnxxNTenHjaw9vZbzxT7KEtzst9qYcPJw7NtbuPZ1Srsbk
# JgYTH+PanZPJ1PZLLLqQXoAKh3AduGiBTOQjug==
# SIG # End signature block
