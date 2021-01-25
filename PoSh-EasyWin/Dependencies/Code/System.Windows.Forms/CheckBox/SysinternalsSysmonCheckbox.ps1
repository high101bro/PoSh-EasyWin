$SysinternalsSysmonCheckBoxAdd_Click = {
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Sysinternals - Sysmon")

    # Manages how the checkbox is handeled to ensure that a config is selected if sysmon is checked
    if ($SysinternalsSysmonCheckbox.checked -and $SysinternalsSysmonConfigTextBox.Text -eq "Config:") {
        Select-SysinternalsSysmonXmlConfig
    }
    if ($SysinternalsSysmonConfigTextBox.Text -eq "Config:"){
        $SysinternalsSysmonCheckbox.checked = $false
    }

    Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
}

$SysinternalsSysmonCheckboxAdd_MouseHover = {
    Show-ToolTip -Title "Sysinternals - Autoruns" -Icon "Info" -Message @"
+  System Monitor (Sysmon) is a Windows system service and device driver that, once installed on a system, remains resident
     across system reboots to monitor and log system activity to the Windows event log. It provides detailed information
     about process creations, network connections, and changes to file creation time. By collecting the events it generates
     using Windows Event Collection or SIEM agents and subsequently analyzing them, you can identify malicious or anomalous
     activity and understand how intruders and malware operate on your network.

+  Note that Sysmon does not provide analysis of the events it generates, nor does it attempt to protect or hide itself
     from attackers.

+  Sysmon includes the following capabilities:
    - Logs process creation with full command line for both current and parent processes.
    - Records the hash of process image files using SHA1 (the default), MD5, SHA256 or IMPHASH.
    - Multiple hashes can be used at the same time.
    - Includes a process GUID in process create events to allow for correlation of events even when Windows reuses process IDs.
    - Include a session GUID in each events to allow correlation of events on same logon session.
    - Logs loading of drivers or DLLs with their signatures and hashes.
    - Logs opens for raw read access of disks and volumes
    - Optionally logs network connections, including each connection’s source process, IP addresses, port numbers, hostnames
      and port names.
    - Detects changes in file creation time to understand when a file was really created. Modification of file create timestamps
      is a technique commonly used by malware to cover its tracks.
    - Automatically reload configuration if changed in the registry.
    - Rule filtering to include or exclude certain events dynamically.
    - Generates events from early in the boot process to capture activity made by even sophisticated kernel-mode malware.

+  https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
"@
}


