function Logout-AccountsOnMultipleComputers {
    param(
        [switch]$SelectAccountCsvFile,
        [switch]$CollectNewAccountData
    )
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab

    if ($SelectAccountCsvFile) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $SelectFileToLogoutSelectedAccountsOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Select File to Stop Selected Accounts"
            InitialDirectory = "$(if (Test-Path $($script:CollectionSavedDirectoryTextBox.Text)) {$($script:CollectionSavedDirectoryTextBox.Text)} else {$CollectedDataDirectory})"
            Filter           = "CSV (*.csv)|*.csv|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $SelectFileToLogoutSelectedAccountsOpenFileDialog.ShowDialog() | Out-Null

        Import-Csv -Path $($SelectFileToLogoutSelectedAccountsOpenFileDialog.filename) `
        | Select-Object -Property PSComputerName, * -ErrorAction SilentlyContinue `
        | Sort-Object -Property Name, PSComputername, * -ErrorAction SilentlyContinue `
        | Out-GridView -Title 'Select Accounts To Logout' -PassThru -OutVariable AccountsToLogout
    }
    elseif ($CollectNewAccountData) {
        Generate-ComputerList
        
        if ($script:ComputerList.count -eq 0){
            [System.Windows.MessageBox]::Show('Ensure you checkbox one or more endpoints to collect accounts logon info from. Alternatively, you can select a CSV file from a previous Accounts Currently Logon collection.','Error: No Endpoints Selected')
        }
        else {
            if ($ComputerListProvideCredentialsCheckBox.Checked) {
                $ScriptBlock = {
                    ## Find all sessions matching the specified username
                    $quser = quser | Where-Object {$_ -notmatch 'SESSIONNAME'} 

                    $sessions = ($quser -split "`r`n").trim()

                    foreach ($session in $sessions) {
                        try {
                            # This checks if the value is an integer, if it is then it'll TRY, if it errors then it'll CATCH
                            [int]($session -split '  +')[2] | Out-Null
                            
                            [PSCustomObject]@{
                                PSComputerName = $env:COMPUTERNAME
                                UserName       = ($session -split '  +')[0].TrimStart('>')
                                SessionName    = ($session -split '  +')[1]
                                SessionID      = ($session -split '  +')[2]
                                State          = ($session -split '  +')[3]
                                IdleTime       = ($session -split '  +')[4]
                                LogonTime      = ($session -split '  +')[5]
                            }        
                        }
                        catch {
                            [PSCustomObject]@{
                                PSComputerName = $env:COMPUTERNAME
                                UserName       = ($session -split '  +')[0].TrimStart('>')
                                SessionName    = ''
                                SessionID      = ($session -split '  +')[1]
                                State          = ($session -split '  +')[2]
                                IdleTime       = ($session -split '  +')[3]
                                LogonTime      = ($session -split '  +')[4]
                            }
                        }
                    }
                }
                if (!$script:Credential) { Create-NewCredentials }
                Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $script:ComputerList -Credential $script:Credential `
                | Select-Object -ExcludeProperty RunspaceID `
                | Out-GridView -Title 'Select Accounts To Logout' -PassThru -OutVariable AccountsToLogout
            }
            else {
                Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $script:ComputerList `
                | Select-Object -ExcludeProperty RunspaceID `
                | Out-GridView -Title 'Select Accounts To Logout' -PassThru -OutVariable AccountsToLogout
            }
        }
    }

    $AccountsToLogout = $AccountsToLogout | Sort-Object -Property PSComputerName
    $Computers = $AccountsToLogout | Select-Object -ExpandProperty PSComputerName -Unique | Sort-Object

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Multi-Endpoint Account Logout")
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
            $ResultsListBox.Items.Insert(0,"Connected to:  $Computer")
    
            if ($Session) {
                foreach ($Logon in $AccountsToLogout){
                    if ($Logon.PSComputerName -eq $Computer){
                        $AccountName = $Logon.AccountName
                        $SessionID   = $Logon.SessionID
                        $ResultsListBox.Items.Insert(1,"  - Logging Out:  [Computer]$Computer  [Account]$AccountName  [SessionID]$SessionId")
                        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Invoke-Command -ScriptBlock { param($SessionID) C:\Windows\System32\Logoff.exe $SessionID } -ArgumentList $SessionID -Session $Session"
                        Invoke-Command -ScriptBlock { 
                            param($SessionID)
                            & 'C:\Windows\System32\Logoff.exe' $SessionID 
                        } -ArgumentList $SessionID -Session $Session
                    }
                }
                Remove-PSSession -Session $Session
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remove-PSSession -Session $Session"
            }
        }
        catch {
            $ResultsListBox.Items.Insert(1,"Unable to Connect:  $Computer")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Unable to Connect:  $Computer"
        }
    }
    # To alert the user that it's finished
    [system.media.systemsounds]::Exclamation.play()
    if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) { Generate-NewRollingPassword }
}


