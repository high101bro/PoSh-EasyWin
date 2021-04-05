$ComputerListPSSessionPivotButtonAdd_Click = {

    $InformationTabControl.SelectedTab = $Section3ResultsTab
    Create-ComputerNodeCheckBoxArray
    Generate-ComputerList

    if ($ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: PowerShell Session" -Question "Connecting Account:  $Username`n`nEnter a PowerShell Session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
        if ($script:ComputerListUseDNSCheckbox.checked) { 
            $script:ComputerTreeViewSelected = $script:ComputerListEndpointNameToolStripLabel.text 
        }
        else {
            [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
            foreach ($root in $AllHostsNode) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.Text -eq $script:ComputerListEndpointNameToolStripLabel.text) {
                            foreach ($Metadata in $Entry.nodes) {
                                if ($Metadata.Name -eq 'IPv4Address') {
                                    $script:ComputerTreeViewSelected = $Metadata.text
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    elseif (-not $script:ComputerListEndpointNameToolStripLabel.text) {
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select PSSession.','PowerShell Session')
    }

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Pivot-PSSession:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (-not $script:Credential) { Create-NewCredentials }
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password

            $password = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Password))

            $ResultsListBox.Items.Add("Pivot-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential")
            #Normal PSSession# start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-noexit -Command Enter-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential `$(New-Object PSCredential('$Username'`,`$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$Password')) | ConvertTo-SecureString -AsPlainText -Force)))"

            start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-noexit -Command Enter-PSSession -ComputerName $($script:ComputerListPivotExecutionTextBox.text) -Credential `$(New-Object PSCredential('$Username'`,`$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$Password')) | ConvertTo-SecureString -AsPlainText -Force))); function Pivot-PSSession(`$Id) { while ( `$Command -ne 'Exit' ) {`$Session = Get-PSSession -Id `$id; `$ComputerName = `$Session.ComputerName; Write-Host -NoNewline `"[$($script:ComputerListPivotExecutionTextBox.text) --> `$ComputerName]: Pivot> `"; `$Command = Read-Host; Invoke-Command -Session `$Session -ScriptBlock {param(`$Command) invoke-command {iex `$Command}} -ArgumentList `$Command; }; exit; }; Pivot-PSSession -Id (New-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential `$(New-Object PSCredential('$Username'`,`$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$Password')) | ConvertTo-SecureString -AsPlainText -Force)))).Id"
            <#
            Enter-PSSession -ComputerName win10-02 -Credential $creds
            function Pivot-PSSession($Id) {
                while ( $Command -ne "Exit" ) {
                    $Session = Get-PSSession -Id $id
                    $ComputerName = $Session.ComputerName
                    Write-Host -NoNewline "[$ComputerName]: Pivot> "
                    $Command = Read-Host
                    #limited#$ScriptBlock = [scriptblock]::Create($Command)
                    #limited#Invoke-Command -Session $Session -ScriptBlock $ScriptBlock -ArgumentList $creds
                    Invoke-Command -Session $Session -ScriptBlock {param($Command) invoke-command {iex $Command}} -ArgumentList @($Command,$creds)
                }
                exit
            }       
            Pivot-PSSession -Id (New-PSSession -ComputerName dc01 -Credential $creds).Id
            #>
            Start-Sleep -Seconds 3
        }
        else {
            $ResultsListBox.Items.Add("Pivot-PSSession -ComputerName $script:ComputerTreeViewSelected")
            start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-noexit -Command Enter-PSSession -ComputerName 'win10-01' | ConvertTo-SecureString -AsPlainText -Force))); function Pivot-PSSession(`$Id) { while ( `$Command -ne 'Exit' ) {`$Session = Get-PSSession -Id `$id; `$ComputerName = `$Session.ComputerName; Write-Host -NoNewline `"[$($script:ComputerListPivotExecutionTextBox.text) --> `$ComputerName]: Pivot> `"; `$Command = Read-Host; Invoke-Command -Session `$Session -ScriptBlock {param(`$Command) invoke-command {iex `$Command}} -ArgumentList `$Command; }; exit; }; Pivot-PSSession -Id (New-PSSession -ComputerName dc01).Id"
            Start-Sleep -Seconds 3
        }
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Pivot-PSSession -ComputerName $($script:ComputerTreeViewSelected)"

        if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Generate-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Pivot-PSSession:  Cancelled")
    }
}

$ComputerListPSSessionPivotButtonAdd_MouseHover = {
    Show-ToolTip -Title "Pivot-PSSession" -Icon "Info" -Message @"
+  Starts an interactive session with the specified pivot endpoint.
+  Uses Invoke-Command to route commands to the target endpoint thru the pivot endpoint.
+  Requires the WinRM service.
"@
}


