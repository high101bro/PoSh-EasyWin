$ComputerTreeNodeImportTxtButtonAdd_Click = {
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
    $ResultsListBox.Items.Clear()

    foreach ($Computer in $ComputerTreeNodeImportTxt) {
        # Checks if the data already exists
        if ($script:ComputerTreeViewData.Name -contains $Computer) {
            Message-HostAlreadyExists -Message "Import .CSV:  Warning" -Computer $Computer
        }
        else {
            if ($ComputerTreeNodeOSHostnameRadioButton.Checked -and $Computer -ne "") {
                Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category 'Unknown' -Entry $Computer -ToolTip 'N/A'
            }
            elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked -and $Computer -ne "") {
                Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category '/Unknown' -Entry $Computer -ToolTip 'N/A'
            }
            $script:ComputerTreeViewData += [PSCustomObject]@{
                Name            = $Computer
                OperatingSystem = 'Unknown'
                CanonicalName   = '/Unknown'
                IPv4Address     = 'N/A'
                MACAddress      = 'N/A'
            }
            $script:ComputerTreeView.Nodes.Clear()
            Initialize-ComputerTreeNodes
            KeepChecked-ComputerTreeNode -NoMessage
            Populate-ComputerTreeNodeDefaultData
            Foreach($Computer in $script:ComputerTreeViewData) { Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
            $script:ComputerTreeView.ExpandAll()
            AutoSave-HostData
            Update-NeedToSaveTreeView
        }
    }
}
