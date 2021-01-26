$ComputerListPingToolStripButtonAdd_Click = {
    Create-ComputerNodeCheckBoxArray

    if ($script:ComputerTreeViewSelected.count -eq 0){
        [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Ping')
    }
    else {
        if (Verify-Action -Title "Verification: Ping Test" -Question "Conduct a Ping test to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
            Check-Connection -CheckType "Ping" -MessageTrue "Able to Ping" -MessageFalse "Unable to Ping"
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Ping:  Cancelled")
        }
}
}
<#
$ComputerListPingToolStripButtonAdd_MouseHover = {
    Show-ToolTip -Title "Ping Check" -Icon "Info" -Message @"
+  Unresponsive hosts can be removed from being nodes checked.
+  Command:
    Test-Connection -Count 1 -ComputerName <target>
+  Command Alternative (legacy):
    ping -n1 <target>
"@
}
#>


