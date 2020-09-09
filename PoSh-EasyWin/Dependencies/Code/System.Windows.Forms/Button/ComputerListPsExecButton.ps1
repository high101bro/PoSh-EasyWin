$ComputerListPsExecButtonAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    Create-ComputerNodeCheckBoxArray
    Generate-ComputerList

    if ($script:ComputerTreeViewSelected.count -eq 1 -or $script:ComputerListEndpointNameToolStripLabel.text -in $script:ComputerList) {        
        if ($script:ComputerListEndpointNameToolStripLabel.text -in $script:ComputerList) {
            $VerifyRDP = Verify-Action -Title "Verification: PSExec" -Question "Enter a PSEexec session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
            $script:ComputerTreeViewSelected = $script:ComputerListEndpointNameToolStripLabel.text
        }
        else {
            $VerifyRDP = Verify-Action -Title "Verification: PSExec" -Question "Enter a PSEexec session to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')
        }
        if ($VerifyRDP) {
            # This brings specific tabs to the forefront/front view
            $MainBottomTabControl.SelectedTab = $Section3ResultsTab
     
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("PsExec:  $($script:ComputerTreeViewSelected)")
            #Removed For Testing#$ResultsListBox.Items.Clear()
            if ($ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                $Username = $script:Credential.UserName
                $Password = $script:Credential.GetNetworkCredential().Password
                $UseCredential = "-u $Username -p $Password"
                $ResultsListBox.Items.Add("./PsExec.exe -AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected '<domain\username>' -p '<password>' cmd")
                Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process '$PsExecPath' -ArgumentList '-AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected $UseCredential cmd'"
            }
            else { 
                $ResultsListBox.Items.Add("./PsExec.exe -AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected cmd")
                $ResultsListBox.Items.Add("$PsExecPath -AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected cmd")
                Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process '$PsExecPath' -ArgumentList '-AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected cmd'"
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
        PsExec.exe -AcceptEULA -NoBanner \\<target> cmd
        PsExec.exe -AcceptEULA -NoBanner \\<target> -u <domain\username> -p <password> cmd
+  Compatiable with 'Specify Credentials'
"@ 
}
