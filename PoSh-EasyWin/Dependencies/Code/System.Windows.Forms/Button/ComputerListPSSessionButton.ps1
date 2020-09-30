$ComputerListPSSessionButtonAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    Create-ComputerNodeCheckBoxArray
    Generate-ComputerList

    if ($ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerListEndpointNameToolStripLabel.text) {
        $VerifyAction = Verify-Action -Title "Verification: PowerShell Session" -Question "Connecting Account:  $Username`n`nEnter a PowerShell Session to the following?" -Computer $($script:ComputerListEndpointNameToolStripLabel.text)
        $script:ComputerTreeViewSelected = $script:ComputerListEndpointNameToolStripLabel.text
    }
    elseif (-not $script:ComputerListEndpointNameToolStripLabel.text) {
        [System.Windows.Forms.Messagebox]::Show('Left click an endpoint node to select it, then right click to access the context menu and select PSSession.','PowerShell Session')
    }

    if ($VerifyAction) {
        # This brings specific tabs to the forefront/front view
        $MainBottomTabControl.SelectedTab = $Section3ResultsTab

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Enter-PSSession:  $($script:ComputerTreeViewSelected)")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        if ($ComputerListProvideCredentialsCheckBox.Checked) {
            if (-not $script:Credential) { Create-NewCredentials }
            Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Credentials Used: $($script:Credential.UserName)"
            $Username = $script:Credential.UserName
            $Password = $script:Credential.GetNetworkCredential().Password

            $password = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Password))
            #if ($UserName -like '*\*') {
            #    $Name     = $UserName.split('\')[1]
            #    $Domain   = $UserName.split('\')[0]
            #    $UserName = "$Name@$Domain"
            #}

            $ResultsListBox.Items.Add("Enter-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential $script:Credential")
            #start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-noexit -Command Enter-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential `$(New-Object PSCredential('$Username'`,`$('$Password' | ConvertTo-SecureString -AsPlainText -Force)))"
            start-process -FilePath 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -ArgumentList "-noexit -Command Enter-PSSession -ComputerName $script:ComputerTreeViewSelected -Credential `$(New-Object PSCredential('$Username'`,`$([System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('$Password')) | ConvertTo-SecureString -AsPlainText -Force)))"

            Start-Sleep -Seconds 3
        }
        else {
            $ResultsListBox.Items.Add("Enter-PSSession -ComputerName $script:ComputerTreeViewSelected")
            Start-Process PowerShell -ArgumentList "-noexit Enter-PSSession -ComputerName $script:ComputerTreeViewSelected"
            Start-Sleep -Seconds 3
        }
        Create-LogEntry -LogFile $LogFile -NoTargetComputer -Message "Enter-PSSession -ComputerName $($script:ComputerTreeViewSelected)"

        if ($script:RollCredentialsState -and $ComputerListProvideCredentialsCheckBox.checked) {
            Start-Sleep -Seconds 3
            Generate-NewRollingPassword
        }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("PowerShell Session:  Cancelled")
    }
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


