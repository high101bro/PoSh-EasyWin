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
# 9xqgggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUI2F+O75FhRwV454rRzXenwlu8fkwDQYJKoZI
# hvcNAQEBBQAEggEAhey0tnpsyh9ZgucgBtZ2hqdnwvmewhTppepE+wN6dqnEgG0x
# j1xobE56Sedcowk36qZsLdrtGx+plhv/B3W8qxt/ttWOsHEffhjDEsRf315k3Kxl
# RV8cCjWEqjbE3oRQzW2BxX1WNxMWhcwJS6CE9oWekGhWqgGiorjPA/1mH11XmyMf
# Xy4PqTKcIp7FIHvKz41lvWgU+k93cJhKfOFyqsevER755pJY8UZQeuALBloz2HBI
# TTUsUx4LKfDwEVYttJ8H6SJ2kim8DHazqe1kzAqfhwD2FabXI+7fVLXTLQ24yzZS
# JaN1tKQFL5QWEURPGvAYm3qpUtnTKhU6+WGNsg==
# SIG # End signature block
