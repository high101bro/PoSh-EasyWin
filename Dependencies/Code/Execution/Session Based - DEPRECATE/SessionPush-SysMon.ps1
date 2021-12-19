$ExecutionStartTime = Get-Date
$CollectionName = "Sysinternals Sysmon Configuration"
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Executing: $CollectionName")
$ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  $CollectionName")
$PoShEasyWin.Refresh()

# This directory is created by the parent script and is used by most other commands, but it's not needed here
# Whoopes... don't delete this, because if you push sysmon with other queries you'll delete all the results...
# Remove-Item -Path $script:CollectionSavedDirectoryTextBox.Text -Recurse -Force -ErrorAction SilentlyContinue

$script:ProgressBarEndpointsProgressBar.Value = 0

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
                    Start-Process -NoNewWindow -FilePath "$TargetFolder\$SysmonExecutable" -Argumentlist "/AcceptEULA -i $TargetFolder\$Script:SysmonXMLName -d $SysmonDriverName"
                }
                # If the Tool service exists, it updates the configuration file
                else {
                    Start-Process -NoNewWindow -FilePath "$TargetFolder\$SysmonExecutable" -Argumentlist "/AcceptEULA -c $TargetFolder\$Script:SysmonXMLName -d $SysmonDriverName "
                }
            } -Argumentlist @($SysmonName,$SysmonDriverName,$TargetFolder,$SysmonExecutable,$Script:SysmonXMLName) -Session $Session

            if (-not $(Invoke-Command -ScriptBlock { param($SysmonName); Get-Service -Name "$SysmonName" } -ArgumentList $SysmonName -Session $Session)) {
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Start-Process -NoNewWindow -FilePath `"$TargetFolder\$SysmonExecutable`" -ArgumentList `"/AcceptEULA -i $TargetFolder\$Script:SysmonXMLName -d $SysmonDriverName`""
            }
            else {
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Start-Process -NoNewWindow -FilePath `"$TargetFolder\$SysmonExecutable`" -ArgumentList `"/AcceptEULA -c $TargetFolder\$Script:SysmonXMLName -d $SysmonDriverName`""
            }
        }
        else {
            Invoke-Command -ScriptBlock {
                param($SysmonName,$SysmonDriverName,$TargetFolder,$SysmonExecutable,$Script:SysmonXMLName)
                # Installs Tool if service not detected
                if (-not (Get-Service -Name "$SysmonName")){
                    Start-Process -NoNewWindow -FilePath "$TargetFolder\$SysmonExecutable" -Argumentlist "/AcceptEULA -i $TargetFolder\$Script:SysmonXMLName"
                }
                # If the Tool service exists, it updates the configuration file
                else {
                    Start-Process -NoNewWindow -FilePath "$TargetFolder\$SysmonExecutable" -Argumentlist "/AcceptEULA -c $TargetFolder\$Script:SysmonXMLName"
                }
            } -Argumentlist @($SysmonName,$SysmonDriverName,$TargetFolder,$SysmonExecutable,$Script:SysmonXMLName) -Session $Session

            if (-not $(Invoke-Command -ScriptBlock { param($SysmonName); Get-Service -Name "$SysmonName" } -ArgumentList $SysmonName -Session $Session)) {
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Start-Process -NoNewWindow -FilePath `"$TargetFolder\$SysmonExecutable`" -ArgumentList `"/AcceptEULA -i $TargetFolder\$Script:SysmonXMLName`""
            }
            else {
                Create-LogEntry -LogFile $LogFile -TargetComputer "    $($Session.ComputerName)" -Message "Start-Process -NoNewWindow -FilePath `"$TargetFolder\$SysmonExecutable`" -ArgumentList `"/AcceptEULA -c $TargetFolder\$Script:SysmonXMLName`""
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


$script:ProgressBarEndpointsProgressBar.Value = 0
$SysmonCompletedEndpoints = @()
$FirstCheck = $true
$SecondsToCheck = $ExternalProgramsTimoutOutTextBox.Text

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
                $ResultsListBox.Items.Insert(3,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))      Checking for $SysmonName service - NOT Yet Running on $($Session.ComputerName)")
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
    elseif ((Get-Date) -gt ( ($ExecutionStartTime).addseconds([int]$script:OptionJobTimeoutSelectionComboBox.text))) {
        $ResultsListBox.Items.Insert(3,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))      [!] Timeout: $CollectionName ($([int]$script:OptionJobTimeoutSelectionComboBox.Text) Seconds)")
        $PoShEasyWin.Refresh()
        break
    }
}

$ResultsListBox.Items.RemoveAt(1)
$ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss'))  [$(New-TimeSpan -Start $ExecutionStartTime -End (Get-Date))]  $CollectionName")
$PoShEasyWin.Refresh()

$script:ProgressBarQueriesProgressBar.Value += 1
$PoShEasyWin.Refresh()
Start-Sleep -match 500



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOimTEwWVAGY+bnJsqJREIAeE
# lhWgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUGPPXoYg/kcCt0xPvs89M58DShDswDQYJKoZI
# hvcNAQEBBQAEggEAZ1HJQ3zaw2tk+vwDD17wXBBpbKi7oQxmcPlLQapSlQ1wRhox
# 7hPoT/d6BsvNtiFPafr8MQo4CC/DDZVZbDWxEW/mSLDIuQauLE5Zf/aJLUSVRoEb
# CtwKfM92cNbzKE0/fzA3RqHnXVCxNncuvI40O30M7t4nCLhFSQIvfFOFFC7seuLZ
# 7A48ok+I50jfv5rpghJSB36Z56J3KzDMNx6AOtza11YWqbhMULsBoxKDLrp2NbVe
# BmtextvKYE+isYuSz4N28bzm39tuX94CKUN5Y2uugjCE8fE/l3pOwPVvL3YkdPps
# EpQk62QtU5PDi7W4xDYuHIyx59DybhKrx0Qegw==
# SIG # End signature block
