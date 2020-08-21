$OpNotesListBoxAdd_MouseEnter = {
    $MainLeftTabControl.Size = @{ Width  = $FormScale * ($MainLeftTabControlBoxWidth + 615)
                                  Height = $FormScale * $MainLeftTabControlBoxHeight }
    $OpNotesListBox.Size     = @{ Width  = $FormScale * ($OpNotesMainTextBoxWidth + 615)
                                  Height = $FormScale * $OpNotesMainTextBoxHeight }
}

$OpNotesListBoxAdd_MouseLeave = {
    $MainLeftTabControl.Size = @{ Width  = $FormScale * ($MainLeftTabControlBoxWidth)
                                  Height = $FormScale * $MainLeftTabControlBoxHeight }
    $OpNotesListBox.Size     = @{ Width  = $FormScale * $OpNotesMainTextBoxWidth
                                  Height = $FormScale * $OpNotesMainTextBoxHeight }
}
