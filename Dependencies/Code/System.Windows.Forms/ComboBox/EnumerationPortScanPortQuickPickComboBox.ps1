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
# 4w6gggM6MIIDNjCCAh6gAwIBAgIQeugH5LewQKBKT6dPXhQ7sDANBgkqhkiG9w0B
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
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUqv4FjXoK+VxZa+U4RxPUPBgFbRkwDQYJKoZI
# hvcNAQEBBQAEggEArsL+00MctzycZxmg0r5hLzI3v1MQ07Ht1udMmph4UpGdMV+9
# /ReGZBND4Dx1LcfnWfkLLokWnOmwlOFBby4af9eu64Fcjfo96kBms3QjPrpluZaD
# VFQ9wiBXg5x3SOTcZ5jWmI9gKFQ+q/1ws96LQSkOzt7vkIXdG0//1afBDvKJ4cRl
# XVqhw1TZG4FofvbXw8h9e+EW+Siy8eitaCY054en4yqAYDJ4Sr1q4C0uKrNGyNfj
# jx08dB8zbHKB4uHpYBxbDdCTCsDB1Sor7qMRjrT2KeuLFCWtE0ktsO/fyjmzhccu
# FWZmU9P95o80F6PXRiXEyl/x/X0c5XFtuf2T7g==
# SIG # End signature block
