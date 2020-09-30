$EnumerationComputerListBoxAddToListButtonAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab

    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Enumeration:  Added $($EnumerationComputerListBox.SelectedItems.Count) IPs")
    #Removed For Testing#$ResultsListBox.Items.Clear()
    foreach ($Selected in $EnumerationComputerListBox.SelectedItems) {
        if ($script:ComputerTreeViewData.Name -contains $Selected) {
            Message-HostAlreadyExists -Message "Port Scan Import:  Warning" -Computer $Selected
        }
        else {
            if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
                Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Selected -ToolTip $Computer.IPv4Address
                $MainBottomTabControl.SelectedTab = $Section3ResultsTab
                $ResultsListBox.Items.Add("$($Selected) has been added to the Unknown category")
            }
            elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked) {
                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Selected -ToolTip $Computer.IPv4Address
                $ResultsListBox.Items.Add("$($Selected) has been added to /Unknown category")
            }
            $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{
                Name            = $Selected
                OperatingSystem = 'Unknown'
                CanonicalName   = '/Unknown'
                IPv4Address     = $Selected
            }
            $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP
        }
    }
    $script:ComputerTreeView.ExpandAll()
    Populate-ComputerTreeNodeDefaultData
    AutoSave-HostData
    Save-HostData
}


