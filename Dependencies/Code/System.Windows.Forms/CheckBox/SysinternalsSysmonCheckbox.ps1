$SysinternalsSysmonCheckBoxAdd_Click = {
    Update-QueryCount
    
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Sysinternals - Sysmon")

    # Manages how the checkbox is handeled to ensure that a config is selected if sysmon is checked
    if ($SysinternalsSysmonCheckbox.checked -and $SysinternalsSysmonConfigTextBox.Text -eq "Config:") {
        Select-SysinternalsSysmonXmlConfig
    }
    if ($SysinternalsSysmonConfigTextBox.Text -eq "Config:"){
        $SysinternalsSysmonCheckbox.checked = $false
    }

    Update-TreeViewData -Commands -TreeView $script:CommandsTreeView.Nodes
}

$SysinternalsSysmonCheckboxAdd_MouseHover = {
    Show-ToolTip -Title "Sysinternals - Sysmon" -Icon "Info" -Message @"
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



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUezr5IFXK9hfVsSSSYcxiTA+o
# 9xqgggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTIxNDA1MDIwMFoXDTMxMTIxNDA1MTIwMFowMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALvIxUDFEVGB/G0FXPryoNlF
# dA65j5jPEFM2R4468rjlTVsNYUOR+XvhjmhpggSQa6SzvXtklUJIJ6LgVUpt/0C1
# zlr1pRwTvsd3svI7FHTbJahijICjCv8u+bFcAR2hH3oHFZTqvzWD1yG9FGCw2pq3
# h4ahxtYBd1+/n+jOtPUoMzcKIOXCUe4Cay+xP8k0/OLIVvKYRlMY4B9hvTW2CK7N
# fPnvFpNFeGgZKPRLESlaWncbtEBkexmnWuferJsRtjqC75uNYuTimLDSXvNps3dJ
# wkIvKS1NcxfTqQArX3Sg5qKX+ZR21uugKXLUyMqXmVo2VEyYJLAAAITEBDM8ngUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBSDJIlo6BcZ7KJAW5hoB/aaTLxFzTANBgkqhkiG9w0BAQUFAAOCAQEA
# ouCzal7zPn9vc/C9uq7IDNb1oNbWbVlGJELLQQYdfBE9NWmXi7RfYNd8mdCLt9kF
# CBP/ZjHKianHeZiYay1Tj+4H541iUN9bPZ/EaEIup8nTzPbJcmDbaAGaFt2PFG4U
# 3YwiiFgxFlyGzrp//sVnOdtEtiOsS7uK9NexZ3eEQfb/Cd9HRikeUG8ZR5VoQ/kH
# 2t2+tYoCP4HsyOkEeSQbnxlO9s1jlSNvqv4aygv0L6l7zufiKcuG7q4xv/5OvZ+d
# TcY0W3MVlrrNp1T2wxzl3Q6DgI+zuaaA1w4ZGHyxP8PLr6lMi6hIugI1BSYVfk8h
# 7KAaul5m+zUTDBUyNd91ojGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQeugH5LewQKBKT6dP
# XhQ7sDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUI2F+O75FhRwV454rRzXenwlu8fkwDQYJKoZI
# hvcNAQEBBQAEggEAXzSCwW6a19PImrcc7C2U2OXSGcNEUnEP/DtuVH4AgMhmOBKC
# 7T+IQUVdfZa9dpUs4sWvAUNOzjDzwhI3dt06leqmnJFSn9c+qs82G0SrR3Ml+TkN
# jbhQXhpMl26a3OWLlFnnfUgJxP6ytbOaqdhGHpfP4CSsbTOy5OJe9DAUmIJF4HYw
# dffmhYV8QZbW8t2zQMMC30fWWialPZnJ6WndRoxZn19A9j6y8tHPEDjGZ0GzAh6W
# L2Aa+dZd90LJad6r+qlCkbYUbUBJxggu/LzckLaIzcA/GtVq5nAjMDgUzHk0cs6n
# dSNel/rPSEJ8Z7pXsvS1SRcQDRRPPQ79Y1u2ZQ==
# SIG # End signature block
