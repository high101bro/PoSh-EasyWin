function Show-MoveForm {
    param(
        $FormTitleEndpoints,
        [switch]$SelectedEndpoint
    )
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Move Selection:  ")

    #----------------------------------
    # ComputerList TreeView Popup Form
    #----------------------------------
    $ComputerTreeNodePopup = New-Object system.Windows.Forms.Form -Property @{
        Text          = "Move"
        Size          = New-Object System.Drawing.Size(($FormScale * 330),($FormScale * 107))
        StartPosition = "CenterScreen"
        Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
        Add_Closing = { $This.dispose() }
    }
    $ComputerTreeNodePopup.Text = $FormTitleEndpoints

    #----------------------------------------------
    # ComputerList TreeView Popup Execute ComboBox
    #----------------------------------------------
    $ComputerTreeNodePopupMoveComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text     = "Select A Category"
        Location = @{ X = $FormScale * 10
                      Y = $FormScale * 10 }
        Size     = @{ Width  = $FormScale * 300
                      Height = $FormScale * 25 }
        AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    }
    # Dynamically creates the combobox's Category list used for the move destination
    $ComputerTreeNodeCategoryList = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
    ForEach ($root in $AllHostsNode) { foreach ($Category in $root.Nodes) { $ComputerTreeNodeCategoryList += $Category.text } }
    ForEach ($Item in $ComputerTreeNodeCategoryList) { $ComputerTreeNodePopupMoveComboBox.Items.Add($Item) }

    # Moves the hostname/IPs to the new Category
    $ComputerTreeNodePopupMoveComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") {
        if ($SelectedEndpoint){ Move-ComputerTreeNodeSelected -SelectedEndpoint }
        else { Move-ComputerTreeNodeSelected }
    } })
    $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupMoveComboBox)

    #--------------------------------------------
    # ComputerList TreeView Popup Execute Button
    #--------------------------------------------
    $ComputerTreeNodePopupExecuteButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Execute"
        Location = @{ X = $FormScale * 210
                      Y = $ComputerTreeNodePopupMoveComboBox.Size.Height + ($FormScale * 15) }
        Size     = @{ Width  = $FormScale * 100
                      Height = $FormScale * 25 }
    }
    CommonButtonSettings -Button $ComputerTreeNodePopupExecuteButton
    $ComputerTreeNodePopupExecuteButton.Add_Click({
        # This brings specific tabs to the forefront/front view
        $MainBottomTabControl.SelectedTab = $Section3ResultsTab
        if ($SelectedEndpoint){ Move-ComputerTreeNodeSelected -SelectedEndpoint }
        else { Move-ComputerTreeNodeSelected }
        $ComputerTreeNodePopup.close()
    })
    $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupExecuteButton)
    $ComputerTreeNodePopup.ShowDialog()

}





$ComputerListMoveSelectedToolStripButtonAdd_Click = {
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab

    Create-ComputerNodeCheckBoxArray
    if ($script:EntrySelected) {
        Show-MoveForm -FormTitleEndpoints "Move: $($script:EntrySelected.Text)" -SelectedEndpoint

        $script:ComputerTreeView.Nodes.Clear()
        Initialize-ComputerTreeNodes

        if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
            Foreach($Computer in $script:ComputerTreeViewData) {
                Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address  -Metadata $Computer
            }
        }
        elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked) {
            Foreach($Computer in $script:ComputerTreeViewData) {
                Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address  -Metadata $Computer
            }
        }
        Remove-EmptyCategory
        Save-HostData
        Update-TreeNodeComputerState -NoMessage

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Moved:  $($script:EntrySelected.text)")
    }
}





$ComputerListMoveAllCheckedToolStripButtonAdd_Click = {
    Create-ComputerNodeCheckBoxArray

    if ($script:ComputerTreeViewSelected.count -eq 0){
        [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Move All')
    }
    else {
        $MainBottomTabControl.SelectedTab = $Section3ResultsTab

        Create-ComputerNodeCheckBoxArray
        if ($script:ComputerTreeViewSelected.count -ge 0) {
            Show-MoveForm -FormTitleEndpoints "Moving $($script:ComputerTreeViewSelected.count) Endpoints"

            $script:ComputerTreeView.Nodes.Clear()
            Initialize-ComputerTreeNodes

            if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
                Foreach($Computer in $script:ComputerTreeViewData) {
                    Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address  -Metadata $Computer
                }
            }
            elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked) {
                Foreach($Computer in $script:ComputerTreeViewData) {
                    Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address  -Metadata $Computer
                }
            }

            Remove-EmptyCategory
            AutoSave-HostData
            Save-HostData
            Update-TreeNodeComputerState -NoMessage

            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Moved $($script:ComputerTreeNodeToMove.Count) Endpoints")
            #Removed For Testing#$ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("The following hostnames/IPs have been moved to $($ComputerTreeNodePopupMoveComboBox.SelectedItem):")
        }
        else { ComputerNodeSelectedLessThanOne -Message 'Move Selection' }
    }
}


