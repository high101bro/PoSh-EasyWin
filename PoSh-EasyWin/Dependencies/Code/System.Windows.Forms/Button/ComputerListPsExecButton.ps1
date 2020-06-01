$ComputerListPsExecButtonAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    Create-ComputerNodeCheckBoxArray
    if ($script:ComputerTreeViewSelected.count -eq 1) {        
        if (Verify-Action -Title "Verification: PSExec" -Question "Enter a PSEexec session to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
            # This brings specific tabs to the forefront/front view
            $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("PsExec:  $($script:ComputerTreeViewSelected)")
            $ResultsListBox.Items.Clear()
            if ($ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                $Username = $script:Credential.UserName
                $Password = $script:Credential.GetNetworkCredential().Password
                $UseCredential = "-u $Username -p $Password"
                $ResultsListBox.Items.Add("./PsExec.exe /AcceptEula \\$script:ComputerTreeViewSelected '<domain\username>' -p '<password>' cmd")
                Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process '$PsExecPath' -ArgumentList '/AcceptEula \\$script:ComputerTreeViewSelected $UseCredential cmd'"        
            }
            else { 
                $ResultsListBox.Items.Add("./PsExec.exe /AcceptEula \\$script:ComputerTreeViewSelected cmd")
                $ResultsListBox.Items.Add("$PsExecPath /AcceptEula \\$script:ComputerTreeViewSelected cmd")
                Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process '$PsExecPath' -ArgumentList '/AcceptEula \\$script:ComputerTreeViewSelected cmd'"
            }
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "PsExec: $($script:ComputerTreeViewSelected)"

            if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) { Generate-NewRollingPassword }
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("PSExec Session:  Cancelled")
        }
    }
    elseif ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'PsExec' }
    elseif ($script:ComputerTreeViewSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'PsExec' }
}

$ComputerListPsExecButtonAdd_MouseHover = {
    Show-ToolTip -Title "PsExec" -Icon "Info" -Message @"
+  Will attempt to obtain a cmd prompt via PsExec.
+  PsExec is a Windows Sysinternals tool.
+  Some anti-virus scanners will alert on this.
+  Command:
        PsExec.exe /AcceptEula \\<target> cmd
        PsExec.exe /AcceptEula \\<target> -u <domain\username> -p <password> cmd
+  Compatiable with 'Specify Credentials'
"@ 
}
