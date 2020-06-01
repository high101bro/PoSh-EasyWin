function Remove-EmptyCategory {
    # Checks if the category node is empty, if so the node is removed
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
    foreach ($root in $AllHostsNode) { 
        foreach ($Category in $root.Nodes) { 
            [int]$CategoryNodeContentCount = 0
            # Counts the number of computer nodes in each category
            foreach ($Entry in $Category.nodes) { 
                if ($Entry.Test -ne '' -and $Entry.Text -ne $null){
                    $CategoryNodeContentCount += 1
                }
            }
            # Removes a category node if it is empty
            if ($CategoryNodeContentCount -eq 0 ) { 
                $Category.remove() 
            }
        }
    }
 #   $ComputerTreeNodePopup.close()
}