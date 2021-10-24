$NetworkLiveSearchRemoteIPAddressSelectionButtonAdd_Click = {
    Import-Csv "$script:EndpointTreeNodeFileSave"  | Out-GridView -Title 'PoSh-EasyWin: IP Address Selection' -OutputMode Multiple | Select-Object -Property IPv4Address | Set-Variable -Name IPAddressSelectionContents
    $IPAddressColumn = $IPAddressSelectionContents | Select-Object -ExpandProperty IPv4Address
    $IPAddressToBeScan = ""
    Foreach ($Port in $IPAddressColumn) {
        $IPAddressToBeScan += "$Port`r`n"
    }
    if ($NetworkLiveSearchRemoteIPAddressRichTextbox.Lines -eq "Enter Remote IPs; One Per Line") { $NetworkLiveSearchRemoteIPAddressRichTextbox.Text = "" }
    $NetworkLiveSearchRemoteIPAddressRichTextbox.Text += $("`r`n" + $IPAddressToBeScan)
    $NetworkLiveSearchRemoteIPAddressRichTextbox.Text  = $NetworkLiveSearchRemoteIPAddressRichTextbox.Text.Trim("")
}


