function OpNoteTextBoxEntry {
    # Adds Timestamp to Entered Text
    $OpNotesAdded = $OpNotesListBox.Items.Add("$((Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) $($OpNotesInputTextBox.Text)")

    Save-OpNotes

    # Adds all entries to the OpNotesWriteOnlyFile -- This file gets all entries and are not editable from the GUI
    # Useful for looking into accidentally deleted entries
    Add-Content -Path $OpNotesWriteOnlyFile -Value ("$($(Get-Date).ToString('yyyy/MM/dd HH:mm:ss')) $($OpNotesInputTextBox.Text)") -Force

    $OpNotesInputTextBox.Text = ""
}


