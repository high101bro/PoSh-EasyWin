$ComputerListPsExecButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList

    if ($script:ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: PSExec" -Question "Connecting Account:  $Username`n`nEnter a PSEexec session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
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
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select PSExec.','PSExec (Sysinternals)')
    }

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PsExec:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        if ($script:ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password

            if ($Username -like '*@*'){
                $User     = $Username.split('@')[0]
                $Domain   = $Username.split('@')[1]
                $Username = "$($Domain)\$($User)"
            }
            $Password = "'$Password'"

            $ResultsListBox.Items.Add("./PsExec.exe -AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected '<domain\username>' -p '<password>' cmd")
            #opens in black terminal# Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process '$PsExecPath' -ArgumentList '-AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected -u '$Username' -p '$Password' cmd'"
            start-process powershell "-noexit -command $PsExecPath -accepteula -nobanner \\$script:ComputerTreeViewSelected -u $Username -p $Password cmd"
        }
        else {
            $ResultsListBox.Items.Add("./PsExec.exe -AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected cmd")
            #$ResultsListBox.Items.Add("$PsExecPath -AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected cmd")
            #opens in black terminal# Start-Process PowerShell -WindowStyle Hidden -ArgumentList "Start-Process '$PsExecPath' -ArgumentList '-AcceptEULA -NoBanner \\$script:ComputerTreeViewSelected cmd'"
            start-process powershell "-noexit -command $PsExecPath -accepteula -nobanner \\$script:ComputerTreeViewSelected cmd"
        }
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "PsExec: $($script:ComputerTreeViewSelected)"

        if ($script:RollCredentialsState -and $script:ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Generate-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PSExec Session:  Cancelled")
    }
}