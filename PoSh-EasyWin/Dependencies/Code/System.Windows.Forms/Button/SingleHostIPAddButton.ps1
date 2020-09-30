$SingleHostIPAddButtonAdd_Click = {
    # Conducts a simple input check for default or blank data
    if (($script:SingleHostIPTextBox.Text -ne $DefaultSingleHostIPText) -and ($script:SingleHostIPTextBox.Text -ne '')) {
        if ($script:ComputerTreeViewData.Name -contains $script:SingleHostIPTextBox.Text) {
            Message-HostAlreadyExists -Message "Add Hostname/IP:  Error" -Computer $script:SingleHostIPTextBox.Text
        }
        else {
            $StatusListBox.Items.Clear()
            $StatusListBox.Items.Add("Added Selection:  $($script:SingleHostIPTextBox.Text)")

            $NewNodeValue = "Manually Added"
            # Adds the hostname/ip entered into the collection list box
            Add-NodeComputer -RootNode $script:TreeNodeComputerList -Category $NewNodeValue -Entry $script:SingleHostIPTextBox.Text -ToolTip 'No Data Avialable'

            #Removed For Testing#$ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("$($script:SingleHostIPTextBox.Text) has been added to $($NewNodeValue)")

            $ComputerTreeNodeAddHostnameIP = New-Object PSObject -Property @{
                Name            = $script:SingleHostIPTextBox.Text
                OperatingSystem = $NewNodeValue
                CanonicalName   = $NewNodeValue
                IPv4Address     = "No IP Available"
            }
            $script:ComputerTreeViewData += $ComputerTreeNodeAddHostnameIP

            $script:ComputerTreeView.ExpandAll()
            # Enables the Computer TreeView
            $script:ComputerTreeView.Enabled   = $true
            $script:ComputerTreeView.BackColor = "white"
            # Clears Textbox
            $script:SingleHostIPTextBox.Text = $DefaultSingleHostIPText
            # Auto checks/unchecks various checkboxes for visual status indicators
            $script:SingleHostIPCheckBox.Checked = $false

            Populate-ComputerTreeNodeDefaultData
            AutoSave-HostData
        }
    }
}

$SingleHostIPAddButtonAdd_MouseHover = {
    Show-ToolTip -Title "Query A Single Endpoint" -Icon "Info" -Message @"
+  Adds a single host to the computer treeview.
+  The host is added under
"@
}


