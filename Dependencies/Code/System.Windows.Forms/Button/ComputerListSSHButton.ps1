$ComputerListSSHButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList

    if ($ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: SSH" -Question "Connecting Account:  $Username`n`nEnter a SSH session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
        if ($script:ComputerListUseDNSCheckbox.checked) { 
            $script:ComputerTreeViewSelected = $script:ComputerListEndpointNameToolStripLabel.text 
        }
        else {
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
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
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select SSH.','SSH')
    }

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("SSH:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password

            if ($Username -like '*@*'){
                $User     = $Username.split('@')[0]
                $Domain   = $Username.split('@')[1]
                $Username = "$($Domain)\$($User)"
            }

            $ResultsListBox.Items.Add("kitty-0.74.4.7.exe -ssh '$script:ComputerTreeViewSelected' -l '$Username' -pw 'password'")
            start-process $kitty_ssh_client -ArgumentList @("-ssh",$script:ComputerTreeViewSelected,"-l",$Username,"-pw",$Password)
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "start-process $kitty_ssh_client -ArgumentList @(`"-ssh`",$script:ComputerTreeViewSelected,`"-l`",$User,`"-pw`",`"Password`")"
        }
        else {
            $ResultsListBox.Items.Add("kitty-0.74.4.7.exe -ssh '$script:ComputerTreeViewSelected' -l '$Username'")
            start-process $kitty_ssh_client -ArgumentList @("-ssh",$script:ComputerTreeViewSelected,"-l",$Username)
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "start-process $kitty_ssh_client -ArgumentList @(`"-ssh`",$script:ComputerTreeViewSelected,`"-l`",$User)"
        }

        if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Generate-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("SSH:  Cancelled")
    }
}

$ComputerListPsExecButtonAdd_MouseHover = {
    Show-ToolTip -Title "SSH" -Icon "Info" -Message @"
+  Will attempt to obtain a cmd prompt via SSH.
+  KiTTY is a better version forked from Plink (PuTTY) that not only has all the same features has but many more.
+  Plink (PuTTY cli tool), is an ssh client often used for automation, but has integration issues with this tool.
+  SSH (OpenSSH) is natively available on Windows 10 as up the April 2018 update, it does not support passing credentials automatically.
+  Usefult to access Linux and Windows hosts with SSH enabled.
+  Command:
        kitty.exe -ssh 'IP/hostname' -l 'username' -pw 'password'
+  Compatiable with 'Specify Credentials'
"@
}


