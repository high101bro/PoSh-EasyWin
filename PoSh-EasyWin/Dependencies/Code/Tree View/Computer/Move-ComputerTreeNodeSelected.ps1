function Move-ComputerTreeNodeSelected {
    param(
        [switch]$SelectedEndpoint
    )
    # Makes a copy of the checkboxed node name in the new Category
    $script:ComputerTreeNodeToMove = New-Object System.Collections.ArrayList


    if ($SelectedEndpoint){
        function Copy-TreeViewNodeSelected {
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
            foreach ($root in $AllHostsNode) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.text -eq $script:EntrySelected.text) {
                            Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $ComputerTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Data Available"
                            $script:ComputerTreeNodeToMove.Add($Entry.text)
                            break
                        }
                    }
                }
            }
        }
        if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
            Copy-TreeViewNodeSelected
            # Removes the original hostname/IP that was copied above
            foreach ($i in $script:ComputerTreeNodeToMove) {
                foreach ($root in $AllHostsNode) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if (($i -contains $Entry.text) -and ($Entry.text -eq $script:EntrySelected.text)) {
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
            Copy-TreeViewNodeSelected
            # Removes the original hostname/IP that was copied above
            foreach ($i in $script:ComputerTreeNodeToMove) {
                foreach ($root in $AllHostsNode) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if (($i -contains $Entry.text) -and ($Entry.text -eq $script:EntrySelected.text)) {
                                $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $ComputerTreeNodePopupMoveComboBox.SelectedItem
                                $ResultsListBox.Items.Add($Entry.text)
                                $Entry.remove()
                            }
                        }
                    }
                }
            }
        }
    }
    else {
        function Copy-TreeViewNodeChecked {
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
            foreach ($root in $AllHostsNode) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.Checked) {
                            Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $ComputerTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Data Available"
                            $script:ComputerTreeNodeToMove.Add($Entry.text)
                        }
                    }
                }
            }
        }
        if ($ComputerTreeNodeOSHostnameRadioButton.Checked) {
            Copy-TreeViewNodeChecked
            # Removes the original hostname/IP that was copied above
            foreach ($i in $script:ComputerTreeNodeToMove) {
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
            Copy-TreeViewNodeChecked
            # Removes the original hostname/IP that was copied above
            foreach ($i in $script:ComputerTreeNodeToMove) {
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
    }

    Remove-EmptyCategory
    AutoSave-HostData
    Save-HostData
}


