function Search-TreeViewData {
    param(
        [switch]$Accounts,
        [switch]$Endpoint
    )

    if ($Accounts) {
        #$InformationTabControl.SelectedTab   = $Section3ResultsTab
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes

        # Checks if the search node already exists
        $SearchNode = $false
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -imatch 'Search Results') { $SearchNode = $true }
        }
        if ($SearchNode -eq $false) { $script:AccountsTreeView.Nodes.Add($script:AccountsListSearch) }
    

        $AccountsSearchText = $AccountsTreeNodeSearchComboBox.Text

        # Checks if the search has already been conduected
        $SearchCheck = $false
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -imatch 'Search Results') {
                foreach ($Category in $root.Nodes) {
                    if ($Category.text -eq $AccountsSearchText) { $SearchCheck = $true}
                }
            }
        }

        # Conducts the search, if something is found it will add it to the treeview
        # Will not produce multiple results if the host triggers in more than one field
        $SearchFoundNotes         = @()
        $SearchFoundName          = @()
        $SearchFoundCanonicalName = @()
        $SearchFoundMemberOf      = @()
        $SearchFoundScriptPath    = @()
        $SearchFoundHomeDrive     = @()
        if ($AccountsSearchText -ne "" -and $SearchCheck -eq $false) {
            if ($AccountsTreeNodeSearchGreedyCheckbox.checked) {
                Foreach($Account in $script:AccountsTreeViewData) {
                    if (($SearchFoundNotes -inotcontains $Account.Name) -and ($Account.Notes -imatch $AccountsSearchText)) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Notes]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundNotes += $Account.Name
                    }
                    if (($SearchFoundName -inotcontains $Account.Name) -and ($Account.Name -imatch $AccountsSearchText)) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Name]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundName += $Account.Name
                    }
                    if (($SearchFoundCanonicalName -inotcontains $Account.Name) -and ($Account.CanonicalName -imatch $AccountsSearchText)) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [OU/CN]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundCanonicalName += $Account.Name
                    }
                    $AccountSearchGroupList = $Account.MemberOf.split("`n") | Sort-Object
                    ForEach ($Group in $AccountSearchGroupList) {
                        if (($SearchFoundMemberOf -inotcontains $Account.Name) -and ($Group -imatch $AccountsSearchText)) {
                            AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Group]') -Entry $Account.Name -DoNotPopulateMetadata
                            $SearchFoundMemberOf += $Account.Name
                        }
                    }
                    if (($SearchFoundScriptPath -inotcontains $Account.Name) -and ($Account.ScriptPath -imatch $AccountsSearchText)) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Script Path]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundScriptPath += $Account.Name
                    }
                    if (($SearchFoundHomeDrive -inotcontains $Account.Name) -and ($Account.HomeDrive -imatch $AccountsSearchText)) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Home Drive]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundHomeDrive += $Account.Name
                    }
                }
            }
            else {
                Foreach($Account in $script:AccountsTreeViewData) {
                    if (($SearchFoundNotes -inotcontains $Account.Name) -and ($Account.Notes -eq $AccountsSearchText)) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Notes]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundNotes += $Account.Name
                    }
                    if (($SearchFoundName -inotcontains $Account.Name) -and ($Account.Name -eq $AccountsSearchText)) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Name]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundName += $Account.Name
                    }
                    if (($SearchFoundCanonicalName -inotcontains $Account.Name) -and ($Account.CanonicalName -eq $AccountsSearchText)) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [OU/CN]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundCanonicalName += $Account.Name
                    }
                    $AccountSearchGroupList = $Account.MemberOf.split("`n") | Sort-Object
                    ForEach ($Group in $AccountSearchGroupList) {
                        if (($SearchFoundMemberOf -inotcontains $Account.Name) -and ($Group -eq $AccountsSearchText)) {
                            AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Group]') -Entry $Account.Name -DoNotPopulateMetadata
                            $SearchFoundMemberOf += $Account.Name
                        }
                    }
                    if (($SearchFoundScriptPath -inotcontains $Account.Name) -and ($Account.ScriptPath -eq $AccountsSearchText)) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Script Path]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundScriptPath += $Account.Name
                    }
                    if (($SearchFoundHomeDrive -inotcontains $Account.Name) -and ($Account.HomeDrive -eq $AccountsSearchText)) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:AccountsListSearch -Category $($AccountsSearchText + ' [Home Drive]') -Entry $Account.Name -DoNotPopulateMetadata
                        $SearchFoundHomeDrive += $Account.Name
                    }
                }
            }
        }


        # Manages TreeView Appearance when Search Results are found
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -match 'Search Results'){
                $root.Collapse()
                $root.Expand()
                foreach ($Category in $root.Nodes) {
                    if ($AccountsSearchText -in $Category.text) {
                        $Category.Expand()
                    }
                    else {
                        $Category.Collapse()
                    }
                }
            }
        }
        $AccountsSearchText = ""
        $script:AccountsTreeView.Enabled   = $true
        $script:AccountsTreeView.BackColor = "white"
    }






    if ($Endpoint) {
        #$InformationTabControl.SelectedTab   = $Section3ResultsTab
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes

        # Checks if the search node already exists
        $SearchNode = $false
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -imatch 'Search Results') { $SearchNode = $true }
        }
        if ($SearchNode -eq $false) { $script:ComputerTreeView.Nodes.Add($script:ComputerListSearch) }
    

        $ComputerSearchText = $ComputerTreeNodeSearchComboBox.Text

        # Checks if the search has already been conduected
        $SearchCheck = $false
        foreach ($root in $AllTreeViewNodes) {
            if ($root.text -imatch 'Search Results') {
                foreach ($Category in $root.Nodes) {
                    if ($Category.text -eq $ComputerSearchText) { $SearchCheck = $true}
                }
            }
        }

        # Conducts the search, if something is found it will add it to the treeview
        # Will not produce multiple results if the host triggers in more than one field
        $SearchFoundNotes                      = @()
        $SearchFoundName                       = @()
        $SearchFoundOperatingSystem            = @()
        $SearchFoundCanonicalName              = @()
        $SearchFoundIPv4address                = @()
        $SearchFoundMACAddress                 = @()
        $SearchFoundOperatingSystemHotfix      = @()
        $SearchFoundOperatingSystemServicePack = @()
        $SearchFoundMemberOf                   = @()
        $SearchFoundLocation                   = @()
        $SearchFoundPortScan                   = @()
        if ($ComputerSearchText -ne "" -and $SearchCheck -eq $false) {
            if ($ComputerTreeNodeSearchGreedyCheckbox.checked) {
                Foreach($Computer in $script:ComputerTreeViewData) {
                    if (($SearchFoundNotes -inotcontains $Computer.Name) -and ($Computer.Notes -imatch $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Notes]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundNotes += $Computer.Name
                    }
                    if (($SearchFoundName -inotcontains $Computer.Name) -and ($Computer.Name -imatch $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Name]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundName += $Computer.Name
                    }
                    if (($SearchFoundOperatingSystem -inotcontains $Computer.Name) -and ($Computer.OperatingSystem -imatch $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [OS]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundOperatingSystem += $Computer.Name
                    }
                    if (($SearchFoundCanonicalName -inotcontains $Computer.Name) -and ($Computer.CanonicalName -imatch $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [OU/CN]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundCanonicalName += $Computer.Name
                    }
                    if (($SearchFoundIPv4address -inotcontains $Computer.Name) -and ($Computer.IPv4address -imatch $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [IP]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundIPv4address += $Computer.Name
                    }
                    if (($SearchFoundMACAddress -inotcontains $Computer.Name) -and ($Computer.MACAddress -imatch $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [MAC]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundMACAddress += $Computer.Name
                    }
                    if (($SearchFoundOperatingSystemHotfix -inotcontains $Computer.Name) -and ($Computer.OperatingSystemHotfix -imatch $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Hotfix]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundOperatingSystemHotfix += $Computer.Name
                    }
                    if (($SearchFoundOperatingSystemServicePack -inotcontains $Computer.Name) -and ($Computer.OperatingSystemServicePack -imatch $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Service Pack]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundOperatingSystemServicePack += $Computer.Name
                    }
                    if (($SearchFoundMemberOf -inotcontains $Computer.Name) -and ($Computer.MemberOf -imatch $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Group]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundMemberOf += $Computer.Name
                    }
                    if (($SearchFoundLocation -inotcontains $Computer.Name) -and ($Computer.Location -imatch $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Location]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundLocation += $Computer.Name
                    }
                    if ($Computer.PortScan) {
                        $EndpointPortScanList = $Computer.PortScan.split(",") | Sort-Object
                    }
                    else {
                        $EndpointPortScanList = $null
                    }
                    ForEach ($Port in $EndpointPortScanList) {
                        if (($SearchFoundPortScan -inotcontains $Computer.Name) -and ($Port -imatch $ComputerSearchText)) {
                            AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Port Scan]') -Entry $Computer.Name -DoNotPopulateMetadata
                            $SearchFoundPortScan += $Computer.Name
                        }
                    }
                }
            }
            else {
                Foreach($Computer in $script:ComputerTreeViewData) {
                    if (($SearchFoundNotes -inotcontains $Computer.Name) -and ($Computer.Notes -eq $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Notes]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundNotes += $Computer.Name
                    }
                    if (($SearchFoundName -inotcontains $Computer.Name) -and ($Computer.Name -eq $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Name]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundName += $Computer.Name
                    }
                    if (($SearchFoundOperatingSystem -inotcontains $Computer.Name) -and ($Computer.OperatingSystem -eq $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [OS]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundOperatingSystem += $Computer.Name
                    }
                    if (($SearchFoundCanonicalName -inotcontains $Computer.Name) -and ($Computer.CanonicalName -eq $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [OU/CN]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundCanonicalName += $Computer.Name
                    }
                    if (($SearchFoundIPv4address -inotcontains $Computer.Name) -and ($Computer.IPv4address -eq $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [IP]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundIPv4address += $Computer.Name
                    }
                    if (($SearchFoundMACAddress -inotcontains $Computer.Name) -and ($Computer.MACAddress -eq $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [MAC]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundMACAddress += $Computer.Name
                    }
                    if (($SearchFoundOperatingSystemHotfix -inotcontains $Computer.Name) -and ($Computer.OperatingSystemHotfix -eq $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [HotFix]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundOperatingSystemHotfix += $Computer.Name
                    }
                    if (($SearchFoundOperatingSystemServicePack -inotcontains $Computer.Name) -and ($Computer.OperatingSystemServicePack -eq $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Service Pack]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundOperatingSystemServicePack += $Computer.Name
                    }
                    if (($SearchFoundMemberOf -inotcontains $Computer.Name) -and ($Computer.MemberOf -eq $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Group]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundMemberOf += $Computer.Name
                    }
                    if (($SearchFoundLocation -inotcontains $Computer.Name) -and ($Computer.Location -eq $ComputerSearchText)) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Location]') -Entry $Computer.Name -DoNotPopulateMetadata
                        $SearchFoundLocation += $Computer.Name
                    }
                    if ($Computer.PortScan) {
                        $EndpointPortScanList = $Computer.PortScan.split(",") | Sort-Object
                    }
                    else {
                        $EndpointPortScanList = $null
                    }
                    ForEach ($Port in $EndpointPortScanList) {
                        if (($SearchFoundPortScan -inotcontains $Computer.Name) -and ($Port -eq $ComputerSearchText)) {
                            AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Port Scan]') -Entry $Computer.Name -DoNotPopulateMetadata
                            $SearchFoundPortScan += $Computer.Name
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
                                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Process]') -Entry $PSComputerName -DoNotPopulateMetadata
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
                                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Service]') -Entry $PSComputerName -DoNotPopulateMetadata
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
                                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:ComputerListSearch -Category $($ComputerSearchText + ' [Network]') -Entry $PSComputerName -DoNotPopulateMetadata
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
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
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
}



# SIG # Begin signature block
# MIIFuAYJKoZIhvcNAQcCoIIFqTCCBaUCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUuRuTIsWbwJZQrRCPPWrHz46Z
# 5eagggM6MIIDNjCCAh6gAwIBAgIQVnYuiASKXo9Gly5kJ70InDANBgkqhkiG9w0B
# AQUFADAzMTEwLwYDVQQDDChQb1NoLUVhc3lXaW4gQnkgRGFuIEtvbW5pY2sgKGhp
# Z2gxMDFicm8pMB4XDTIxMTEyOTIzNDA0NFoXDTMxMTEyOTIzNTA0M1owMzExMC8G
# A1UEAwwoUG9TaC1FYXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANUnnNeIFC/eQ11BjDFsIHp1
# 2HkKgnRRV07Kqsl4/fibnbOclptJbeKBDQT3iG5csb31s9NippKfzZmXfi69gGE6
# v/L3X4Zb/10SJdFLstfT5oUD7UdiOcfcNDEiD+8OpZx4BWl5SNWuSv0wHnDSIyr1
# 2M0oqbq6WA2FqO3ETpdhkK22N3C7o+U2LeuYrGxWOi1evhIHlnRodVSYcakmXIYh
# pnrWeuuaQk+b5fcWEPClpscI5WiQh2aohWcjSlojsR+TiWG/6T5wKFxSJRf6+exu
# C0nhKbyoY88X3y/6qCBqP6VTK4C04tey5z4Ux4ibuTDDePqH5WpRFMo9Vie1nVkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS2KLS0Frf3zyJTbQ4WsZXtnB9SFDANBgkqhkiG9w0BAQUFAAOCAQEA
# s/TfP54uPmv+yGI7wnusq3Y8qIgFpXhQ4K6MmnTUpZjbGc4K3DRJyFKjQf8MjtZP
# s7CxvS45qLVrYPqnWWV0T5NjtOdxoyBjAvR/Mhj+DdptojVMMp2tRNPSKArdyOv6
# +yHneg5PYhsYjfblzEtZ1pfhQXmUZo/rW2g6iCOlxsUDr4ZPEEVzpVUQPYzmEn6B
# 7IziXWuL31E90TlgKb/JtD1s1xbAjwW0s2s1E66jnPgBA2XmcfeAJVpp8fw+OFhz
# Q4lcUVUoaMZJ3y8MfS+2Y4ggsBLEcWOK4vGWlAvD5NB6QNvouND1ku3z94XmRO8v
# bqpyXrCbeVHascGVDU3UWTGCAegwggHkAgEBMEcwMzExMC8GA1UEAwwoUG9TaC1F
# YXN5V2luIEJ5IERhbiBLb21uaWNrIChoaWdoMTAxYnJvKQIQVnYuiASKXo9Gly5k
# J70InDAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAigAoAAoQKAADAZBgkq
# hkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgELMQ4wDAYKKwYBBAGC
# NwIBFTAjBgkqhkiG9w0BCQQxFgQUlCCYOE/DGBjbE6pXbwUYFeG01FcwDQYJKoZI
# hvcNAQEBBQAEggEAuThVqmkBvgBQQNRaEz6y/memBRGy9RTPh/+h/VBdHUEpJ5CY
# jFvv/YWCe9XlAwqbayPPqM21k26eIofPiM5FHvKX+eLo4AuHUS1vEg9tsj9kp74z
# 0NJ0hzjOCDXcWt8F05V2fEdLStYwVTNG5+XqWI9WGIC9EbCBlXN3nCWSZdcP3T28
# 65NrLEGCDZFUPFydwj+mNWc561mWJ63KfPg0akx1GBh1fziONgPMFeoUOx34zpia
# FeK4XNcXskgPsg+E/owoGoB5FdZj5DY3p/tIsRRDftsyKF4Uco55LV4q/FH2mGFg
# THrIqqjdJExHWOtQMII3ZnnyuuqfRB23gs//bQ==
# SIG # End signature block
