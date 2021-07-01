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
                if ($Computer.CanonicalName -eq "") { AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer.Name -ToolTip 'No ToolTip Data' -IPv4Address $Computer.IPv4Address }
                else { AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $CanonicalName -Entry $Computer.Name -ToolTip 'No ToolTip Data' -IPv4Address $Computer.IPv4Address }
    
                $script:ComputerTreeViewData += $Computer
    
                $script:ComputerTreeView.Nodes.Clear()
                Initialize-TreeViewData -Endpoint
                UpdateState-TreeViewData -Endpoint -NoMessage
                Normalize-TreeViewData -Endpoint
                Foreach($Computer in $script:ComputerTreeViewData) { AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip 'No ToolTip Data' -IPv4Address $Computer.IPv4Address }
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
        foreach ($Accounts in $AccountsTreeNodeImportCsv) {
            # Checks if data already exists
            if ($script:AccountsTreeViewData.Name -contains $Accounts.Name) {
                Message-NodeAlreadyExists -Accounts -Message "Import .CSV:  Warning" -Account $Accounts.Name -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'
        
                $CanonicalName = $($($Accounts.CanonicalName) -replace $Accounts.Name,"" -replace $Accounts.CanonicalName.split('/')[0],"").TrimEnd("/")
                if ($Accounts.CanonicalName -eq "") { AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category '/Unknown' -Entry $Accounts.Name -ToolTip 'No ToolTip Data' -IPv4Address $Accounts.IPv4Address }
                else { AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $CanonicalName -Entry $Accounts.Name -ToolTip 'No ToolTip Data' -IPv4Address $Accounts.IPv4Address }
        
                $script:AccountsTreeViewData += $Accounts
        
                $script:AccountsTreeView.Nodes.Clear()
                Initialize-TreeViewData -Accounts
                UpdateState-TreeViewData -Accounts -NoMessage
                Normalize-TreeViewData -Accounts
                Foreach($Accounts in $script:AccountsTreeViewData) { AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Accounts.CanonicalName -Entry $Accounts.Name -ToolTip 'No ToolTip Data' -IPv4Address $Accounts.IPv4Address }
                $script:AccountsTreeView.ExpandAll()
            }
        }
        Save-TreeViewData -Accounts
    }
}