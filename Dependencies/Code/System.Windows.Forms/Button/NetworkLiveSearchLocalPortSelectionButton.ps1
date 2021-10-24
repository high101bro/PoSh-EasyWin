$NetworkLiveSearchLocalPortSelectionButtonAdd_Click = {
    Import-Csv "$Dependencies\Ports, Protocols, and Services.csv" | Out-GridView -Title 'PoSh-EasyWin: Port Selection' -OutputMode Multiple | Select-Object -Property Port | Set-Variable -Name PortManualEntrySelectionContents
    $PortsColumn = $PortManualEntrySelectionContents | Select-Object -ExpandProperty Port
    $PortsToBeScan = ""
    Foreach ($Port in $PortsColumn) {
        $PortsToBeScan += "$Port`r`n"
    }
    if ($NetworkLiveSearchLocalPortRichTextbox.Lines -eq "Enter Local Ports; One Per Line") { $NetworkLiveSearchLocalPortRichTextbox.Text = "" }
    $NetworkLiveSearchLocalPortRichTextbox.Text += $("`r`n" + $PortsToBeScan)
    $NetworkLiveSearchLocalPortRichTextbox.Text  = $NetworkLiveSearchLocalPortRichTextbox.Text.Trim("")
}


