function Push-SysinternalsSysmon {
    param ($SysmonXMLPath, $SysmonXMLName)
    $CollectionName = "Sysmon"
    $CollectionCommandStartTime = Get-Date 
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Query: $CollectionName")                    
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName")
    foreach ($TargetComputer in $ComputerList) {
        $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) $CollectionName - $TargetComputer")
        Conduct-PreCommandCheck -CollectedDataTimeStampDirectory $CollectedDataTimeStampDirectory `
                                -IndividualHostResults $IndividualHostResults -CollectionName $CollectionName `
                                -TargetComputer $TargetComputer
        Create-LogEntry -TargetComputer $TargetComputer -CollectionName $CollectionName -LogFile $LogFile

        $SysinternalsExecutable     = 'Sysmon.exe'
        $ToolName                   = 'Sysmon'
        $AdminShare                 = 'c$'
        $LocalDrive                 = 'c:'
        $PsExecPath                 = "$ExternalPrograms\PsExec.exe"
        $SysinternalsExecutablePath = "$ExternalPrograms\Sysmon.exe"
        $SysmonXMLName              = "$SysmonXMLName"     
        $SysmonXMLPath              = "$SysmonXMLPath"
        $TargetFolder               = "Windows\Temp"
            
        # Checks is the sysmon service is already installed, if so it updates the sysmon configuration
        if ($(Get-Service -ComputerName $TargetComputer -Name sysmon)){
            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] $ToolName is already an installed service on $TargetComputer")
            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $ToolName to $TargetComputer to update $ToolName configuration")
            try { Copy-Item $SysinternalsExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop } 
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }                

            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $SysmonXMLName config file to $TargetComputer to be used by $ToolName")
            try { Copy-Item $SysmonXMLPath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop } 
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Updating $ToolName configuration on $TargetComputer")
            #Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable -AcceptEula -c '$LocalDrive\$TargetFolder\$SysmonXMLName'" -PassThru | Out-Null
            Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList "$LocalDrive\$TargetFolder\$SysinternalsExecutable -accepteula -c $LocalDrive\$TargetFolder\$SysmonXMLName"
            Start-Sleep -Seconds 5

            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Removing $ToolName executable and $SysmonXMLName from $TargetComputer")                 
            Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysinternalsExecutable" -Force
            Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysmonXMLName" -Force
        }
        # If sysmon is not a service, it will install sysmon with the selected configuration
        else {
            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $ToolName to $TargetComputer to be executed by PsExec")
            try { Copy-Item $SysinternalsExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop } 
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $SysmonXMLName config file to $TargetComputer to be used by $ToolName")
            try { Copy-Item $SysmonXMLPath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop } 
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Installing $ToolName on $TargetComputer")
            #Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula -i '$LocalDrive\$TargetFolder\$SysmonXMLName'" -PassThru | Out-Null
            $Command = "Invoke-WmiMethod -ComputerName $TargetComputer -Class Win32_Process -Name Create -ArgumentList '$LocalDrive\$TargetFolder\$SysinternalsExecutable -accepteula -i $LocalDrive\$TargetFolder\$SysmonXMLName'"
            Invoke-Expression $Command #batman
            $Command | out-file "C:\test.txt"
            Start-Sleep -Seconds 5

            $ResultsListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Removing $ToolName executable and $SysmonXMLName from $TargetComputer")                 
            Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysinternalsExecutable" -Force
            Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysmonXMLName" -Force
        }
        $CollectionCommandEndTime1  = Get-Date 
        $CollectionCommandDiffTime1 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime1
        $ResultsListBox.Items.RemoveAt(1)
        $ResultsListBox.Items.Insert(1,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime1]  $CollectionName - $TargetComputer")
    }
    $CollectionCommandEndTime0  = Get-Date 
    $CollectionCommandDiffTime0 = New-TimeSpan -Start $CollectionCommandStartTime -End $CollectionCommandEndTime0
    $ResultsListBox.Items.RemoveAt(0)
    $ResultsListBox.Items.Insert(0,"$(($CollectionCommandStartTime).ToString('yyyy/MM/dd HH:mm:ss')) [$CollectionCommandDiffTime0]  $CollectionName")
}