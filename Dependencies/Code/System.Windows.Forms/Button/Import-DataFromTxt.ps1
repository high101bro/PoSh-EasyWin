Function Import-DataFromTxt {
    param(
        [switch]$Endpoint,
        [switch]$Accounts
    )

    if ($Endpoint){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab

        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $ComputerTreeNodeImportTxtOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Import .txt Data"
            InitialDirectory = "$PoShHome"
            filter           = "TXT (*.txt)| *.txt|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $ComputerTreeNodeImportTxtOpenFileDialog.ShowDialog() | Out-Null
        $ComputerTreeNodeImportTxt = Get-Content $($ComputerTreeNodeImportTxtOpenFileDialog.filename)
    
        $StatusListBox.Items.Clear()
        #Removed For Testing#
        $ResultsListBox.Items.Clear()
    
        foreach ($Computer in $($ComputerTreeNodeImportTxt | Where-Object {$_ -ne ''}) ) {
            # Checks if the data already exists
            if ($script:ComputerTreeViewData.Name -contains $Computer) {
                Message-NodeAlreadyExists -Endpoint -Message "Import .CSV:  Warning" -Computer $Computer -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
    
                AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer -ToolTip 'N/A'
    
                $script:ComputerTreeViewData += [PSCustomObject]@{
                    Name            = $Computer
                    OperatingSystem = 'Unknown'
                    CanonicalName   = '/Unknown'
                    IPv4Address     = 'N/A'
                    MACAddress      = 'N/A'
                }
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
    if ($Accounts){
        $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab

        [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
        $AccountsTreeNodeImportTxtOpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog -Property @{
            Title            = "Import .txt Data"
            InitialDirectory = "$PoShHome"
            filter           = "TXT (*.txt)| *.txt|All files (*.*)|*.*"
            ShowHelp         = $true
        }
        $AccountsTreeNodeImportTxtOpenFileDialog.ShowDialog() | Out-Null
        $AccountsTreeNodeImportTxt = Get-Content $($AccountsTreeNodeImportTxtOpenFileDialog.filename)
    
        $StatusListBox.Items.Clear()
        #Removed For Testing#
        $ResultsListBox.Items.Clear()
    
        foreach ($Accounts in $($AccountsTreeNodeImportTxt | Where-Object {$_ -ne ''}) ) {
            # Checks if the data already exists
            if ($script:AccountsTreeViewData.Name -contains $Accounts) {
                Message-NodeAlreadyExists -Accounts -Message "Import .CSV:  Warning" -Account $Accounts -ResultsListBoxMessage
            }
            else {
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'
    
                AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category '/Unknown' -Entry $Accounts -ToolTip 'N/A'
    
                $script:AccountsTreeViewData += [PSCustomObject]@{
                    Name            = $Accounts
                    OperatingSystem = 'Unknown'
                    CanonicalName   = '/Unknown'
                    IPv4Address     = 'N/A'
                    MACAddress      = 'N/A'
                }
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