$ComputerListWinRMCheckToolStripButtonAdd_Click = {
    Create-ComputerNodeCheckBoxArray

    if ($ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerTreeViewSelected.count -lt 1){
        [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','WinRM Check')
    }
    else {
        if (Verify-Action -Title "Verification: WinRM Check" -Question "Connecting Account:  $Username`n`nConduct a WinRM Check to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
            Check-Connection -CheckType "WinRM Check" -MessageTrue "Able to Verify WinRM" -MessageFalse "Unable to Verify WinRM"
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("WinRM Check:  Cancelled")
        }
    }
}


<#
$ComputerListWinRMCheckToolStripButtonAdd_MouseHover = {
    Show-ToolTip -Title "WinRM Check" -Icon "Info" -Message @"
+  Unresponsive hosts can be removed from being nodes checked.
+  Command:
    Test-WSman -ComputerName <target>
+  Command  Alternative (Sends Ping First):
    Test-NetConnection CommonTCPPort WINRM -ComputerName <target>
"@
}
#>


