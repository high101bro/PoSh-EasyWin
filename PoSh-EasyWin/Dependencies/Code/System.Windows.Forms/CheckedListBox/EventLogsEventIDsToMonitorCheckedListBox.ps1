$EventLogsEventIDsToMonitorCheckedListBoxAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    $EventID = $($script:EventLogSeverityQueries | Where {$_.EventID -eq $($($EventLogsEventIDsToMonitorCheckListBox.SelectedItem) -split " ")[0]})
    $Display = @(
        "====================================================================================================",
        "Current Event ID:  $($EventID.EventID)",
        "Legacy Event ID:   $($EventID.LegacyEventID)",
        "===================================================================================================="
        "$($EventID.Message)",
        "Ref: $($EventID.Reference)",
        "===================================================================================================="
        )
    # Adds the data from PSObject
    $ResultsListBox.Items.Clear()

    foreach ($item in $Display) {
        $ResultsListBox.Items.Add($item)
    }
    # Adds the notes
    foreach ($line in $($EventID.Notes -split "`r`n")) {
        $ResultsListBox.Items.Add($line)
    }
}


