function Stop-ProcessesOnMultipleComputers {
    param(
        [switch]$SelectProcessCsvFile,
        [switch]$CollectNewProcessData
    )
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    
    if ($SelectProcessCsvFile) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $SelectProcessFileToStopSelectedProcessesOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Select Process File to Stop Selected Processes"
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
            Filter           = "CSV (*.csv)|*.csv|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $SelectProcessFileToStopSelectedProcessesOpenFileDialog.ShowDialog() | Out-Null

        Import-Csv -Path $($SelectProcessFileToStopSelectedProcessesOpenFileDialog.filename) `
        | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
        | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
        | Out-GridView -Title 'Select Processes To Stop' -PassThru -OutVariable ProcessesToStop
    }
    elseif ($CollectNewProcessData) {
        Generate-ComputerListToQuery
        
        if ($script:ComputerList.count -eq 0){
            [System.Windows.MessageBox]::Show('Ensure you checkbox one or more endpoints to collect process data from. Alternatively, you can select a CSV file from a previous process collection.','Error: No Endpoints Selected')
        }
        else {
            if ($ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                Invoke-Command -ScriptBlock { 
                    Get-Process #| Select-Object -Property @{n='PSComputerName';e={$(hostname)}}, * 
                } -ComputerName $script:ComputerList -Credential $script:Credential `
                | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
                | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
                | Out-GridView -Title 'Select Processes To Stop' -PassThru -OutVariable ProcessesToStop
            }
            else {
                Invoke-Command -ScriptBlock { 
                    Get-Process #| Select-Object -Property @{n='PSComputerName';e={$(hostname)}}, * 
                } -ComputerName $script:ComputerList `
                | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
                | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
                | Out-GridView -Title 'Select Processes To Stop' -PassThru -OutVariable ProcessesToStop
            }
        }
    }

    $ProcessesToStop = $ProcessesToStop | Sort-Object -Property PSComputerName
    $Computers = $ProcessesToStop | Select-Object -ExpandProperty PSComputerName -Unique | Sort-Object

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Domain Wide Process Stopper")
    $ResultsListBox.Items.Clear()

    foreach ($Computer in $Computers) {    
        $Session = $null

        try {
            if ($script:Credential) {
                $Session = New-PSSession -ComputerName $Computer -Credential $script:Credential
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $Computer -Credential $script:Credential"
            }
            else {
                $Session = New-PSSession -ComputerName $Computer
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "New-PSSession -ComputerName $Computer"
            }
            #Write-Host "Connected to:  $Computer" -ForegroundColor Cyan
            $ResultsListBox.Items.Insert(0,"Connected to:  $Computer")
    
            if ($Session) {
                foreach ($Process in $ProcessesToStop){
                    if ($Process.PSComputerName -eq $Computer){
                        $ProcessId   = $Process.id
                        $ProcessName = $Process.Name
                        #Write-Host "  - Stopping:  $Process" -ForegroundColor Green
                        $ResultsListBox.Items.Insert(1,"  - Stopping Process:  [Name]$($Process.Name)  [PID]$($Process.Id)")
                        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { param(`$ProcessName,`$ProcessID); Stop-Process -Name $ProcessName | Where-Object {`$_.Id -eq $ProcessID}} -ArgumentList @(`$ProcessName,`$ProcessID) -Session `$Session"
                        Invoke-Command -ScriptBlock { param($ProcessName,$ProcessID); Stop-Process -Name $ProcessName -Force | Where-Object {$_.Id -eq $ProcessID}} -ArgumentList @($ProcessName,$ProcessID) -Session $Session
                    }
                }
                Remove-PSSession -Session $Session
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remove-PSSession -Session $Session"
            }
        }
        catch {
            #Write-Host "Unable to Connect:  $Computer" -ForegroundColor Red
            $ResultsListBox.Items.Insert(1,"Unable to Connect:  $Computer")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Unable to Connect:  $Computer"
        }
    }
}


