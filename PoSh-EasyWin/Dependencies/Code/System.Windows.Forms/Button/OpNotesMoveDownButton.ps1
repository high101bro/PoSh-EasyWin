$OpNotesMoveDownButtonAdd_Click = {
    if(($OpNotesListBox.Items).Count -ne (($OpNotesListBox.SelectedIndices)[-1] + 1) ) {
        $OpNotesListBox.BeginUpdate()
        $OpNotesToMove = @()
        $SelectedItemPositions = @()
        $SelectedItemIndices = $($OpNotesListBox.SelectedIndices)

        $BufferLine = $null
        #Checks if the lines are contiguous, if they are not it will not move the lines
        foreach ($line in $SelectedItemIndices) {
            if (($BufferLine - $line) -ne -1 -and $BufferLine -ne $null) {
                $OpNotesListBox.EndUpdate()
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Error: OpNotes")
                $ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add('Error: You can only move contiguous lines up or down.')
                [system.media.systemsounds]::Exclamation.play()
                #[console]::beep(500,100)
                return
            }
            $BufferLine = [int]$line
        }
        #Adds lines to variable to be moved and removes each line
        while($OpNotesListBox.SelectedItems) {
            $SelectedItemPositions += $OpNotesListBox.SelectedIndex
            $OpNotesToMove         += $OpNotesListBox.SelectedItems[0]
            $OpNotesListBox.Items.Remove($OpNotesListBox.SelectedItems[0]) 
        }
        #Reverses Array order... [array]::reverse($OpNotesToMove) was not working
        if ($a.Length -gt 999) {$OpNotesToMove = $OpNotesToMove[-1..-10000]}
        else {$OpNotesToMove = $OpNotesToMove[-1..-1000]}

        #Adds lines to their new location
        foreach ($note in $OpNotesToMove) { $OpNotesListBox.items.insert($SelectedItemPositions[0] +1,$note) 
        }
        $OpNotesListBox.EndUpdate()
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Success: OpNotes Action")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Moved OpNote lines down.")
        $ResultsListBox.Items.Add('Opnotes have been saved.')
        Save-OpNotes
    
        #the index location of the line
        $IndexCount = $SelectedItemIndices.count
        foreach ($Index in $SelectedItemIndices) { $OpNotesListBox.SetSelected(($Index + 1),$true) }
    }
    else {
        [system.media.systemsounds]::Exclamation.play()
        #[console]::beep(500,100)
    }
}
