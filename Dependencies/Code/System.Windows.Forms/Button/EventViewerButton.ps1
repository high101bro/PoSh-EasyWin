$EventViewerButtonAdd_Click = {
    $InformationTabControl.SelectedTab = $Section3ResultsTab
    #Create-TreeViewCheckBoxArray -Endpoint
    Generate-ComputerList

    if ($ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: Event Viewer" -Question "Connecting Account:  $Username`n`nAttempt to launch the Event Viewer on the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
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
        $InformationTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Event Viewer:  $($script:ComputerTreeViewSelected)")

        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (!$script:Credential) { Create-NewCredentials }

            $ResultsListBox.Items.Add("start-process powershell.exe -ArgumentList '-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected' -Credential <Credential> -WindowStyle Hidden")
            #start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-WindowStyle Hidden -Command Show-eventLog -ComputerName $script:ComputerTreeViewSelected" -Credential $script:Credential -WindowStyle Hidden
            [System.Windows.Forms.MessageBox]::Show("If the Event Viewer doesn't display, try re-launching PoSh-EasyWin itself with domain credentials and wihtout checking 'Specify Credentials'. This method would require the localhost to be on the domain.",'Show-EventLog')
            start-process powershell.exe -ArgumentList "-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected" -Credential $script:Credential -WindowStyle Hidden
        }
        else {
            $ResultsListBox.Items.Add("start-process powershell.exe -ArgumentList '-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected' -WindowStyle Hidden")
            [System.Windows.Forms.MessageBox]::Show("If the Event Viewer doesn't display, try re-launching PoSh-EasyWin itself with domain credentials and wihtout checking 'Specify Credentials'. This method would require the localhost to be on the domain.",'Show-EventLog')
            start-process powershell.exe -ArgumentList "-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected" -WindowStyle Hidden
        }
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "start-process powershell.exe -ArgumentList '-WindowStyle Hidden -Command Show-EventLog -ComputerName $script:ComputerTreeViewSelected' -WindowStyle Hidden"

        if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Generate-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Event Viewer:  Cancelled")
    }
}