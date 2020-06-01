$ComputerListRDPButtonAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    Create-ComputerNodeCheckBoxArray
    if ($script:ComputerTreeViewSelected.count -eq 1) {
        if (Verify-Action -Title "Verification: Remote Desktop" -Question "Open a Remote Desktop session to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
            # This brings specific tabs to the forefront/front view
            $MainBottomTabControl.SelectedTab = $Section3ResultsTab

            if ($ComputerListProvideCredentialsCheckBox.Checked) {
                if (!$script:Credential) { Create-NewCredentials }
                Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
                $Username = $script:Credential.UserName
                $Password = $script:Credential.GetNetworkCredential().Password
                # The cmdkey utility helps you manage username and passwords; it allows you to create, delete, and display credentials for the current user
                    # cmdkey /list                <-- lists all credentials
                    # cmdkey /list:targetname     <-- lists the credentials for a speicific target
                    # cmdkey /add:targetname      <-- creates domain credential
                    # cmdkey /generic:targetname  <-- creates a generic credential
                    # cmdkey /delete:targetname   <-- deletes target credential
                #cmdkey /generic:TERMSRV/$script:ComputerTreeViewSelected /user:$Username /pass:$Password
                cmdkey /add:$script:ComputerTreeViewSelected /user:$Username /pass:$Password
                mstsc /v:$($script:ComputerTreeViewSelected):3389
                #Start-Sleep -Seconds 1
                #cmdkey /delete:$script:ComputerTreeViewSelected 
                
                if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) { Generate-NewRollingPassword }
            }
            else {
                mstsc /v:$($script:ComputerTreeViewSelected):3389
            }
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Remote Desktop:  $($script:ComputerTreeViewSelected)")
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("mstsc /v:$($script:ComputerTreeViewSelected):3389")
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Remote Desktop (RDP): $($script:ComputerTreeViewSelected)"
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Remote Desktop:  Cancelled")
        }
    }
    elseif ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Remote Desktop' }
    elseif ($script:ComputerTreeViewSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Remote Desktop' }
}

$ComputerListRDPButtonAdd_MouseHover = {
    Show-ToolTip -Title "Remote Desktop Connection" -Icon "Info" -Message @"
+  Will attempt to RDP into a single host.
+  Command:
        mstsc /v:<target>:3389
        mstsc /v:<target>:3389 /user:USERNAME /pass:PASSWORD
+  Compatiable with 'Specify Credentials' if permitted by network policy
"@ 
}
