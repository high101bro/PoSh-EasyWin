$ComputerListRDPButtonAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    Create-ComputerNodeCheckBoxArray
    Generate-ComputerList

    if ($script:ComputerTreeViewSelected.count -eq 1 -or $script:ComputerListEndpointNameToolStripLabel.text -in $script:ComputerList) {
        if ($script:ComputerListEndpointNameToolStripLabel.text -in $script:ComputerList) {
            $VerifyRDP = Verify-Action -Title "Verification: Remote Desktop" -Question "Open a Remote Desktop session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
            $script:ComputerTreeViewSelected = $script:ComputerListEndpointNameToolStripLabel.text
        }
        else {
            $VerifyRDP = Verify-Action -Title "Verification: Remote Desktop" -Question "Open a Remote Desktop session to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')
        }
        if ($VerifyRDP) {
            # This brings specific tabs to the forefront/front view
            $MainBottomTabControl.SelectedTab = $Section3ResultsTab
            if ($ComputerListProvideCredentialsCheckBox.Checked) { 
                
                # Selects between which credentials to use: 1) The selected credentials, 2) The Rolling Account credentials, 3) the credentials used that launched PoSh-EasyWin
                if ($script:CredentialManagementPasswordRollingAccountCheckbox.checked) {

                    # Extracts the username and password from the credential object to be used by cmdkey to pass along to mstsc
                    $Username = $null
                    $Password = $null

                    $Username = $script:credential.UserName
                    $Password = $script:credential.GetNetworkCredential().Password
                    cmdkey /delete:"$script:ComputerTreeViewSelected"
                    cmdkey /delete /ras               


                    cmdkey /generic:"$script:ComputerTreeViewSelected" /user:"$Username" /pass:"$Password"
                    mstsc /v:$($script:ComputerTreeViewSelected):3389 /NoConsentPrompt

                    # There seems to be a delay between the credential passing before credentials can be removed locally from cmdkey and them still being needed
                    Start-Sleep -Seconds 5
                    cmdkey /delete /ras               
                    cmdkey /delete:"$script:ComputerTreeViewSelected"

                    #Start-Process PowerShell -WindowStyle Hidden -ArgumentList "cmdkey /add:$script:ComputerTreeViewSelected /user:$Username /pass:$Password; Start-Process mstsc -ArgumentList '/v:$($script:ComputerTreeViewSelected):3389'"        
                    if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) { Generate-NewRollingPassword }
                }
                else {
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
                    mstsc /v:$($script:ComputerTreeViewSelected):3389 /NoConsentPrompt
                    #Start-Sleep -Seconds 1
                    #cmdkey /delete:$script:ComputerTreeViewSelected 
                    
                    if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) { Generate-NewRollingPassword }
                }
            }
            else {
                cmdkey /delete:"$script:ComputerTreeViewSelected"
                cmdkey /delete /ras               

                mstsc /v:$($script:ComputerTreeViewSelected):3389 /NoConsentPrompt
            }
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Remote Desktop:  $($script:ComputerTreeViewSelected)")
            #Removed For Testing#$ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("mstsc /v:$($script:ComputerTreeViewSelected):3389 /NoConsentPrompt")
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
        mstsc /v:<target>:3389 /NoConsentPrompt
        mstsc /v:<target>:3389 /user:USERNAME /pass:PASSWORD /NoConsentPrompt
+  Compatiable with 'Specify Credentials' if permitted by network policy
"@ 
}
