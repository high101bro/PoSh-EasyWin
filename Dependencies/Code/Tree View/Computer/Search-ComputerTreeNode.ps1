function Search-ComputerTreeNode {

    #$InformationTabControl.SelectedTab   = $Section3ResultsTab
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes

    # Checks if the search node already exists
    $SearchNode = $false
    foreach ($root in $AllHostsNode) {
        if ($root.text -imatch 'Search Results') { $SearchNode = $true }
    }
    if ($SearchNode -eq $false) { $script:ComputerTreeView.Nodes.Add($script:ComputerListSearch) }
   

    $ComputerSearchText = $ComputerTreeNodeSearchComboBox.Text

    # Checks if the search has already been conduected
    $SearchCheck = $false
    foreach ($root in $AllHostsNode) {
        if ($root.text -imatch 'Search Results') {
            foreach ($Category in $root.Nodes) {
                if ($Category.text -eq $ComputerSearchText) { $SearchCheck = $true}
            }
        }
    }

    # Conducts the search, if something is found it will add it to the treeview
    # Will not produce multiple results if the host triggers in more than one field
    $SearchFound = @()
    if ($ComputerSearchText -ne "" -and $SearchCheck -eq $false) {
        if ($ComputerTreeNodeSearchGreedyCheckbox.checked) {
            Foreach($Computer in $script:ComputerTreeViewData) {
                if (($SearchFound -inotcontains $Computer) -and ($Computer.Notes -imatch $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HostData Notes]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
                if (($SearchFound -inotcontains $Computer) -and ($Computer.Name -imatch $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HostData Name]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
                if (($SearchFound -inotcontains $Computer) -and ($Computer.OperatingSystem -imatch $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HostData OS]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
                if (($SearchFound -inotcontains $Computer) -and ($Computer.CanonicalName -imatch $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HostData OU/CN]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
                if (($SearchFound -inotcontains $Computer) -and ($Computer.IPv4address -imatch $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HostData IP]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
                if (($SearchFound -inotcontains $Computer) -and ($Computer.MACAddress -imatch $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HostData MAC]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
                if (($SearchFound -inotcontains $Computer) -and ($Computer.PortScan -imatch $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Port Scan]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
            }
        }
        else {
            Foreach($Computer in $script:ComputerTreeViewData) {
                if (($SearchFound -inotcontains $Computer) -and ($Computer.Notes -eq $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HostData Notes]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
                if (($SearchFound -inotcontains $Computer) -and ($Computer.Name -eq $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HostData Name]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
                if (($SearchFound -inotcontains $Computer) -and ($Computer.OperatingSystem -eq $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HostData OS]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
                if (($SearchFound -inotcontains $Computer) -and ($Computer.CanonicalName -eq $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HostData OU/CN]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
                if (($SearchFound -inotcontains $Computer) -and ($Computer.IPv4address -eq $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HostData IP]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
                if (($SearchFound -inotcontains $Computer) -and ($Computer.MACAddress -eq $ComputerSearchText)) {
                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HostData MAC]') -Entry $Computer.Name -DoNotPopulateMetadata
                    $SearchFound += $Computer
                }
                if (($SearchFound -inotcontains $Computer) -and ($Computer.PortScan -imatch $ComputerSearchText)) {
                    foreach ($port in (($Computer.PortScan).split(',')) ) {
                        if ($port -eq $ComputerSearchText) {
                            Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Port Scan]') -Entry $Computer.Name -DoNotPopulateMetadata
                            $SearchFound += $Computer
                        }
                    }
                }
            }
        }
        
        # Checks if the Option is checked, if so it will include searching through 'Processes' CSVs
        # This is a slow process...
        if ($OptionSearchProcessesCheckBox.Checked -or $OptionSearchServicesCheckBox.Checked -or $OptionSearchNetworkTCPConnectionsCheckBox.Checked) {
            # Searches though the all Collection Data Directories to find files that match
            $ListOfCollectedDataDirectories = $(Get-ChildItem -Path $CollectedDataDirectory | Sort-Object -Descending).FullName | Select-Object -first $CollectedDataDirectorySearchLimitCombobox.text
            $script:CSVFileMatch = @()

            foreach ($CollectionDir in $ListOfCollectedDataDirectories) {
                $CSVFiles = $(Get-ChildItem -Path $CollectionDir -Filter "*.csv" -Recurse).FullName | Where {$_ -match  "Collected Data" -and $_ -notmatch "Results By Endpoints"}
                foreach ($CSVFile in $CSVFiles) {
                    if ($OptionSearchProcessesCheckBox.Checked) {
                        # Searches for the CSV file that matches the data selected
                        if ($CSVFile -match "Processes") {
                            if ($ComputerTreeNodeSearchGreedyCheckbox.checked) {
                                $SearchImportedCsvData = Import-CSV -Path $CSVFile | Select-Object -Property ComputerName, ProcessName, Name, Description  | where {($_.ProcessName -imatch $ComputerSearchText) -or ($_.Name -imatch $ComputerSearchText) -or ($_.Description -imatch $ComputerSearchText)} #| where {$_.name -ne ''}
                            }
                            else {
                                $SearchImportedCsvData = Import-CSV -Path $CSVFile | Select-Object -Property ComputerName, ProcessName, Name, Description  | where {($_.ProcessName -eq $ComputerSearchText) -or ($_.Name -eq $ComputerSearchText) -or ($_.Description -eq $ComputerSearchText)} #| where {$_.name -ne ''}
                            }                            
                            $SearchImportedCsvData = $SearchImportedCsvData | Select-Object -ExpandProperty ComputerName -Unique
                            if ( $SearchImportedCsvData ) {
                                foreach ($PSComputerName in $SearchImportedCsvData) {
                                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Process]') -Entry $PSComputerName -DoNotPopulateMetadata
                                    $SearchFound += $ComputerWithResults
                                }
                            }
                        }
                    }
                    if ($OptionSearchServicesCheckBox.Checked) {
                        # Searches for the CSV file that matches the data selected
                        if ($CSVFile -match "Services") {
                            if ($ComputerTreeNodeSearchGreedyCheckbox.checked) {
                                $SearchImportedCsvData = Import-CSV -Path $CSVFile | Select-Object -Property ComputerName, Name, DisplayName  | where {($_.Name -imatch $ComputerSearchText) -or ($_.DisplayName -imatch $ComputerSearchText)} #| where {$_.name -ne ''}
                            }
                            else {
                                $SearchImportedCsvData = Import-CSV -Path $CSVFile | Select-Object -Property ComputerName, Name, DisplayName  | where {($_.Name -eq $ComputerSearchText) -or ($_.DisplayName -eq $ComputerSearchText)} #| where {$_.name -ne ''}
                            }
                            $SearchImportedCsvData = $SearchImportedCsvData | Select-Object -ExpandProperty ComputerName -Unique
                            if ( $SearchImportedCsvData ) {
                                foreach ($PSComputerName in $SearchImportedCsvData) {
                                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Service]') -Entry $PSComputerName -DoNotPopulateMetadata
                                    $SearchFound += $ComputerWithResults
                                }
                            }
                        }
                    }
                    if ($OptionSearchNetworkTCPConnectionsCheckBox.Checked) {
                        # Searches for the CSV file that matches the data selected
                        if ($CSVFile -match "Network") {
                            if ($ComputerTreeNodeSearchGreedyCheckbox.checked) {
                                $SearchImportedCsvData = Import-CSV -Path $CSVFile | Select-Object -Property ComputerName, RemoteAddress, RemotePort, LocalPort, ProcessName, CommandLine | where {($_.CommandLine -imatch $ComputerSearchText) -or ($_.ProcessName -imatch $ComputerSearchText) -or ($_.RemoteAddress -imatch $ComputerSearchText) -or ($_.RemotePort -imatch $ComputerSearchText) -or ($_.LocalPort -imatch $ComputerSearchText)} #| where {$_.name -ne ''}
                            }
                            else {
                                $SearchImportedCsvData = Import-CSV -Path $CSVFile | Select-Object -Property ComputerName, RemoteAddress, RemotePort, LocalPort, ProcessName, CommandLine | where {($_.CommandLine -eq $ComputerSearchText) -or ($_.ProcessName -eq $ComputerSearchText) -or ($_.RemoteAddress -eq $ComputerSearchText) -or ($_.RemotePort -eq $ComputerSearchText) -or ($_.LocalPort -eq $ComputerSearchText)} #| where {$_.name -ne ''}
                            }

                            $SearchImportedCsvData = $SearchImportedCsvData | Select-Object -ExpandProperty ComputerName -Unique
                            if ( $SearchImportedCsvData ) {
                                foreach ($PSComputerName in $SearchImportedCsvData) {
                                    Add-NodeComputer -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Network]') -Entry $PSComputerName -DoNotPopulateMetadata
                                    $SearchFound += $ComputerWithResults
                                }
                            }
                        }
                    }
                }
            }
        }
    }








    # Manages TreeView Appearance when Search Results are found
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
    foreach ($root in $AllHostsNode) {
        if ($root.text -match 'Search Results'){
            $root.Collapse()
            $root.Expand()
            foreach ($Category in $root.Nodes) {
                if ($ComputerSearchText -in $Category.text) {
                    $Category.Expand()
                }
                else {
                    $Category.Collapse()
                }
            }
        }
    }
    $ComputerSearchText = ""
    $script:ComputerTreeView.Enabled   = $true
    $script:ComputerTreeView.BackColor = "white"

}


