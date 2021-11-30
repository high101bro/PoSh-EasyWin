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

    $script:CollectionName = "Sysinternals Sysmon"


    New-Item -Type Directory -Path $script:CollectionSavedDirectoryTextBox.Text -ErrorAction SilentlyContinue


    foreach ($TargetComputer in $script:ComputerList) {
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $($script:CollectionSavedDirectoryTextBox.Text) `
                                -IndividualHostResults "$script:IndividualHostResults" -CollectionName $script:CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $script:CollectionName

        $LocalSavePath = "$($script:CollectionSavedDirectoryTextBox.Text)\$script:CollectionName\$TargetComputer - $script:CollectionName.evtx"


        Start-Job -Name "PoSh-EasyWin: $script:CollectionName -- $TargetComputer $DateTime" -ScriptBlock {
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
        Monitor-Jobs -CollectionName $script:CollectionName -MonitorMode -SysmonSwitch -SysmonName $SysinternalsSysmonRenameServiceProcessTextBox.text -ComputerName $script:ComputerList -DisableReRun -InputValues $InputValues -NotExportFiles
    }
    elseif ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Individual Execution') {
        Monitor-Jobs -CollectionName $script:CollectionName -NotExportFiles
        Post-MonitorJobs -CollectionName $script:CollectionName -CollectionCommandStartTime $ExecutionStartTime
    }
}





# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUf1uW1h0SHbip+5gRXiG7TVFU
# /AKgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUJ5pdr2aFpll+ziIqiv4jqupUxFEwDQYJKoZI
# hvcNAQEBBQAEggEAwOh1pfT3OxPct4+K6/xF5yhxKhFcL2dGu3vHpmDLvk6f98x1
# 9YJo9HnopUpNUtfrY9tlqv3TRuMb6x6McvnOQOgko70YLjs2n3BaIEYvKG9E1QuF
# Cw8LaX64iFa4DOmAxXKdfxR19Drv8WZV+kcC1o7U+ufKoKLjmZ/Aa7R+HBbCZTbM
# 1XPM69IQHEOsaZYndxrWVO2hXfrQ8JM5wXQJbtTSDS116a8qGbkOn8nQb5IN80bz
# mFELmOc5bo09PMPShmJeorWCLk/2Ns0s190COvplZNwlbDxRq/tGtmaJ7AA0qxv+
# m6eKXV8hK1CNw4krKAeHAK1QGaaXViZqs/QvrA==
# SIG # End signature block
