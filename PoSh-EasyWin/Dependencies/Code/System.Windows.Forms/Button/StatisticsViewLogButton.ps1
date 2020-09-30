$StatisticsViewLogButtonAdd_Click = {
    write.exe $LogFile
}

$StatisticsViewLogButtonAdd_MouseHover = {
    Show-ToolTip -Title "View Activity Log File" -Icon "Info" -Message @"
+  Opens the PoSh-EasyWin activity log file.
+  All activities are logged, to inlcude:
    The launch of PoSh-EasyWin and the assosciated account/privileges.
    Each queries executed against each host.
    Network enumeration scannning for hosts: IPs and Ports.
    Connectivity checks: Ping, WinRM, & RPC.
    Remote access to hosts, but not commands executed within.
"@
}


