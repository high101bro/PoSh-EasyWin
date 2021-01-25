$NetworkConnectionSearchLocalPortSelectionButtonAdd_Click = {
    Import-Csv "$Dependencies\Ports, Protocols, and Services.csv" | Out-GridView -Title 'PoSh-EasyWin: Port Selection' -OutputMode Multiple | Select-Object -Property Port | Set-Variable -Name PortManualEntrySelectionContents
    $PortsColumn = $PortManualEntrySelectionContents | Select-Object -ExpandProperty Port
    $PortsToBeScan = ""
    Foreach ($Port in $PortsColumn) {
        $PortsToBeScan += "$Port`r`n"
    }
    if ($NetworkConnectionSearchLocalPortRichTextbox.Lines -eq "Enter Local Ports; One Per Line") { $NetworkConnectionSearchLocalPortRichTextbox.Text = "" }
    $NetworkConnectionSearchLocalPortRichTextbox.Text += $("`r`n" + $PortsToBeScan)
    $NetworkConnectionSearchLocalPortRichTextbox.Text  = $NetworkConnectionSearchLocalPortRichTextbox.Text.Trim("")
}


