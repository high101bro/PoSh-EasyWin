function Generate-ComputerList {
    # Generate list of endpoints to query
    # Selects between manually entered endpoint and the computer treeview
    if ($script:SingleHostIPCheckBox.Checked -eq $true) {
        if (($script:SingleHostIPTextBox.Text -ne $DefaultSingleHostIPText) -and ($script:SingleHostIPTextBox.Text -ne '') ) {
            #$StatusListBox.Items.Clear()
            #$StatusListBox.Items.Add("Single Host Collection")
            $script:ComputerList = $script:SingleHostIPTextBox.Text
        }
    }
    elseif ($script:SingleHostIPCheckBox.Checked -eq $false) {
        #$StatusListBox.Items.Clear()
        #$StatusListBox.Items.Add("Multiple Host Collection")
        $script:ComputerList = @()

        # If the root computerlist checkbox is checked, All Endpoints will be queried
        [System.Windows.Forms.TreeNodeCollection]$AllHostsNode = $script:ComputerTreeView.Nodes
        if ($script:ComputerListSearch.Checked) {
            foreach ($root in $AllHostsNode) {
                if ($root.text -imatch "Search Results") {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            $script:ComputerList += $Entry.text
                        }
                    }
                }
            }
        }
        if ($script:TreeNodeComputerList.Checked) {
            foreach ($root in $AllHostsNode) {
                if ($root.text -imatch "All Endpoints") {
                    foreach ($Category in $root.Nodes) {
                        foreach ($Entry in $Category.nodes) {
                            $script:ComputerList += $Entry.text
                        }
                    }
                }
            }
        }
        foreach ($root in $AllHostsNode) {
            # This loop will select All Endpoints in a Category
            foreach ($Category in $root.Nodes) {
                if ($Category.Checked) {
                    foreach ($Entry in $Category.Nodes) {
                        $script:ComputerList += $Entry.text
                    }
                }
            }
            # This loop will check for entries that are checked
            foreach ($Category in $root.Nodes) {
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.Checked) { $script:ComputerList += $Entry.text }
                }
            }
        }
        # This will dedup the ComputerList, though there is unlikely multiple computers of the same name
        $script:ComputerList = $script:ComputerList | Sort-Object -Unique
    }

#    #Removed For Testing#$ResultsListBox.Items.Clear()
#    $ResultsListBox.Items.Add("Computers to be queried:  $($script:ComputerList.Count)")
#    $ResultsListBox.Items.Add("$script:ComputerList")
}


