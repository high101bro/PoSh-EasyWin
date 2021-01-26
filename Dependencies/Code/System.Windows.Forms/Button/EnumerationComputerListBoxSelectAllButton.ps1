$EnumerationComputerListBoxSelectAllButtonAdd_Click = {
    # Select all fields
    for($i = 0; $i -lt $EnumerationComputerListBox.Items.Count; $i++) {
        $EnumerationComputerListBox.SetSelected($i, $true)
    }
}

