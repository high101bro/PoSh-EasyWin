Function Message-HostAlreadyExists {
    param(
        $Message,
        $Computer,
        [Switch]$ResultsListBoxMessage
    )
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab
    [system.media.systemsounds]::Exclamation.play()
    if ($Computer){
        $ComputerNameExist = $Computer
    }
    elseif ($Computer.Name) {
        $ComputerNameExist = $Computer.Name
    }

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("$Message")

    if ($ResultsListBoxMessage) {
        $ResultsListBox.Items.Add("The following hostname already exists: $ComputerNameExist")
        $ResultsListBox.Items.Add("- OS:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).OperatingSystem)")
        $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).CanonicalName)")
        $ResultsListBox.Items.Add("")
        $PoShEasyWin.Refresh()
    }
    else {
        [System.Windows.MessageBox]::Show("The following hostname already exists: $ComputerNameExist
- OU/CN: $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).CanonicalName)
- OS:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).OperatingSystem)",'Error')
    }
    #$ResultsListBox.Items.Add("- IP:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).IPv4Address)")
    #$ResultsListBox.Items.Add("- MAC:   $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).MACAddress)")
}


