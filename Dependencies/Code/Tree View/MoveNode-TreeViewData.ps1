function MoveNode-TreeViewData {
    param(
        [switch]$Accounts,
        [switch]$Endpoint,
        [switch]$SelectedAccounts,
        [switch]$SelectedEndpoint
    )
    if ($Accounts) {
        # Makes a copy of the checkboxed node name in the new Category
        $script:AccountsTreeNodeToMove = New-Object System.Collections.ArrayList

        if ($SelectedAccounts){
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.text -eq $script:EntrySelected.text) {
                            AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $AccountsTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Data Available"
                            $script:AccountsTreeNodeToMove.Add($Entry.text)
                            break
                        }
                    }
                }
            }

            # Removes the original Account that was copied above
            foreach ($i in $script:AccountsTreeNodeToMove) {
                foreach ($root in $AllTreeViewNodes) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if (($i -contains $Entry.text) -and ($Entry.text -eq $script:EntrySelected.text)) {
                                $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $AccountsTreeNodePopupMoveComboBox.SelectedItem
                                $ResultsListBox.Items.Add($Entry.text)
                                $Entry.remove()
                            }
                        }
                    }
                }
            }
        }
        else {
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.Checked) {
                            AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $AccountsTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Data Available"
                            $script:AccountsTreeNodeToMove.Add($Entry.text)
                        }
                    }
                }
            }

            $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
            $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'

            # Removes the original Account that was copied above
            foreach ($i in $script:AccountsTreeNodeToMove) {
                foreach ($root in $AllTreeViewNodes) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if (($i -contains $Entry.text) -and ($Entry.Checked)) {
                                $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName = $AccountsTreeNodePopupMoveComboBox.SelectedItem
                                $ResultsListBox.Items.Add($Entry.text)
                                $Entry.remove()
                            }
                        }
                    }
                }
            }
        }

        Remove-EmptyCategory -Accounts
        Save-TreeViewData -Accounts
    }
    if ($Endopint) {
        # Makes a copy of the checkboxed node name in the new Category
        $script:ComputerTreeNodeToMove = New-Object System.Collections.ArrayList

        if ($SelectedEndpoint){
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.text -eq $script:EntrySelected.text) {
                            AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $ComputerTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Data Available"
                            $script:ComputerTreeNodeToMove.Add($Entry.text)
                            break
                        }
                    }
                }
            }

            # Removes the original hostname/IP that was copied above
            foreach ($i in $script:ComputerTreeNodeToMove) {
                foreach ($root in $AllTreeViewNodes) {
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
        else {
            # Adds (copies) the node to the new Category
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {
                if ($root.Checked) { $root.Checked = $false }
                foreach ($Category in $root.Nodes) {
                    if ($Category.Checked) { $Category.Checked = $false }
                    foreach ($Entry in $Category.nodes) {
                        if ($Entry.Checked) {
                            AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $ComputerTreeNodePopupMoveComboBox.SelectedItem -Entry $Entry.text #-ToolTip "No Data Available"
                            $script:ComputerTreeNodeToMove.Add($Entry.text)
                        }
                    }
                }
            }

            $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
            $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

            # Removes the original hostname/IP that was copied above
            foreach ($i in $script:ComputerTreeNodeToMove) {
                foreach ($root in $AllTreeViewNodes) {
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

        Remove-EmptyCategory -Endpoint
        Save-TreeViewData -Endpoint
    }
}


