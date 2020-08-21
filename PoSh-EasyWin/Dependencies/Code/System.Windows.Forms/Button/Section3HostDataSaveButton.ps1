$Section3HostDataSaveButtonAdd_Click = {
    Save-ComputerTreeNodeHostData
    Save-HostData
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Saved Host Data:  $($Section3HostDataNameTextBox.Text)")
}

$Section3HostDataSaveButtonAdd_MouseHover = {
    Show-ToolTip -Title "Warning" -Icon "Warning" -Message @"
+  It's Best practice is to manually save after modifying each host data.
+  That said, data is automatically saved when you select a endpoint in the computer treeview
"@
}
