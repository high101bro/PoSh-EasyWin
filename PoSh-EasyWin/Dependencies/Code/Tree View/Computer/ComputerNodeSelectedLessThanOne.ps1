function ComputerNodeSelectedLessThanOne {
    param($Message)
    [system.media.systemsounds]::Exclamation.play()
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("$($Message):  Error")
    $ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Add("Error:  No hostname/IP selected")
    $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
    $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")
}
