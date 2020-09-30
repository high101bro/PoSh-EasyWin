$Section3HostDataNotesAddOpNotesButtonAdd_Click = {
    $MainLeftTabControl.SelectedTab   = $Section1OpNotesTab
    if ($Section3HostDataNotesRichTextBox.text) {
        $TimeStamp = Get-Date
        $OpNotesListBox.Items.Add("$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss')) [+] Host Data Notes from: $($Section3HostDataNameTextBox.Text)")
        Add-Content -Path $OpNotesWriteOnlyFile -Value "$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss')) [+] Host Data Notes from: $($Section3HostDataNameTextBox.Text)" -Force
        foreach ( $Line in ($Section3HostDataNotesRichTextBox.text -split "`r`n") ){
            $OpNotesListBox.Items.Add("$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss'))  -  $Line")
            Add-Content -Path $OpNotesWriteOnlyFile -Value "$(($TimeStamp).ToString('yyyy/MM/dd HH:mm:ss'))  -  $Line" -Force
        }
        Save-OpNotes
    }
}

$Section3HostDataNotesAddOpNotesButtonAdd_MouseHover = {
    Show-ToolTip -Title "Add Selected To OpNotes" -Icon "Info" -Message @"
+  One or more lines can be selected to add to the OpNotes.
+  The selection can be contiguous by using the Shift key
    and/or be separate using the Ctrl key, the press OK.
+  A Datetime stampe will be prefixed to the entry.
"@
}


