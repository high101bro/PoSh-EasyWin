Function Message-HostAlreadyExists($Message) {
    [system.media.systemsounds]::Exclamation.play()
    if ($Computer.Name) {$Computer = $Computer.Name}
    else {$Computer}
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("$Message")
    $ResultsListBox.Items.Add("$Computer - already exists with the following data:")
    $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).CanonicalName)")
    $ResultsListBox.Items.Add("- OS:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).OperatingSystem)")
    #$ResultsListBox.Items.Add("- IP:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).IPv4Address)")
    #$ResultsListBox.Items.Add("- MAC:   $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).MACAddress)")
    $ResultsListBox.Items.Add("")
}
