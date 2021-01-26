$ComputerListCollapseToolStripButtonAdd_Click = {
    if ($script:ExpandCollapseStatus -eq "Collapse") {
        $script:ComputerTreeView.CollapseAll()
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
        foreach ($root in $AllHostsNode) {  $root.Expand() }
        $ComputerListCollapseToolStripButton.Text = "Expand"
        $script:ExpandCollapseStatus = "Expand"
    }
    elseif ($script:ExpandCollapseStatus -eq "Expand") {
        $script:ComputerTreeView.ExpandAll()
        $ComputerListCollapseToolStripButton.Text = "Collapse"
        $script:ExpandCollapseStatus = "Collapse"
    }
}


