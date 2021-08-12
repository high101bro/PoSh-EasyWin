function Remove-EmptyCategory {
    param(
        [switch]$Accounts,
        [switch]$Endpoint
    )
    if ($Accounts) {
        # Checks if the category node is empty, if so the node is removed
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
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
    }
    if ($Endpoint) {
        # Checks if the category node is empty, if so the node is removed
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
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
    }

    #   $ComputerTreeNodePopup.close()
}

