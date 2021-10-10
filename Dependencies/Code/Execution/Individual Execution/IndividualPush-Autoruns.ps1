$CollectionName = "Autoruns"
$ExecutionStartTime = Get-Date
$StatusListBox.Items.Clear()
$StatusListBox.Items.Add("Query: $CollectionName")
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")


$AutorunsName                   = 'Autoruns'
$AutorunsExecutable             = "$AutorunsName.exe"
$AdminShare                     = 'C$'
$LocalDrive                     = 'C:'
$LocalPathForAutorunsExecutable = "$ExternalPrograms\$AutorunsExecutable"
$TargetFolder                   = "Windows\Temp"

New-Item "$script:IndividualHostResults\Autoruns" -Type Directory

# Renames Autoruns Process name in order to obfuscate deployent
if ($SysinternalsAutorunsRenameProcessTextBox.text -ne 'Autoruns') {
    Copy-Item -Path "$LocalPathForAutorunsExecutable" -Destination "$ExternalPrograms\$($SysinternalsAutorunsRenameProcessTextBox.text).exe" -Force
    $AutorunsName                   = "$($SysinternalsAutorunsRenameProcessTextBox.text)"
    $AutorunsExecutable             = "$($SysinternalsAutorunsRenameProcessTextBox.text).exe"
    $LocalPathForAutorunsExecutable = "$ExternalPrograms\$AutorunsExecutable"
}


foreach ($TargetComputer in $script:ComputerList) {
    $ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName - $TargetComputer")
    Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $script:CollectedDataTimeStampDirectory `
                            -IndividualHostResults "$script:IndividualHostResults" -CollectionName $CollectionName `
                            -TargetComputer $TargetComputer
    Create-LogEntry -TargetComputer $TargetComputer  -LogFile $LogFile -Message $CollectionName

    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $AutorunsName to $TargetComputer")
    try { Copy-Item $LocalPathForAutorunsExecutable "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop }
    catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }


    if ($SysinternalsAutorunsRenameProcessTextBox.text -ne 'Autoruns') {
        # Removes the local renamed copy of Autoruns
        Remove-Item "$ExternalPrograms\$($SysinternalsAutorunsRenameProcessTextBox.text).exe" -Force
    }

    # Process monitor must be launched as a separate process otherwise the sleep and terminate commands below would never execute and fill the disk
    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Starting Autoruns on $TargetComputer")
    #Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/AcceptEULA -s \\$TargetComputer $LocalDrive\$TargetFolder\$AutorunsExecutable /AcceptEULA -a $LocalDrive\$TargetFolder\Autoruns-$TargetComputer.arn" -PassThru | Out-Null
    Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList "$RemoteDrive\$TargetFolder\$AutorunsExecutable  /AcceptEULA -a $LocalDrive\$TargetFolder\$AutorunsName.arn"


    #$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Terminating $AutorunsName process on $TargetComputer")
    #Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/AcceptEULA -s \\$TargetComputer $LocalDrive\$TargetFolder\$procmon /AcceptEULA /terminate /quiet" -PassThru | Out-Null
    Start-Sleep -Seconds $ExternalProgramsTimoutOutTextBox.Text

    # Checks to see if the process is still running
    while ($true) {
        if ($(Get-WmiObject -Class Win32_Process -ComputerName "$TargetComputer" | Where-Object {$_.ProcessName -match "$AutorunsName"})) {
            #$RemoteFileSize = "$(Get-ChildItem -Path `"C:\$TempPath`" | Where-Object {$_.Name -match `"$MemoryCaptureFile`"} | Select-Object -Property Length)" #-replace "@{Length=","" -replace "}",""

            $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Checking Autoruns Status on $TargetComputer"
            #$ResultsListBox.Items.RemoveAt(0) ; $ResultsListBox.Items.RemoveAt(0)
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $Message")
            Start-Sleep -Seconds $ExternalProgramsTimoutOutTextBox.Text
        }
        else {
            Start-Sleep -Seconds 5
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $AutorunsName data to local machine for analysis")
            try { Copy-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$AutorunsName.arn" "$script:IndividualHostResults\$CollectionName" -Force -ErrorAction Stop }
            catch { $_ ; }

            Rename-Item "$script:IndividualHostResults\$CollectionName\$AutorunsName.arn" "$script:IndividualHostResults\$CollectionName\Autoruns-$TargetComputer.arn" -Force

            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Removing temporarily $AutorunsName executable and data file from target system")
            Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$AutorunsName.arn" -Force
            Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$AutorunsName.exe" -Force

            $FileSize = [math]::round(((Get-Item "$script:IndividualHostResults\$CollectionName\Autoruns-$TargetComputer.arn").Length/1mb),2)
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] ..\Autoruns-$TargetComputer.arn is $FileSize MB.")

            #$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Launching $AutorunsName and loading collected log data")
            #if(Test-Path("$script:IndividualHostResults\$CollectionName\Autoruns-$TargetComputer.arn")) { & $LocalPathForAutorunsExecutable  "$script:IndividualHostResults\$CollectionName\Autoruns-$TargetComputer.arn" }
            break
        }
    }

    $SysinternalsAutorunsButton.BackColor = 'LightGreen'

    $CollectionCommandEndTime1  = Get-Date
    $CollectionCommandDiffTime1 = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime1
    $ResultsListBox.Items.RemoveAt(1)
    $ResultsListBox.Items.Insert(1,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime1]  $CollectionName - $TargetComputer")
}

$CollectionCommandEndTime0  = Get-Date
$CollectionCommandDiffTime0 = New-TimeSpan -Start $ExecutionStartTime -End $CollectionCommandEndTime0
$ResultsListBox.Items.RemoveAt(0)
$ResultsListBox.Items.Insert(0,"$(($ExecutionStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime0]  $CollectionName")


