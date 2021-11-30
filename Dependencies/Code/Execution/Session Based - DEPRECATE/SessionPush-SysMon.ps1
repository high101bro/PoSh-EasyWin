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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUFAT/ybwbNAfKA2ZLfMk5f5l/
# bhugggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUYFVqP6U9dGqavvVDQ/ZeP256AV8wDQYJKoZI
# hvcNAQEBBQAEggEAqy8SsLIVwEIYFb3hAu71xWJO9h5UBxAtpgX/sHstswXyrIC/
# +AlMlTuem3VVhiZypXt4utwBrNoR4FUycY11VPZxNKClEoWhWex8DAj/CsaSfXsQ
# pFzx4CoLHxOHThzow3wmPSxS3AFfRtDPZv53C0xn4sAnJ4c7iQ8OFSnHLzFEczgt
# PVspvkRrT8porB4fNF3eedWD02ALkPPLGxMKMjJtCBwDWRw7Ig/XRK/3xI0ODUR6
# K8QPm1ZUjn4gfvi7hhk+uoCEXuGMW58VHYamgfIvVUE3Khud0W3cm321dQzxPybF
# VpRut5EBPlrvbwTemuAueYkCIhwUyu4abBkXRQ==
# SIG # End signature block
