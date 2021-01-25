$ResultsTabOpNotesAddButtonAdd_Click = {
    $MainLeftTabControl.SelectedTab   = $Section1OpNotesTab
    if ($ResultsListBox.Items.Count -gt 0) {
        $TimeStamp = Get-Date
        $OpNotesListBox.Items.Add("$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss')) [+] Notes added from Results Window:")
        Add-Content -Path $OpNotesWriteOnlyFile -Value "$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss')) [+] Notes added from Results Window:" -Force
        foreach ( $Line in $ResultsListBox.SelectedItems ){
            $OpNotesListBox.Items.Add("$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss'))  -  $Line")
            Add-Content -Path $OpNotesWriteOnlyFile -Value "$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss'))  -  $Line" -Force
        }
        Save-OpNotes
    }
}

$ResultsTabOpNotesAddButtonAdd_MouseHover = {
    Show-ToolTip -Title "Add Selected To OpNotes" -Icon "Info" -Message @"
+  One or more lines can be selected to add to the OpNotes.
+  The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.
+  A Datetime stampe will be prefixed to the entry.
"@
}


