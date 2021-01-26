$EventLogsEventIDsToMonitorClearButtonAdd_Click = {
    # Clears the commands selected
    For ($i=0;$i -lt $EventLogsEventIDsToMonitorChecklistbox.Items.count;$i++) {
        $EventLogsEventIDsToMonitorChecklistbox.SetSelected($i,$False)
        $EventLogsEventIDsToMonitorChecklistbox.SetItemChecked($i,$False)
        $EventLogsEventIDsToMonitorChecklistbox.SetItemCheckState($i,$False)
    }
}


