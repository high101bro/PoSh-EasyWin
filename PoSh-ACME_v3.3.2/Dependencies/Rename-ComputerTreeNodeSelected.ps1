function Rename-ComputerTreeNodeSelected {                       
    if ($script:ComputerTreeNodeData.Name -contains $ComputerTreeNodeRenamePopupTextBox.Text) {
        Message-HostAlreadyExists -Message "Rename Hostname/IP:  Error"
    }
    else {
        # Makes a copy of the checkboxed node name in the new Category
        $ComputerTreeNodeToRename = New-Object System.Collections.ArrayList

        # Adds (copies) the node to the new Category
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeNode.Nodes 
        foreach ($root in $AllHostsNode) { 
            if ($root.Checked) { $root.Checked = $false }
            foreach ($Category in $root.Nodes) { 
                if ($Category.Checked) { $Category.Checked = $false }
                foreach ($Entry in $Category.nodes) { 
                    if ($Entry.Checked) {
                        Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $Category.Text -Entry $ComputerTreeNodeRenamePopupTextBox.text #-ToolTip "No Data Available"
                        $ComputerTreeNodeToRename.Add($Entry.text)
                    }
                }
            }
        }
        # Removes the original hostname/IP that was copied above
        foreach ($i in $ComputerTreeNodeToRename) {
            foreach ($root in $AllHostsNode) { 
                foreach ($Category in $root.Nodes) { 
                    foreach ($Entry in $Category.nodes) { 
                        if (($i -contains $Entry.text) -and ($Entry.Checked)) {
                            $($script:ComputerTreeNodeData | Where-Object {$_.Name -eq $Entry.Text}).Name = $ComputerTreeNodeRenamePopupTextBox.text
                            $ResultsListBox.Items.Add($Entry.text)
                            $Entry.remove()
                        }
                    }
                }
            }
        }
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Rename Selection:  $($ComputerTreeNodeToRename.Count) Hosts")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("The computer has been renamed to $($ComputerTreeNodeRenamePopupTextBox.Text)")
        Update-NeedToSaveTreeView
    }
    $ComputerTreeNodeRenamePopup.close()
}