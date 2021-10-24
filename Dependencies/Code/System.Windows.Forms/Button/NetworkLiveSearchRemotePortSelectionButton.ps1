$NetworkLiveSearchRemotePortSelectionButtonAdd_Click = {
    Import-Csv "$Dependencies\Ports, Protocols, and Services.csv" | Out-GridView -Title 'PoSh-EasyWin: Port Selection' -OutputMode Multiple | Select-Object -Property Port | Set-Variable -Name PortManualEntrySelectionContents
    $PortsColumn = $PortManualEntrySelectionContents | Select-Object -ExpandProperty Port
    $PortsToBeScan = ""
    Foreach ($Port in $PortsColumn) {
        $PortsToBeScan += "$Port`r`n"
    }
    if ($NetworkLiveSearchRemotePortRichTextbox.Lines -eq "Enter Remote Ports; One Per Line") { $NetworkLiveSearchRemotePortRichTextbox.Text = "" }
    $NetworkLiveSearchRemotePortRichTextbox.Text += $("`r`n" + $PortsToBeScan)
    $NetworkLiveSearchRemotePortRichTextbox.Text  = $NetworkLiveSearchRemotePortRichTextbox.Text.Trim("")
}


