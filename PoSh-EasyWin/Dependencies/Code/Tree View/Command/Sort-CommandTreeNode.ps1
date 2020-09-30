function Sort-CommandTreeNode {
    # This variable stores data on checked checkboxes, so boxes checked remain among different views
    $script:CommandsCheckedBoxesSelected = @()

    if ($CommandsViewMethodRadioButton.checked) {
        [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
        foreach ($root in $AllCommandsNode) {
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.Checked) { $script:CommandsCheckedBoxesSelected += $Entry.Text }
                }
            }
        }
        $script:CommandsTreeView.Nodes.Clear()
        Initialize-CommandTreeNodes
        AutoSave-HostData
        View-CommandTreeNodeMethod
        Update-TreeNodeCommandState
        Update-QueryHistory
    }
    elseif ($CommandsViewQueryRadioButton.checked) {
        [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes
        foreach ($root in $AllCommandsNode) {
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.Checked) {
                        $script:CommandsCheckedBoxesSelected += $Entry.Text
                    }
                }
            }
        }
        $script:CommandsTreeView.Nodes.Clear()
        Initialize-CommandTreeNodes
        AutoSave-HostData
        View-CommandTreeNodeQuery
        Update-TreeNodeCommandState
        Update-QueryHistory
    }

    Conduct-NodeAction -TreeView $script:CommandsTreeView.Nodes -Commands
    Start-Sleep -Seconds  1
}

