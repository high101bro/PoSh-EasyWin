$ComputerListRPCCheckButtonAdd_Click = {
    Create-ComputerNodeCheckBoxArray
    if (Verify-Action -Title "Verification: RPC Check" -Question "Conduct a RPC Check to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
        Check-Connection -CheckType "RPC Check" -MessageTrue "RPC Port 135 is Open" -MessageFalse "RPC Port 135 is Closed"
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("RPC Check:  Cancelled")
    }
}

$ComputerListRPCCheckButtonAdd_MouseHover = {
    Show-ToolTip -Title "RPC Check" -Icon "Info" -Message @"
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
    $CheckCommand = Test-Port -ComputerName $target -Port 135 | Select-Object -ExpandProperty Open
+  Command Alternative (Sends Ping First):
    Test-NetConnection -Port 135 -ComputerName <target>`n`n
"@
}
