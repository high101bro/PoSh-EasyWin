$ComputerListDeleteButtonAdd_Click = {
    # This brings specific tabs to the forefront/front view
    $Section4TabControl.SelectedTab = $Section3ResultsTab

    Create-ComputerNodeCheckBoxArray 
    if ($script:ComputerTreeViewSelected.count -gt 0) {
        # Removes selected computer nodes
        foreach ($i in $script:ComputerTreeViewSelected) {
            [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes 
            foreach ($root in $AllHostsNode) {
                foreach ($Category in $root.Nodes) { 
                    foreach ($Entry in $Category.nodes) { 
                        if (($i -eq $Entry.text) -and ($Entry.Checked)) {
                            # Removes the node from the treeview
                            $Entry.remove()
                            # Removes the host from the variable storing the all the computers
                            $script:ComputerTreeViewData = $script:ComputerTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                        }
                    }
                }
            }
        }
        # Removes selected category nodes - Note: had to put this in its own loop... 
        # the saving of nodes didn't want to work properly when use in the above loop when switching between treenode views.
        foreach ($i in $script:ComputerTreeViewSelected) {
            foreach ($root in $AllHostsNode) {
                foreach ($Category in $root.Nodes) { 
                    if (($i -eq $Category.text) -and ($Category.Checked)) { $Category.remove() }
                }
            }
        }
        # Removes selected root node - Note: had to put this in its own loop... see above category note
        foreach ($i in $script:ComputerTreeViewSelected) {
            foreach ($root in $AllHostsNode) {                
                if (($i -eq $root.text) -and ($root.Checked)) {
                    foreach ($Category in $root.Nodes) { $Category.remove() }
                    $root.remove()
                    if ($i -eq "All Hosts") { $script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList) }                                    
                }
            }
        }

        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Deleted:  $($script:ComputerTreeViewSelected.Count) Selected Items")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("The following hosts have been deleted:  ")
        $ComputerListDeletedArray = @()
        foreach ($Node in $script:ComputerTreeViewSelected) { 
            if ($Node -notin $ComputerListDeletedArray) {
                $ComputerListDeletedArray += $Node
                $ResultsListBox.Items.Add(" - $Node") 
            }
        }
        $script:ComputerTreeView.Nodes.Clear()
        Initialize-ComputerTreeNodes
        Foreach($Computer in $script:ComputerTreeViewData) { Add-ComputerTreeNode -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip $Computer.IPv4Address }
        KeepChecked-ComputerTreeNode -NoMessage
        $script:ComputerTreeView.ExpandAll()
        AutoSave-HostData
        Update-NeedToSaveTreeView
    } # END if statement
    else { ComputerNodeSelectedLessThanOne -Message 'Delete Selection' }
}
