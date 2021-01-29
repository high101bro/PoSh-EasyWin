function Push-SysinternalsProcessMonitor {
    param ($SysinternalsProcessMonitorTime = 5)
    $CollectionName = "Procmon"
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
                      
        # Collect Remote host Disk Space       
        Function Get-DiskSpace([string] $TargetComputer) {
                try { $HD = Get-WmiObject Win32_LogicalDisk -ComputerName $TargetComputer -Filter "DeviceID='C:'" -ErrorAction Stop } 
                catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Unable to connect to $TargetComputer. $_"); continue}
                if(!$HD) { throw }
                $FreeSpace = [math]::round(($HD.FreeSpace/1gb),2)
                return $FreeSpace
        }

        # Uses PsExec and Procmon to get Process Monitoring informaiton on remote hosts
        # Diskspace is calculated on local and target hosts to determine if there's a risk
        # Procmon is copied over to the target host, and data is gathered there and then exported back
        # The Procmon program and capture file are deleted
        Function SysinternalsProcessMonitorData {
            # Checks to see if the duration is within 10 and 100 seconds
            Param(
                [Parameter(Mandatory=$true)][string]$TargetComputer, 
                [Parameter(Mandatory=$true,
                    HelpMessage="Enter a duration from 10 to 300 seconds (limited due to disk space requriements")]
                    [ValidateRange(5,300)][int]$Duration
            )
            $SysinternalsExecutable      = 'procmon.exe'
            $ToolName                    = 'ProcMon'
            $AdminShare                  = 'c$'
            $LocalDrive                  = 'c:'
            $PsExecPath                  = "$ExternalPrograms\PsExec.exe"
            $SysinternalsExecutablePath  = "$ExternalPrograms\Procmon.exe"
            $TargetFolder                = "Windows\Temp"            
           
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Verifing connection to $TargetComputer, checking for PsExec and Procmon.")
    
            # Process monitor generates enormous amounts of data.  
            # To try and offer some protections, the script won't run if the source or target have less than 500MB free
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Verifying free diskspace on source and target.")
            if((Get-DiskSpace $TargetComputer) -lt 0.5) 
                { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $TargetComputer has less than 500MB free - aborting to avoid filling the disk"); break }

            if((Get-DiskSpace $Env:ComputerName) -lt 0.5) 
                { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Local computer has less than 500MB free - aborting to avoid filling the disk"); break }

            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $ToolName to $TargetComputer temporarily to be executed by PsExec")
            try { Copy-Item $SysinternalsExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop } 
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            # Process monitor must be launched as a separate process otherwise the sleep and terminate commands below would never execute and fill the disk
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Starting process monitor on $TargetComputer")
            #$Command = Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/accepteula $script:Credentials -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula /BackingFile $LocalDrive\$TargetFolder\$TargetComputer /RunTime 10 /Quiet" -PassThru | Out-Null
            $Command = Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula /BackingFile `"$LocalDrive\$TargetFolder\ProcMon-$TargetComputer`" /RunTime $Duration /Quiet" -PassThru | Out-Null
            $Command
            Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "$($SysinternalsProcessMonitorCheckbox.Name)"
            Create-LogEntry -LogFile $LogFile -TargetComputer $TargetComputer -Message "$Command"

            Start-Sleep -Seconds ($Duration + 5)

            while ($true) {
                if ($(Get-WmiObject -Class Win32_Process -ComputerName "$TargetComputer" | Where-Object {$_.ProcessName -match "Procmon"})) {                      
                    $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Checking ProcMon Status on $TargetComputer"
                    $ResultsListBox.Items.Insert(0,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $Message")
                    Start-Sleep -Seconds 30
                }
                else {
                    Start-Sleep -Seconds 5

                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $ToolName data to local machine for analysis")
                    try { Copy-Item "\\$TargetComputer\$AdminShare\$TargetFolder\ProcMon-$TargetComputer.pml" "$IndividualHostResults\$CollectionName" -Force -ErrorAction Stop }
                    catch { $_ ; }

                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Removing temporary $ToolName executable and data file from target system")
                 
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\ProcMon-$TargetComputer.pml" -Force
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysinternalsExecutable" -Force

                    $FileSize = [math]::round(((Get-Item "$IndividualHostResults\$CollectionName\$TargetComputer.pml").Length/1mb),2)    
                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] ..\ProcMon-$TargetComputer.pml is $FileSize MB. Remember to delete it when finished.")

                    #$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Launching $ToolName and loading collected log data")
                    #if(Test-Path("$IndividualHostResults\$CollectionName\ProcMon-$TargetComputer.pml")) { & $SysinternalsExecutablePath /openlog $IndividualHostResults\$CollectionName\ProcMon-$TargetComputer.pml }
                    break
                }
            }
        }
        $SysinternalsProcessMonitorTimeSwitch = switch ($SysinternalsProcessMonitorTime) {
            '5 Seconds'   {5}
            '10 Seconds'  {10}
            '15 Seconds'  {15}
            '30 Seconds'  {30}
            '1 Minute'    {60}
            '2 Minutes'   {120}
            '3 Minutes'   {180}
            '4 Minutes'   {240}
            '5 Minutes'   {360}
        }
        SysinternalsProcessMonitorData -TargetComputer $TargetComputer -Duration $SysinternalsProcessMonitorTimeSwitch
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