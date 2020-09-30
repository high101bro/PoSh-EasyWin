$EnumerationPortScanPortsSelectionButtonAdd_Click = {
    Import-Csv "$Dependencies\Ports, Protocols, and Services.csv" | Out-GridView -Title 'PoSh-EasyWin: Port Selection' -OutputMode Multiple | Set-Variable -Name PortManualEntrySelectionContents
    $PortsColumn = $PortManualEntrySelectionContents | Select-Object -ExpandProperty "Port"
    $PortsToBeScan = ""
    Foreach ($Port in $PortsColumn) { $PortsToBeScan += "$Port," }
    $EnumerationPortScanSpecificPortsTextbox.Text += $("," + $PortsToBeScan)
    $EnumerationPortScanSpecificPortsTextbox.Text = $EnumerationPortScanSpecificPortsTextbox.Text.Trim(",")
}


