$ComputerTreeNodeCollapseAllButtonAdd_Click = {
    if ($ComputerTreeNodeCollapseAllButton.Text -eq "Collapse") {
        $script:ComputerTreeView.CollapseAll()
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes 
        foreach ($root in $AllHostsNode) { 
            $root.Expand()
        }
        $ComputerTreeNodeCollapseAllButton.Text = "Expand"
    }
    elseif ($ComputerTreeNodeCollapseAllButton.Text -eq "Expand") {
        $script:ComputerTreeView.ExpandAll()
        $ComputerTreeNodeCollapseAllButton.Text = "Collapse"
    }
}
