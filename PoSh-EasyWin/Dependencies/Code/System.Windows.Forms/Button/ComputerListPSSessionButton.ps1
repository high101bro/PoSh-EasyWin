$ComputerListPSSessionButtonAdd_Click = {
    Create-ComputerNodeCheckBoxArray
    if ($script:ComputerTreeViewSelected.count -eq 1) {        
        if (Verify-Action -Title "Verification: PowerShell Session" -Question "Enter a PowerShell Session to the following?" -Computer $($script:ComputerTreeViewSelected)) {
            # This brings specific tabs to the forefront/front view
            $Section4TabControl.SelectedTab = $Section3ResultsTab

            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Enter-PSSession:  $($script:ComputerTreeViewSelected)")
            $ResultsListBox.Items.Clear()
            if ($ComputerListProvideCredentialsCheckBox.Checked) {
                if (-not $script:Credential) { Create-NewCredentials }
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                $Username = $script:Credential.UserName
                $Password = $script:Credential.GetNetworkCredential().Password
                $ResultsListBox.Items.Add("Enter-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential")                        
                start-process powershell -ArgumentList "-noexit Enter-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential `$(New-Object pscredential('$Username'`,`$('$Password' | ConvertTo-SecureString -AsPlainText -Force)))"
            }
    
            else {
                $ResultsListBox.Items.Add("Enter-PSSession -ComputerName $script:ComputerTreeViewSelected")
                Start-Process PowerShell -ArgumentList "-noexit Enter-PSSession -ComputerName $script:ComputerTreeViewSelected" 
            }
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Enter-PSSession -ComputerName $($script:ComputerTreeViewSelected)"

            if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) { Generate-NewRollingPassword }
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("PowerShell Session:  Cancelled")
        }
    }
    elseif ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Enter-PSSession' }
    elseif ($script:ComputerTreeViewSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Enter-PSSession' }
}

$ComputerListPSSessionButtonAdd_MouseHover = {
    Show-ToolTip -Title "Enter-PSSession" -Icon "Info" -Message @"
+  Starts an interactive session with a remote computer.
+  Requires the WinRM service.
+  To use with an IP address, the Credential parameter must be used.
Also, the computer must be configured for HTTPS transport or
the remote computer's IP must be in the local TrustedHosts.
+  Command:
        Enter-PSSession -ComputerName <target>
+  Compatiable with 'Specify Credentials'
"@ 
}
