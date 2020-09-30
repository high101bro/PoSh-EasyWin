$NetworkConnectionSearchRemoteIPAddressSelectionButtonAdd_Click = {
    Import-Csv "$ComputerTreeNodeFileSave"  | Out-GridView -Title 'PoSh-EasyWin: IP Address Selection' -OutputMode Multiple | Select-Object -Property IPv4Address | Set-Variable -Name IPAddressSelectionContents
    $IPAddressColumn = $IPAddressSelectionContents | Select-Object -ExpandProperty IPv4Address
    $IPAddressToBeScan = ""
    Foreach ($Port in $IPAddressColumn) {
        $IPAddressToBeScan += "$Port`r`n"
    }
    if ($NetworkConnectionSearchRemoteIPAddressRichTextbox.Lines -eq "Enter Remote IPs; One Per Line") { $NetworkConnectionSearchRemoteIPAddressRichTextbox.Text = "" }
    $NetworkConnectionSearchRemoteIPAddressRichTextbox.Text += $("`r`n" + $IPAddressToBeScan)
    $NetworkConnectionSearchRemoteIPAddressRichTextbox.Text  = $NetworkConnectionSearchRemoteIPAddressRichTextbox.Text.Trim("")
}


