$EnumerationPortScanPortQuickPickComboBoxItemsAddRange =@(
    "N/A"
    "Nmap Top 100 Ports"
    "Nmap Top 1000 Ports"
    "Well-Known Ports (0-1023)"
    "Registered Ports (1024-49151)"
    "Dynamic Ports (49152-65535)"
    "All Ports (0-65535)"
    "Previous Scan - Parses LogFile.txt"
    "File: CustomPortsToScan.txt"
)

$EnumerationPortScanPortQuickPickComboBoxAdd_Click = {
    #Removed For Testing#$ResultsListBox.Items.Clear()
    if ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "N/A") { $ResultsListBox.Items.Add("") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Nmap Top 100 Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan the top 100 ports as reported by nmap on each target.") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Nmap Top 1000 Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan the top 1000 ports as reported by nmap on each target.") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Well-Known Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan all Well-Known Ports on each target [0-1023].") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Registered Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan all Registered Ports on each target [1024-49151].") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Dynamic Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan all Dynamic Ports, AKA Ephemeral Ports, on each target [49152-65535].") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "All Ports") { $ResultsListBox.Items.Add("Will conduct a connect scan all 65535 ports on each target.") }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "Previous Scan") {
        $LastPortsScanned = $((Get-Content $LogFile | Select-String -Pattern "Ports To Be Scanned" | Select-Object -Last 1) -split '  ')[2]
        $LastPortsScannedConvertedToList = @()
        Foreach ($Port in $(($LastPortsScanned) -split',')){ $LastPortsScannedConvertedToList += $Port }
        $ResultsListBox.Items.Add("Will conduct a connect scan on ports listed below.")
        $ResultsListBox.Items.Add("Previous Ports Scanned:  $($LastPortsScannedConvertedToList | Where {$_ -ne ''})")
    }
    elseif ($EnumerationPortScanPortQuickPickComboBox.SelectedItem -match "CustomPortsToScan") {
        $CustomSavedPorts = $($PortList="";(Get-Content $CustomPortsToScan | foreach {$PortList += $_ + ','}); $PortList)
        $CustomSavedPortsConvertedToList = @()
        Foreach ($Port in $(($CustomSavedPorts) -split',')){ $CustomSavedPortsConvertedToList += $Port }
        $ResultsListBox.Items.Add("Will conduct a connect scan on ports listed below.")
        $ResultsListBox.Items.Add("Previous Ports Scanned:  $($CustomSavedPortsConvertedToList | Where {$_ -ne ''})")
    }
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyvr43csUQDVN9spH3rPY2uy9
# 4w6gggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUqv4FjXoK+VxZa+U4RxPUPBgFbRkwDQYJKoZI
# hvcNAQEBBQAEggEAojej14pTEJkn7doNOgfL0+O0JTVmb/CMe1IywzbtOdkIU6ka
# Guq0RiMkeW8StCJYMmeY2be/ianwL7w5j8nA/awWaZasQaDA6m61KdbSDmyMoX2U
# PUum6+oXwPYIg0skPXvYnlqCyPc9k2zncvEqtEiGr2P32xMl/MF68aRLwWfCmVqE
# E2nCFoT4kKKDymwTWViDzZ/tIcJVoXDL0/YVJRc1z5ImLqdnnJ7ft+kbI0dM43tS
# UAwIZshzasd2gAMti5vZ7JGMF3YbCqCfvDWU+2raXztzVEmCoJqPTk8yeTWo5nBH
# cpDCaTjGOt/SZDn1pJkSkwB6DNkEl6XR/B0XIw==
# SIG # End signature block
