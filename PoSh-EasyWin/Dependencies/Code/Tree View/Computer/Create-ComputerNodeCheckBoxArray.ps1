function Create-ComputerNodeCheckBoxArray {
    # This array stores checkboxes that are check; a minimum of at least one checkbox will be needed later in the script
    $script:ComputerTreeViewSelected = @()
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
    foreach ($root in $AllHostsNode) {
        if ($root.Checked) {
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.nodes) {
                    $script:ComputerTreeViewSelected += $Entry.Text
                }
            }
        }
        else {
            foreach ($Category in $root.Nodes) {
                if ($Category.Checked) {
                    foreach ($Entry in $Category.nodes) { $script:ComputerTreeViewSelected += $Entry.Text }
                }
                else {
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.Checked) {
                            $script:ComputerTreeViewSelected += $Entry.Text
                        }
                    }
                }
            }
        }
    }
    $script:ComputerTreeViewSelected = $script:ComputerTreeViewSelected | Select-Object -Unique
    #return $script:ComputerTreeViewSelected
}



