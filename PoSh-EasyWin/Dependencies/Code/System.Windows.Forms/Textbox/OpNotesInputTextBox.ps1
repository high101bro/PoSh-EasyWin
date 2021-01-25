$OpNotesInputTextBoxAdd_KeyDown = {
    if ($_.KeyCode -eq "Enter") {
        # There must be text in the input to make an entry
        if ($OpNotesInputTextBox.Text -ne "") { OpNoteTextBoxEntry }
    }
}


