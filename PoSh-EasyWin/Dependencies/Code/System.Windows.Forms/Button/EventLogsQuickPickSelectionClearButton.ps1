$EventLogsQuickPickSelectionClearButtonAdd_Click = {
    # Clears the commands selected
    For ($i=0;$i -lt $EventLogsQuickPickSelectionCheckedlistbox.Items.count;$i++) {
        $EventLogsQuickPickSelectionCheckedlistbox.SetSelected($i,$False)
        $EventLogsQuickPickSelectionCheckedlistbox.SetItemChecked($i,$False)
        $EventLogsQuickPickSelectionCheckedlistbox.SetItemCheckState($i,$False)
    }    
}
