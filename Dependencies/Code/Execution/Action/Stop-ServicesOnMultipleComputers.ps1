function Stop-ServicesOnMultipleComputers {
    param(
        [switch]$SelectServiceCsvFile,
        [switch]$CollectNewServiceData
    )
    $InformationTabControl.SelectedTab = $Section3ResultsTab

    if ($SelectServiceCsvFile) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $SelectServiceFileToStopSelectedServicesOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Select Service File to Stop Selected Services"
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
            Filter           = "CSV (*.csv)|*.csv|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $SelectServiceFileToStopSelectedServicesOpenFileDialog.ShowDialog() | Out-Null

        Import-Csv -Path $($SelectServiceFileToStopSelectedServicesOpenFileDialog.filename) `
        | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
        | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
        | Out-GridView -Title 'Select Services To Stop' -PassThru -OutVariable ServicesToStop
    }
    elseif ($CollectNewServiceData) {
        Generate-ComputerList

        if ($script:ComputerList.count -eq 0){
            [System.Windows.MessageBox]::Show('Ensure you checkbox one or more endpoints to collect Service data from. Alternatively, you can select a CSV file from a previous Service collection.','Error: No Endpoints Selected')
        }
        else {
            if ($ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                Invoke-Command -ScriptBlock {
                    Get-Service #| Select-Object -Property @{n='PSComputerName';e={$(hostname)}}, *
                } -ComputerName $script:ComputerList -Credential $script:Credential `
                | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
                | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
                | Out-GridView -Title 'Select Services To Stop' -PassThru -OutVariable ServicesToStop
            }
            else {
                Invoke-Command -ScriptBlock {
                    Get-Service #| Select-Object -Property @{n='PSComputerName';e={$(hostname)}}, *
                } -ComputerName $script:ComputerList `
                | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
                | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
                | Out-GridView -Title 'Select Services To Stop' -PassThru -OutVariable ServicesToStop
            }
        }
    }

    $ServicesToStop = $ServicesToStop | Sort-Object -Property PSComputerName
    $Computers = $ServicesToStop | Select-Object -ExpandProperty PSComputerName -Unique | Sort-Object

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Multi-Endpoint Service Stopper")
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
                foreach ($Service in $ServicesToStop){
                    if ($Service.PSComputerName -eq $Computer){
                        $ServiceName = $Service.Name
                        #Write-Host "  - Stopping:  $Service" -ForegroundColor Green
                        $ResultsListBox.Items.Insert(1,"  - Stopping Service:  [Computer]$Computer  [Service]$($Service.Name)  [Display Name]$($Service.DisplayName)")
                        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { param(`$ServiceName,`$ServiceID); Stop-Service -Name $ServiceName -Force | Where-Object {`$_.Id -eq $ServiceID}} -ArgumentList @(`$ServiceName,`$ServiceID) -Session `$Session"
                        Invoke-Command -ScriptBlock { param($ServiceName); Stop-Service -Name $ServiceName } -ArgumentList $ServiceName -Session $Session
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
    # To alert the user that it's finished
    [system.media.systemsounds]::Exclamation.play()

    if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) {
        Start-Sleep -Seconds 3
        Generate-NewRollingPassword
    }
}




