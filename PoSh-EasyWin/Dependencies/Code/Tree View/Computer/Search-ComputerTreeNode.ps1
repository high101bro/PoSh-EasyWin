function Search-ComputerTreeNode {
    #$Section4TabControl.SelectedTab   = $Section3ResultsTab
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes

    # Checks if the search node already exists
    $SearchNode = $false
    foreach ($root in $AllHostsNode) { 
        if ($root.text -imatch 'Search Results') { $SearchNode = $true }
    }
    if ($SearchNode -eq $false) { $script:ComputerTreeView.Nodes.Add($script:ComputerListSearch) }

    # Checks if the search has already been conduected
    $SearchCheck = $false
    foreach ($root in $AllHostsNode) { 
        if ($root.text -imatch 'Search Results') {                    
            foreach ($Category in $root.Nodes) { 
                if ($Category.text -eq $ComputerTreeNodeSearchComboBox.Text) { $SearchCheck = $true}            
            }
        }
    }
    # Conducts the search, if something is found it will add it to the treeview
    # Will not produce multiple results if the host triggers in more than one field
    $SearchFound = @()
    if ($ComputerTreeNodeSearchComboBox.Text -ne "" -and $SearchCheck -eq $false) {
        Foreach($Computer in $script:ComputerTreeViewData) {
            if (($SearchFound -inotcontains $Computer) -and ($Computer.Notes -imatch $ComputerTreeNodeSearchComboBox.Text)) {
                Add-ComputerTreeNode -RootNode $script:ComputerListSearch -Category $ComputerTreeNodeSearchComboBox.Text -Entry $Computer.Name -ToolTip $Computer.IPv4Address    
                $SearchFound += $Computer
            }
            if (($SearchFound -inotcontains $Computer) -and ($Computer.Name -imatch $ComputerTreeNodeSearchComboBox.Text)) {
                Add-ComputerTreeNode -RootNode $script:ComputerListSearch -Category $ComputerTreeNodeSearchComboBox.Text -Entry $Computer.Name -ToolTip $Computer.IPv4Address    
                $SearchFound += $Computer
            }
            if (($SearchFound -inotcontains $Computer) -and ($Computer.OperatingSystem -imatch $ComputerTreeNodeSearchComboBox.Text)) {
                Add-ComputerTreeNode -RootNode $script:ComputerListSearch -Category $ComputerTreeNodeSearchComboBox.Text -Entry $Computer.Name -ToolTip $Computer.IPv4Address    
                $SearchFound += $Computer
            }
            if (($SearchFound -inotcontains $Computer) -and ($Computer.CanonicalName -imatch $ComputerTreeNodeSearchComboBox.Text)) {
                Add-ComputerTreeNode -RootNode $script:ComputerListSearch -Category $ComputerTreeNodeSearchComboBox.Text -Entry $Computer.Name -ToolTip $Computer.IPv4Address    
                $SearchFound += $Computer
            }
            if (($SearchFound -inotcontains $Computer) -and ($Computer.IPv4address -imatch $ComputerTreeNodeSearchComboBox.Text)) {
                Add-ComputerTreeNode -RootNode $script:ComputerListSearch -Category $ComputerTreeNodeSearchComboBox.Text -Entry $Computer.Name -ToolTip $Computer.IPv4Address    
                $SearchFound += $Computer
            }                
            if (($SearchFound -inotcontains $Computer) -and ($Computer.MACAddress -imatch $ComputerTreeNodeSearchComboBox.Text)) {
                Add-ComputerTreeNode -RootNode $script:ComputerListSearch -Category $ComputerTreeNodeSearchComboBox.Text -Entry $Computer.Name -ToolTip $Computer.IPv4Address    
                $SearchFound += $Computer
            }                
        }    

        # Checks if the Option is checked, if so it will include searching through 'Processes' CSVs
        # This is a slow process...
        if ($OptionSearchProcessesCheckBox.Checked -or $OptionSearchServicesCheckBox.Checked -or $OptionSearchNetworkTCPConnectionsCheckBox.Checked) {
            # Searches though the all Collection Data Directories to find files that match
            $ListOfCollectedDataDirectories = $(Get-ChildItem -Path $CollectedDataDirectory | Sort-Object -Descending).FullName | Select-Object -first $CollectedDataDirectorySearchLimitCombobox.text
            $script:CSVFileMatch = @()

            foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
                $CSVFiles = $(Get-ChildItem -Path $CollectionDir -Filter "*.csv" -Recurse).FullName 
                foreach ($CSVFile in $CSVFiles) { 
                    if ($OptionSearchProcessesCheckBox.Checked) {
                        # Searches for the CSV file that matches the data selected
                        if (($CSVFile -match "Processes") -and ($CSVFile -match "Individual Host Results") -and ($CSVFile -match ".csv")) {
                            if ($(Import-CSV -Path $CSVFile | select -Property Name, Description | `
                                where {($_.Name -imatch $ComputerTreeNodeSearchComboBox.Text) -or ($_.Description -imatch $ComputerTreeNodeSearchComboBox.Text)} #| where {$_.name -ne ''}
                                )) {
                                #note: .split(@(' - '),'none') allows me to split on " - ", which is three characters
                                $ComputerWithResults = $CSVFile.Split('\')[-1].split(@(' - '),'none')[-1].split('.')[-2].replace(' ','')
                                if (($SearchFound -inotcontains $ComputerWithResults) -and ($ComputerWithResults -ne ''))  {
                                    Add-ComputerTreeNode -RootNode $script:ComputerListSearch -Category $ComputerTreeNodeSearchComboBox.Text -Entry $ComputerWithResults #-ToolTip $Computer.IPv4Address
                                    $SearchFound += $ComputerWithResults
                                }
                            }
                        }
                    }
                    if ($OptionSearchServicesCheckBox.Checked) {
                        # Searches for the CSV file that matches the data selected
                        if (($CSVFile -match "Services") -and ($CSVFile -match "Individual Host Results") -and ($CSVFile -match ".csv")) {
                            if ($(Import-CSV -Path $CSVFile | select -Property Name, DisplayName | `
                                where {($_.Name -imatch $ComputerTreeNodeSearchComboBox.Text) -or ($_.DisplayName -imatch $ComputerTreeNodeSearchComboBox.Text)} #| where {$_.name -ne ''}
                                )) {
                                #note: .split(@(' - '),'none') allows me to split on " - ", which is three characters
                                $ComputerWithResults = $CSVFile.Split('\')[-1].split(@(' - '),'none')[-1].split('.')[-2].replace(' ','')
                                if (($SearchFound -inotcontains $ComputerWithResults) -and ($ComputerWithResults -ne ''))  {
                                    Add-ComputerTreeNode -RootNode $script:ComputerListSearch -Category $ComputerTreeNodeSearchComboBox.Text -Entry $ComputerWithResults #-ToolTip $Computer.IPv4Address
                                    $SearchFound += $ComputerWithResults
                                }
                            }
                        }
                    }
                    if ($OptionSearchNetworkTCPConnectionsCheckBox.Checked) {
                        # Searches for the CSV file that matches the data selected
                        if (($CSVFile -match "Network") -and ($CSVFile -match "Individual Host Results") -and ($CSVFile -match ".csv")) {
                            if ($(Import-CSV -Path $CSVFile | select -Property RemoteAddress, RemotePort, LocalPort | `
                                where {($_.RemoteAddress -imatch $ComputerTreeNodeSearchComboBox.Text) -or ($_.RemotePort -imatch $ComputerTreeNodeSearchComboBox.Text) -or ($_.LocalPort -imatch $ComputerTreeNodeSearchComboBox.Text)} #| where {$_.name -ne ''}
                                )) {
                                #note: .split(@(' - '),'none') allows me to split on " - ", which is three characters
                                $ComputerWithResults = $CSVFile.Split('\')[-1].split(@(' - '),'none')[-1].split('.')[-2].replace(' ','')
                                if (($SearchFound -inotcontains $ComputerWithResults) -and ($ComputerWithResults -ne ''))  {
                                    Add-ComputerTreeNode -RootNode $script:ComputerListSearch -Category $ComputerTreeNodeSearchComboBox.Text -Entry $ComputerWithResults #-ToolTip $Computer.IPv4Address
                                    $SearchFound += $ComputerWithResults
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes 
    foreach ($root in $AllHostsNode) { 
        if ($root.text -match 'Search Results'){
            $root.Collapse()
            $root.Expand()
            foreach ($Category in $root.Nodes) {
                if ($ComputerTreeNodeSearchComboBox.text -in $Category.text) {
                    $Category.Expand()
                }
                else {
                    $Category.Collapse()
                }
            }
        }
    }
    $ComputerTreeNodeSearchComboBox.Text = ""
    $script:SingleHostIPCheckBox.Checked    = $false
    $script:SingleHostIPTextBox.Text        = $DefaultSingleHostIPText
    $script:ComputerTreeView.Enabled    = $true
    $script:ComputerTreeView.BackColor  = "white"
}