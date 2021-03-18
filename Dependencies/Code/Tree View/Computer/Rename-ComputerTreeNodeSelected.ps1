function Rename-ComputerTreeNodeSelected {
    if ($script:ComputerTreeViewData.Name -contains $script:ComputerTreeNodeRenamePopupTextBox.Text) {
        Message-HostAlreadyExists -Message "Rename Hostname/IP:  Error" -computer $script:ComputerTreeNodeRenamePopupTextBox.Text

    }
    else {
        # Makes a copy of the checkboxed node name in the new Category
        $ComputerTreeNodeToRename = New-Object System.Collections.ArrayList

        # Adds (copies) the node to the new Category
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
        foreach ($root in $AllHostsNode) {
            if ($root.Checked) { $root.Checked = $false }
            foreach ($Category in $root.Nodes) {
                if ($Category.Checked) { $Category.Checked = $false }
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.IsSelected) {
                        Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $Category.Text -Entry $script:ComputerTreeNodeRenamePopupTextBox.text #-ToolTip "No Data Available"
                        $ComputerTreeNodeToRename.Add($Entry.text)

                        $script:PreviousEndpointName = $script:EntrySelected.Text
                        $Section3HostDataNotesRichTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes + "`r`nPrevious Endpoint Name: $script:PreviousEndpointName"
                        Save-ComputerTreeNodeHostData
                        Check-HostDataIfModified
                        break
                    }
                }
            }
        }
        # Removes the original hostname/IP that was copied above
        foreach ($i in $ComputerTreeNodeToRename) {
            foreach ($root in $AllHostsNode) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        if (($i -contains $Entry.text) -and ($Entry.IsSelected)) {
                            $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name = $script:ComputerTreeNodeRenamePopupTextBox.text
                            $ResultsListBox.Items.Add($Entry.text)
                            $Entry.remove()
                        }
                    }
                }
            }
        }
        Save-ComputerTreeNodeHostDataHostData
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Rename Selection:  $($ComputerTreeNodeToRename.Count) Hosts")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("The computer has been renamed to $($script:ComputerTreeNodeRenamePopupTextBox.Text)")
    }
    $ComputerTreeNodeRenamePopup.close()
}

