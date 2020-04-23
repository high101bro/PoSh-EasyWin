function Move-ComputerTreeNodeSelected {                       
    # Makes a copy of the checkboxed node name in the new Category
    $ComputerTreeNodeToMove = New-Object System.Collections.ArrayList

    function Copy-TreeViewNode {
        # Adds (copies) the node to the new Category
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes 
        foreach ($root in $AllHostsNode) { 
            if ($root.Checked) { $root.Checked = $false }
            foreach ($Category in $root.Nodes) { 
                if ($Category.Checked) { $Category.Checked = $false }
                foreach ($Entry in $Category.nodes) { 
                    if ($Entry.Checked) {
                        Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $ComputerTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Data Available"
                        $ComputerTreeNodeToMove.Add($Entry.text)
                    }
                }
            }
        }
        Update-NeedToSaveTreeView
    }
    if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
        Copy-TreeViewNode
        # Removes the original hostname/IP that was copied above
        foreach ($i in $ComputerTreeNodeToMove) {
            foreach ($root in $AllHostsNode) { 
                foreach ($Category in $root.Nodes) { 
                    foreach ($Entry in $Category.nodes) { 
                        if (($i -contains $Entry.text) -and ($Entry.Checked)) {
                            $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem = $ComputerTreeNodePopupMoveComboBox.SelectedItem
                            $ResultsListBox.Items.Add($Entry.text)
                            $Entry.remove()
                        }
                    }
                }
            }
        }
    }
    elseif ($ComputerTreeNodeOUHostnameRadioButton.Checked) {
        Copy-TreeViewNode                
        # Removes the original hostname/IP that was copied above
        foreach ($i in $ComputerTreeNodeToMove) {
            foreach ($root in $AllHostsNode) { 
                foreach ($Category in $root.Nodes) { 
                    foreach ($Entry in $Category.nodes) { 
                        if (($i -contains $Entry.text) -and ($Entry.Checked)) {
                            $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $ComputerTreeNodePopupMoveComboBox.SelectedItem
                            $ResultsListBox.Items.Add($Entry.text)
                            $Entry.remove()
                        }
                    }
                }
            }
        }
    }
    # Checks if the category node is empty, if so the node is removed
    [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
    foreach ($root in $AllHostsNode) { 
        foreach ($Category in $root.Nodes) { 
            $CategoryNodeContentCount = 0
            # Counts the number of computer nodes in each category
            foreach ($Entry in $Category.nodes) { $CategoryNodeContentCount += 1 }
            # Removes a category node if it is empty
            if ($CategoryNodeContentCount -eq 0) { $Category.remove() }
        }
    }
    $ComputerTreeNodePopup.close()        
}