$ComputerTreeNodeOSHostnameRadioButtonAdd_Click = {
    $ComputerTreeNodeCollapseAllButton.Text = "Collapse"
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Treeview:  Operating Systems")

    # This variable stores data on checked checkboxes, so boxes checked remain among different views
    $script:ComputerTreeViewSelected = @()

    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
    foreach ($root in $AllHostsNode) {
        foreach ($Category in $root.Nodes) {
            foreach ($Entry in $Category.nodes) {
                if ($Entry.Checked) {
                    $script:ComputerTreeViewSelected += $Entry.Text
                }
            }
        }
    }

    $script:ComputerTreeView.Nodes.Clear()
    Initialize-ComputerTreeNodes
    Populate-ComputerTreeNodeDefaultData
    Save-HostData
    AutoSave-HostData

    Foreach($Computer in $script:ComputerTreeViewData) {
        Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Computer.OperatingSystem -Entry $Computer.Name -ToolTip $Computer.IPv4Address -Metadata $Computer
    }
    Update-TreeNodeComputerState
    Conduct-NodeAction
}

$ComputerTreeNodeOSHostnameRadioButtonAdd_MouseHover = {
    Show-ToolTip -Title "Operating System View" -Icon "Info" -Message @"
+  Displays the hosts by Operating Systems.
+  Hosts will remain checked when switching between views.
"@
}


