function Push-SysinternalsAutoruns {
    $CollectionName = "Autoruns"
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
        Function SysinternalsAutorunsData {
            $SysinternalsExecutable     = 'Autoruns.exe'
            $ToolName                   = 'Autoruns'
            $AdminShare                 = 'c$'
            $LocalDrive                 = 'c:'
            $PsExecPath                 = "$ExternalPrograms\PsExec.exe"
            $SysinternalsExecutablePath = "$ExternalPrograms\Autoruns.exe"
            $TargetFolder               = "Windows\Temp"
            
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $ToolName to $TargetComputer temporarily to be executed by PsExec")
            try { Copy-Item $SysinternalsExecutablePath "\\$TargetComputer\$AdminShare\$TargetFolder" -Force -ErrorAction Stop } 
            catch { $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $($_.Exception)"); break }

            # Process monitor must be launched as a separate process otherwise the sleep and terminate commands below would never execute and fill the disk
            $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Starting Autoruns on $TargetComputer")
            Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$SysinternalsExecutable /AcceptEula -a $LocalDrive\$TargetFolder\Autoruns-$TargetComputer.arn" -PassThru | Out-Null   

            #$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Terminating $ToolName process on $TargetComputer")
            #Start-Process -WindowStyle Hidden -FilePath $PsExecPath -ArgumentList "/accepteula -s \\$TargetComputer $LocalDrive\$TargetFolder\$procmon /accepteula /terminate /quiet" -PassThru | Out-Null
            Start-Sleep -Seconds 30

            # Checks to see if the process is still running
            while ($true) {
                if ($(Get-WmiObject -Class Win32_Process -ComputerName "$TargetComputer" | Where-Object {$_.ProcessName -match "Autoruns"})) {  
                    #$RemoteFileSize = "$(Get-ChildItem -Path `"C:\$TempPath`" | Where-Object {$_.Name -match `"$MemoryCaptureFile`"} | Select-Object -Property Length)" #-replace "@{Length=","" -replace "}",""
                    
                    $Message = "$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) Checking Autoruns Status on $TargetComputer"
                    #$ResultsListBox.Items.RemoveAt(0) ; $ResultsListBox.Items.RemoveAt(0)
                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] $Message")
                    Start-Sleep -Seconds 30
                }
                else {
                    Start-Sleep -Seconds 5
                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [+] Copying $ToolName data to local machine for analysis")
                    try { Copy-Item "\\$TargetComputer\$AdminShare\$TargetFolder\Autoruns-$TargetComputer.arn" "$IndividualHostResults\$CollectionName" -Force -ErrorAction Stop }
                    catch { $_ ; }

                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [-] Removing temporarily $ToolName executable and data file from target system")                 
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\Autoruns-$TargetComputer.arn" -Force
                    Remove-Item "\\$TargetComputer\$AdminShare\$TargetFolder\$SysinternalsExecutable" -Force

                    $FileSize = [math]::round(((Get-Item "$IndividualHostResults\$CollectionName\Autoruns-$TargetComputer.arn").Length/1mb),2)    
                    $ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] ..\Autoruns-$TargetComputer.arn is $FileSize MB. Remember to delete it when finished.")

                    #$ResultsListBox.Items.Insert(2,"$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss'))   [!] Launching $ToolName and loading collected log data")
                    #if(Test-Path("$IndividualHostResults\$CollectionName\Autoruns-$TargetComputer.arn")) { & $SysinternalsExecutablePath $IndividualHostResults\$CollectionName\Autoruns-$TargetComputer.arn }
                    break
                }
            }
        }
        SysinternalsAutorunsData -TargetComputer $TargetComputer
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