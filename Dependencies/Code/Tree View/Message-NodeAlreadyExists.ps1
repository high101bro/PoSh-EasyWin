Function Message-NodeAlreadyExists {
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
        $Message,
        $Account,
        $Computer,
        [Switch]$ResultsListBoxMessage
    )
    if ($Accounts) {
        $InformationTabControl.SelectedTab = $Section3ResultsTab
        [system.media.systemsounds]::Exclamation.play()
        if ($Account){
            $AccountsNameExist = $Account
        }
        elseif ($Account.Name) {
            $AccountsNameExist = $Account.Name
        }
    
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("$Message")
    
        if ($ResultsListBoxMessage) {
            $ResultsListBox.Items.Add("The following Account already exists: $AccountsNameExist")
            $ResultsListBox.Items.Add("- OS:    $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).OperatingSystem)")
            $ResultsListBox.Items.Add("- OU/CN: $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).CanonicalName)")
            $ResultsListBox.Items.Add("")
            $PoShEasyWin.Refresh()
        }
        else {
            [System.Windows.MessageBox]::Show("The following Account already exists: $AccountsNameExist
- OU/CN:      $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).CanonicalName)
- Created:    $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).Created)
- LockedOut:  $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).LockedOut)",'Error')
        }
        #$ResultsListBox.Items.Add("- IP:    $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).IPv4Address)")
        #$ResultsListBox.Items.Add("- MAC:   $($($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Account}).MACAddress)")
    }
    if ($Endpoint) {
        $InformationTabControl.SelectedTab = $Section3ResultsTab
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
            $ResultsListBox.Items.Add("The following Endpoint already exists: $ComputerNameExist")
            $ResultsListBox.Items.Add("- OS:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).OperatingSystem)")
            $ResultsListBox.Items.Add("- OU/CN: $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).CanonicalName)")
            $ResultsListBox.Items.Add("")
            $PoShEasyWin.Refresh()
        }
        else {
            [System.Windows.MessageBox]::Show("The following Endpoint already exists: $ComputerNameExist
- OU/CN: $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).CanonicalName)
- OS:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).OperatingSystem)",'Error')
        }
        #$ResultsListBox.Items.Add("- IP:    $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).IPv4Address)")
        #$ResultsListBox.Items.Add("- MAC:   $($($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Computer}).MACAddress)")
    }
}


