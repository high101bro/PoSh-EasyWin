$EventViewerButtonAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    #Create-ComputerNodeCheckBoxArray
    Generate-ComputerList

    function Launch-EventViewer {
        if ($script:ComputerList.count -gt 0) {
            if (Verify-Action -Title "Verification: Event Viewer" -Question "Open the Event Viewer to the following?" -Computer $($script:ComputerList -join ', ')) {
                # This brings specific tabs to the forefront/front view
                $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Show Event Viewer:  $($script:ComputerList)")
                #Removed For Testing#$ResultsListBox.Items.Clear()

                if ($ComputerListProvideCredentialsCheckBox.Checked) {
                    if (!$script:Credential) { Create-NewCredentials }
                }
                # Note: Show-EventLog doesn't support -Credential, nor will it spawn a local GUI if used witn invoke-command/enter-pssession for a remote host with credentials provided
                Foreach ($TargetComputer in $($script:ComputerList | Select-Object -Unique)){ 
                    if ($ComputerListProvideCredentialsCheckBox.Checked) {
                        Invoke-Command -Command { 
                            param(
                                $TargetComputer,
                                $script:Credential
                            )
                            if (Test-Path 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe'){
                                [System.Windows.Forms.MessageBox]::Show("If the Event Viewer doesn't display, try re-launching PoSh-EasyWin itself with elevated credentials and wihtout checking 'Specify Credentials'.",'Show-EvengLog')
                                start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-WindowStyle Hidden -Command Show-eventLog -ComputerName $TargetComputer" -Credential $script:Credential -WindowStyle Hidden
                            }
                            else {
                                start-process powershell.exe -ArgumentList "-WindowStyle Hidden -Command Show-EventLog -ComputerName $TargetComputer" -Credential $script:Credential -WindowStyle Hidden
                            }
                        } -ArgumentList @($TargetComputer,$script:Credential)
                        $ResultsListBox.Items.Add("Show-EventLog -ComputerName $script:ComputerList")
                        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Show-EventLog -ComputerName $($script:ComputerList)"
                    }
                    else{
                        Show-EventLog -ComputerName $TargetComputer 
                        $ResultsListBox.Items.Add("Show-EventLog -ComputerName $script:ComputerList")
                        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Show-EventLog -ComputerName $($script:ComputerList)"
                    }
                }
            }
            else {
                [system.media.systemsounds]::Exclamation.play()
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Event Viewer:  Cancelled")
            }    
        }
        elseif ($script:ComputerList.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Show Event Viewer' }
        elseif ($script:ComputerList.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Show Event Viewer' }
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
