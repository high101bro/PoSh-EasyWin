$OpNotesRemoveButtonAdd_Click = {
    while($OpNotesListBox.SelectedItems) { 
        $OpNotesListBox.Items.Remove($OpNotesListBox.SelectedItems[0]) 
    }
    Save-OpNotes
}
