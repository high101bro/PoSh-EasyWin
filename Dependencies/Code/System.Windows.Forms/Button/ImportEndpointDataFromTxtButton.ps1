$ImportEndpointDataFromTxtButtonAdd_Click = {
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



$ImportEndpointDataFromTxtButtonAdd_MouseHover = {
    Show-ToolTip -Title "Import From TXT File" -Icon "Info" -Message @"
+  Imports data from a selected Text file
+  Useful if you recieve a computer list file from an Admin or outputted from nmap
+  This file should be formatted with one hostname or IP address per line
"@
}





