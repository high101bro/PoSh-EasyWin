Function Import-DataFromCsv {
    param(
        [switch]$Endpoint,
        [switch]$Accounts
    )

    if ($Endpoint){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
        $InformationTabControl.SelectedTab = $Section3ResultsTab
    
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $ComputerTreeNodeImportCsvOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Import .csv Data"
            InitialDirectory = "$PoShHome"
            filter           = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $ComputerTreeNodeImportCsvOpenFileDialog.ShowDialog() | Out-Null
        $ComputerTreeNodeImportCsv = Import-Csv $($ComputerTreeNodeImportCsvOpenFileDialog.filename) | Select-Object -Property Name, IPv4Address, MACAddress, OperatingSystem, CanonicalName | Sort-Object -Property CanonicalName
    
        $StatusListBox.Items.Clear()
        #Removed For Testing#
        $ResultsListBox.Items.Clear()
    
        # Imports data
        foreach ($Computer in $ComputerTreeNodeImportCsv) {
            # Checks if data already exists
            if ($script:ComputerTreeViewData.Name -contains $Computer.Name) {
                Message-NodeAlreadyExists -Endpoint -Message "Import .CSV:  Warning" -Computer $Computer.Name -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
    
                $CanonicalName = $($($Computer.CanonicalName) -replace $Computer.Name,"" -replace $Computer.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Computer.CanonicalName -eq "") { AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address }
                else { AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address }
    
                $script:ComputerTreeViewData += $Computer
    
                $script:ComputerTreeView.Nodes.Clear()
                Initialize-TreeViewData -Endpoint
                UpdateState-TreeViewData -Endpoint -NoMessage
                Normalize-TreeViewData -Endpoint
                Foreach($Computer in $script:ComputerTreeViewData) { AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $ComputerData.IPv4Address -IPv4Address $Computer.IPv4Address }
                $script:ComputerTreeView.ExpandAll()
            }
        }
        Save-TreeViewData -Endpoint   
    }
    elseif ($Accounts){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
        $InformationTabControl.SelectedTab = $Section3ResultsTab
        
        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $AccountsTreeNodeImportCsvOpenFileDialog                  = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Import .csv Data"
            InitialDirectory = "$PoShHome"
            filter           = "CSV (*.csv)| *.csv|Excel (*.xlsx)| *.xlsx|Excel (*.xls)| *.xls|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $AccountsTreeNodeImportCsvOpenFileDialog.ShowDialog() | Out-Null
        $AccountsTreeNodeImportCsv = Import-Csv $($AccountsTreeNodeImportCsvOpenFileDialog.filename) | Select-Object -Property Name, IPv4Address, MACAddress, OperatingSystem, CanonicalName | Sort-Object -Property CanonicalName
        
        $StatusListBox.Items.Clear()
        #Removed For Testing#
        $ResultsListBox.Items.Clear()
        
        # Imports data
        foreach ($Account in $AccountsTreeNodeImportCsv) {
            # Checks if data already exists
            if ($script:AccountsTreeViewData.Name -contains $Account.Name) {
                Message-NodeAlreadyExists -Accounts -Message "Import .CSV:  Warning" -Account $Account.Name -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'
        
                $CanonicalName = $($($Account.CanonicalName) -replace $Account.Name,"" -replace $Account.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Account.CanonicalName -eq "") { AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category '/Unknown' -Entry $Account.Name -ToolTip $Account.SID }
                else { AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $CanonicalName -Entry $Account.Name -ToolTip $Account.SID }
        
                $script:AccountsTreeViewData += $Account
        
                $script:AccountsTreeView.Nodes.Clear()
                Initialize-TreeViewData -Accounts
                UpdateState-TreeViewData -Accounts -NoMessage
                Normalize-TreeViewData -Accounts
                Foreach($Account in $script:AccountsTreeViewData) { AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Account.CanonicalName -Entry $Account.Name -ToolTip $Account.SID }
                $script:AccountsTreeView.ExpandAll()
            }
        }
        Save-TreeViewData -Accounts
    }
}