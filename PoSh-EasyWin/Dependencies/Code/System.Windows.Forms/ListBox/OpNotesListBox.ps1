$OpNotesListBoxAdd_MouseEnter = {
    $MainLeftTabControl.Size = New-Object System.Drawing.Size(($MainLeftTabControlBoxWidth + 615),$MainLeftTabControlBoxHeight)
    $OpNotesListBox.Size     = New-Object System.Drawing.Size(($OpNotesMainTextBoxWidth + 615),$OpNotesMainTextBoxHeight)
}

$OpNotesListBoxAdd_MouseLeave = {
    $MainLeftTabControl.Size = New-Object System.Drawing.Size($MainLeftTabControlBoxWidth,$MainLeftTabControlBoxHeight)
    $OpNotesListBox.Size     = New-Object System.Drawing.Size($OpNotesMainTextBoxWidth,$OpNotesMainTextBoxHeight)
}
