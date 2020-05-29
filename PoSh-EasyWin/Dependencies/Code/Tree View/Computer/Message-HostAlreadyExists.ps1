Function Message-HostAlreadyExists {
    param(
        $Message,
        $Computer
    )
    [system.media.systemsounds]::Exclamation.play()
    if ($Computer){
        $ComputerNameExist = $Computer
    }
    elseif ($Computer.Name) {
        $ComputerNameExist = $Computer.Name
    }

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("$Message")
    [System.Windows.MessageBox]::Show("The following hostname already exists: $ComputerNameExist
- OU/CN: $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).CanonicalName)
- OS:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).OperatingSystem)",'Error')
    #$ResultsListBox.Items.Add("- IP:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).IPv4Address)")
    #$ResultsListBox.Items.Add("- MAC:   $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).MACAddress)")
}
