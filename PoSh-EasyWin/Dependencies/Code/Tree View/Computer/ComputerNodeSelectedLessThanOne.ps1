function ComputerNodeSelectedLessThanOne {
    param($Message)
    [system.media.systemsounds]::Exclamation.play()
    [System.Windows.MessageBox]::Show("No hostname/IP selected`r`nMake sure to checkbox only one hostname/IP`r`nSelecting a Category will not allow you to connect to multiple hosts","$($Message):  Error")
<#
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("$($Message):  Error")
    #Removed For Testing#$ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Add("Error:  No hostname/IP selected")
    $ResultsListBox.Items.Add("        Make sure to checkbox only one hostname/IP")
    $ResultsListBox.Items.Add("        Selecting a Category will not allow you to connect to multiple hosts")
#>
}


