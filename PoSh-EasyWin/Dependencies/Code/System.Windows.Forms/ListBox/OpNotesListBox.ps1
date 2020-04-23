$OpNotesListBoxAdd_MouseEnter = {
    $Section1TabControl.Size = New-Object System.Drawing.Size(($Section1TabControlBoxWidth + 615),$Section1TabControlBoxHeight)
    $OpNotesListBox.Size     = New-Object System.Drawing.Size(($OpNotesMainTextBoxWidth + 615),$OpNotesMainTextBoxHeight)
}

$OpNotesListBoxAdd_MouseLeave = {
    $Section1TabControl.Size = New-Object System.Drawing.Size($Section1TabControlBoxWidth,$Section1TabControlBoxHeight)
    $OpNotesListBox.Size     = New-Object System.Drawing.Size($OpNotesMainTextBoxWidth,$OpNotesMainTextBoxHeight)
}
