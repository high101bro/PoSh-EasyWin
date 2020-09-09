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
