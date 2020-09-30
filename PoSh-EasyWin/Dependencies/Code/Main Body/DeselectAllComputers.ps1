function Deselect-AllComputers {
    #$script:ComputerTreeView.Nodes.Clear()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
    foreach ($root in $AllHostsNode) {
        #if ($root.Checked) { $root.Checked = $false }
        $root.Checked = $false
        foreach ($Category in $root.Nodes) {
            #if ($Category.Checked) { $Category.Checked = $false }
            $Category.Checked = $false
            foreach ($Entry in $Category.nodes) {
                #if ($Entry.Checked) { $Entry.Checked = $false }
                $Entry.Checked = $false
                $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }
    Conduct-NodeAction -TreeView $script:ComputerTreeView.Nodes -ComputerList
}


