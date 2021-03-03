$ComputerListSMBCheckToolStripButtonAdd_Click = {
    Create-ComputerNodeCheckBoxArray

    if ($ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
    else {$Username = $PoShEasyWinAccountLaunch }

    if ($script:ComputerTreeViewSelected.count -eq 0){
        [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','SMB Port Check')
    }
    else {
        if (Verify-Action -Title "Verification: SMB Port Check" -Question "Connecting Account:  $Username`n`nConduct a SMB Port Check to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
            Check-Connection -CheckType "SMB Port Check" -MessageTrue "SMB Port 445 is Open" -MessageFalse "SMB Port 445 is Closed"
        }
        else {
            [system.media.systemsounds]::Exclamation.play()
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("SMB Port Check:  Cancelled")
        }
    }
}

<#
$ComputerListSMBCheckToolStripButtonAdd_MouseHover = {
    Show-ToolTip -Title "SMB Port Check" -Icon "Info" -Message @"
+  Unresponsive hosts can be removed from being nodes checked.
+  Command:
    function Test-Port {
        param ($ComputerName, $Port)
        begin { $tcp = New-Object Net.Sockets.TcpClient }
        process {
            try { $tcp.Connect($ComputerName, $Port) } catch {}
            if ($tcp.Connected) { $tcp.Close(); $open = $true }
            else { $open = $false }
            [PSCustomObject]@{ IP = $ComputerName; Port = $Port; Open = $open }
        }
    }
    $CheckCommand = Test-Port -ComputerName $target -Port 445 | Select-Object -ExpandProperty Open
+  Command Alternative (Sends Ping First):
    Test-NetConnection -Port 445 -ComputerName <target>`n`n
"@
}
#>


