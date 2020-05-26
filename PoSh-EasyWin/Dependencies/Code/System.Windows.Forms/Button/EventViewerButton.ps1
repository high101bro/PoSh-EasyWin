$EventViewerButtonAdd_Click = {
    Create-ComputerNodeCheckBoxArray
    function Launch-EventViewer {
        if ($script:ComputerTreeViewSelected.count -gt 0) {
            if (Verify-Action -Title "Verification: Event Viewer" -Question "Open the Event Viewer to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                # This brings specific tabs to the forefront/front view
                $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Show Event Viewer:  $($script:ComputerTreeViewSelected)")
                $ResultsListBox.Items.Clear()

                if ($ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Create-NewCredentials }
                }
                # Note: Show-EventLog doesn't support -Credential, nor will it spawn a local GUI if used witn invoke-command/enter-pssession for a remote host with credentials provided
                Foreach ($TargetComputer in $($script:ComputerTreeViewSelected | Select-Object -Unique)){ 
                    
                    if ($ComputerListProvideCredentialsCheckBox.Checked) {
                        Invoke-Command -Command { 
                            param(
                                $TargetComputer,
                                $script:Credential
                            )
                            Start-Process PowerShell.exe -Credential $script:Credential -WindowStyle Hidden "-WindowStyle Hidden -Command Show-EventLog -ComputerName $TargetComputer" 
                        } -ArgumentList @($TargetComputer,$script:Credential)
                        $ResultsListBox.Items.Add("Show-EventLog -ComputerName $script:ComputerTreeViewSelected")
                        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Show-EventLog -ComputerName $($script:ComputerTreeViewSelected)"
                    }
                    else{
                        Show-EventLog -ComputerName $TargetComputer 
                        $ResultsListBox.Items.Add("Show-EventLog -ComputerName $script:ComputerTreeViewSelected")
                        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Show-EventLog -ComputerName $($script:ComputerTreeViewSelected)"
                    }
                }
            }
            else {
                [system.media.systemsounds]::Exclamation.play()
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Event Viewer:  Cancelled")
            }    
        }
        elseif ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Show Event Viewer' }
        elseif ($script:ComputerTreeViewSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Show Event Viewer' }
    }

    #if ($ComputerListProvideCredentialsCheckBox.checked) {
    #    if ((Verify-Action -Title "Verification: Credential Warning" -Question "Warning!`nEvent Viewer does not support providing alternate credentials.`nDo you want to continue?" -Computer '')) {
    #        Launch-EventViewer
    #    }
    #}
    #else {Launch-EventViewer}
    Launch-EventViewer
}

$EventViewerButtonAdd_MouseHover = {
    Show-ToolTip -Title "Event Viewer" -Icon "Info" -Message @"
+  Will attempt to show the Event Viewer for a single host.
+  NOT compatiable with 'Specify Credentials'
+  Uses RPC/DCOM, not WinRM
+  Command:
        Show-EventLog -ComputerName <Hostname>
"@ 
}
