$ComputerListDeleteSelectedToolStripButtonAdd_Click = {
    # This brings specific tabs to the forefront/front view
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab

    Create-ComputerNodeCheckBoxArray
    if ($script:EntrySelected) {
        $MessageBox = [System.Windows.MessageBox]::Show("Confirm Deletion of Endpoint Node: $($script:EntrySelected.text)`r`n`r`nAll Endpoint metadata and notes will be lost.`r`n`r`nAny previously collected data will still remain.",'Delete Endpoint','YesNo')

        Switch ( $MessageBox ) {
            'Yes' {
                # Removes selected computer nodes
                [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
                foreach ($root in $AllHostsNode) {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            if ($Entry.text -eq $script:EntrySelected.text) {
                                # Removes the node from the treeview
                                $Entry.remove()
                                # Removes the host from the variable storing the all the computers
                                $script:ComputerTreeViewData = $script:ComputerTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                            }
                        }
                    }
                }
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Deleted:  $($script:EntrySelected.text)")

                if ($ComputerTreeNodeOSHostnameRadioButton.checked){$ComputerTreeNodeOSHostnameRadioButton.PerformClick()}
                elseif ($ComputerTreeNodeOUHostnameRadioButton.checked){$ComputerTreeNodeOUHostnameRadioButton.PerformClick()}

                #This is a bit of a workaround, but it prevents the host data message from appearing after a computer node is deleted...
                $script:FirstCheck = $false

                Remove-EmptyCategory
                Save-HostData
                AutoSave-HostData
            }
            'No' {
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add('Endpoint Deletion Cancelled')
            }
        }
    }
}


$ComputerListDeleteAllCheckedToolStripButtonAdd_Click = {
    if ($script:ComputerTreeViewSelected.count -eq 0){
        [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Delete All')
    }
    else {
        # This brings specific tabs to the forefront/front view
        $MainBottomTabControl.SelectedTab = $Section3ResultsTab

        Create-ComputerNodeCheckBoxArray
        if ($script:ComputerTreeViewSelected.count -eq 1) {
            $MessageBox = [System.Windows.MessageBox]::Show("Confirm Deletion of $($script:ComputerTreeViewSelected.count) Endpoint Node.`r`n`r`nAll Endpoint metadata and notes will be lost.`r`nAny previously collected data will still remain.",'Delete Endpoint','YesNo')
        }
        elseif ($script:ComputerTreeViewSelected.count -gt 1) {
            $MessageBox = [System.Windows.MessageBox]::Show("Confirm Deletion of $($script:ComputerTreeViewSelected.count) Endpoint Nodes.`r`n`r`nAll Endpoint metadata and notes will be lost.`r`nAny previously collected data will still remain.",'Delete Endpoints','YesNo')
        }

        Switch ( $MessageBox ) {
            'Yes' {
                if ($script:ComputerTreeViewSelected.count -gt 0) {
                    foreach ($i in $script:ComputerTreeViewSelected) {
                        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
                        foreach ($root in $AllHostsNode) {
                            foreach ($Category in $root.Nodes) {
                                foreach ($Entry in $Category.nodes) {
                                    if ($Entry.checked) {
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
                                if ($Category.checked) { $Category.remove() }
                            }
                        }
                    }
                    # Removes selected root node - Note: had to put this in its own loop... see above category note
                    foreach ($i in $script:ComputerTreeViewSelected) {
                        foreach ($root in $AllHostsNode) {
                            if ($root.checked) {
                                foreach ($Category in $root.Nodes) { $Category.remove() }
                                $root.remove()
                                if ($i -eq "All Endpoints") { $script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList) }
                            }
                        }
                    }

                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Deleted:  $($script:ComputerTreeViewSelected.Count) Selected Items")
                    #Removed For Testing#$ResultsListBox.Items.Clear()
                    $ResultsListBox.Items.Add("The following hosts have been deleted:  ")
                    $ComputerListDeletedArray = @()
                    foreach ($Node in $script:ComputerTreeViewSelected) {
                        if ($Node -notin $ComputerListDeletedArray) {
                            $ComputerListDeletedArray += $Node
                            $ResultsListBox.Items.Add(" - $Node")
                        }
                    }

                    if ($ComputerTreeNodeOSHostnameRadioButton.checked){$ComputerTreeNodeOSHostnameRadioButton.PerformClick()}
                    elseif ($ComputerTreeNodeOUHostnameRadioButton.checked){$ComputerTreeNodeOUHostnameRadioButton.PerformClick()}

                    Remove-EmptyCategory
                    Save-HostData
                    AutoSave-HostData
                }
                else { ComputerNodeSelectedLessThanOne -Message 'Delete Selection' }
            }
            'No' {
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add('Endpoint Deletion Cancelled')
            }
        }
    }
}





