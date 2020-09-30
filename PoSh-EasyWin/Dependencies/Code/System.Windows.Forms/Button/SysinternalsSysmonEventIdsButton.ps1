$SysinternalsSysmonEventIdsButtonAdd_Click = {
    $EventCodeManualEntrySelectionContents = $null
    Import-Csv  "$Dependencies\Sysmon Config Files\Sysmon Event IDs.csv" | Out-GridView -Title 'Sysmon Event IDs' -OutputMode Multiple | Set-Variable -Name EventCodeManualEntrySelectionContents
    $EventIDColumn = $EventCodeManualEntrySelectionContents | Select-Object -ExpandProperty "Event ID"
    Foreach ($EventID in $EventIDColumn) {
        $EventLogsEventIDsManualEntryTextbox.Text += "$EventID`r`n"
    }

    if ($EventCodeManualEntrySelectionContents){
        $MainLeftCollectionsTabControl.SelectedTab = $Section1EventLogsTab
    }
}

$SysinternalsSysmonEventIdsButtonAdd_MouseHover = {
    Show-ToolTip -Title "Sysmon Event ID List" -Icon "Info" -Message @"
+  Shows a list of Sysmon specific event IDs
+  These Event IDs will only be generated on endpoints that have Sysmon installed
+  https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon
"@
}


