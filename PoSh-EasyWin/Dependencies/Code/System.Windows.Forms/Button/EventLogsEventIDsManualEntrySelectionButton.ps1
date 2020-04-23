$EventLogsEventIDsManualEntrySelectionButtonAdd_Click = {
    Import-Csv $EventIDsFile | Out-GridView  -Title 'Windows Event IDs' -OutputMode Multiple | Set-Variable -Name EventCodeManualEntrySelectionContents
    $EventIDColumn = $EventCodeManualEntrySelectionContents | Select-Object -ExpandProperty "Event ID"
    Foreach ($EventID in $EventIDColumn) {
        $EventLogsEventIDsManualEntryTextbox.Text += "$EventID`r`n"
    }
}
