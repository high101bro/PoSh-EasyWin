$EventLogsStartTimePickerAdd_Click = {
    if ($EventLogsStopTimePicker.checked -eq $false) {
        $EventLogsStopTimePicker.checked = $true
    }
}

$EventLogsStartTimePickerAdd_MouseHover = {
    Show-ToolTip -Title "DateTime - Starting" -Icon "Info" -Message @"
+  Select the starting datetime to filter Event Logs
+  This can be used with the Max Collection field
+  If left blank, it will collect all available Event Logs
+  If used, you must select both a start and end datetime
"@
}


