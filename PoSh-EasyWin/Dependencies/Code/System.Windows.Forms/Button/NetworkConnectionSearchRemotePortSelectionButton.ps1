$NetworkConnectionSearchRemotePortSelectionButtonAdd_Click = {
    Import-Csv "$Dependencies\Ports, Protocols, and Services.csv" | Out-GridView -Title 'PoSh-EasyWin: Port Selection' -OutputMode Multiple | Select-Object -Property Port | Set-Variable -Name PortManualEntrySelectionContents
    $PortsColumn = $PortManualEntrySelectionContents | Select-Object -ExpandProperty Port
    $PortsToBeScan = ""
    Foreach ($Port in $PortsColumn) {
        $PortsToBeScan += "$Port`r`n"
    }
    if ($NetworkConnectionSearchRemotePortRichTextbox.Lines -eq "Enter Remote Ports; One Per Line") { $NetworkConnectionSearchRemotePortRichTextbox.Text = "" }
    $NetworkConnectionSearchRemotePortRichTextbox.Text += $("`r`n" + $PortsToBeScan)
    $NetworkConnectionSearchRemotePortRichTextbox.Text  = $NetworkConnectionSearchRemotePortRichTextbox.Text.Trim("")
}


