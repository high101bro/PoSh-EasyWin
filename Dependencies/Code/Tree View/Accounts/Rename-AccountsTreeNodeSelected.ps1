function Rename-AccountsTreeNodeSelected {
    if ($script:AccountsTreeViewData.Name -contains $script:AccountsTreeNodeRenamePopupTextBox.Text) {
        Message-NodeAlreadyExists -Accounts -Message "Rename Hostname/IP:  Error" -Account $script:AccountsTreeNodeRenamePopupTextBox.Text
    }
    else {
        # Makes a copy of the checkboxed node name in the new Category
        $AccountsTreeNodeToRename = New-Object System.Collections.ArrayList

        # Adds (copies) the node to the new Category
        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
        foreach ($root in $AllTreeViewNodes) {
            if ($root.Checked) { $root.Checked = $false }
            foreach ($Category in $root.Nodes) {
                if ($Category.Checked) { $Category.Checked = $false }
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.IsSelected) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Category.Text -Entry $script:AccountsTreeNodeRenamePopupTextBox.text #-ToolTip "No Unique Data Available"
                        $AccountsTreeNodeToRename.Add($Entry.text)

                        $script:PreviousAccountName = $script:EntrySelected.Text
                        $Section3HostDataNotesRichTextBox.Text = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes + "`r`nPrevious Account Name: $script:PreviousAccountName"
                        Save-TreeViewData -Accounts
                        break
                    }
                }
            }
        }
        # Removes the original hostname/IP that was copied above
        foreach ($i in $AccountsTreeNodeToRename) {
            foreach ($root in $AllTreeViewNodes) {
                foreach ($Category in $root.Nodes) {
                    foreach ($Entry in $Category.nodes) {
                        if (($i -contains $Entry.text) -and ($Entry.IsSelected)) {
                            $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name = $script:AccountsTreeNodeRenamePopupTextBox.text
                            $ResultsListBox.Items.Add($Entry.text)
                            $Entry.remove()
                        }
                    }
                }
            }
        }
        Save-TreeViewData -Accounts
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Rename Selection:  $($AccountsTreeNodeToRename.Count) Hosts")
        #Removed For Testing#$ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("The account has been renamed to $($script:AccountsTreeNodeRenamePopupTextBox.Text)")
    }
    $AccountsTreeNodeRenamePopup.close()
}

