function Search-CommandTreeNode {
    $Section4TabControl.SelectedTab = $Section3ResultsTab
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes

    # Checks if the search node already exists
    $SearchNode = $false
    foreach ($root in $AllCommandsNode) { 
        if ($root.text -imatch 'Search Results') { $SearchNode = $true }
    }
    if ($SearchNode -eq $false) { $script:CommandsTreeView.Nodes.Add($script:TreeNodeCommandSearch) }

    # Checks if the search has already been conduected
    $SearchCheck = $false
    foreach ($root in $AllCommandsNode) { 
        if ($root.text -imatch 'Search Results') {                    
            foreach ($Category in $root.Nodes) { 
                if ($Category.text -eq $CommandsTreeViewSearchComboBox.Text) { $SearchCheck = $true}
            }
        }
    }
    # Conducts the search, if something is found it will add it to the treeview
    # Will not produce multiple results if the host triggers in more than one field
    $SearchFound = @()
    if ($CommandsTreeViewSearchComboBox.Text -ne "" -and $SearchCheck -eq $false) {
        $script:AllCommands  = $script:AllEndpointCommands
        $script:AllCommands += $script:AllActiveDirectoryCommands

        Foreach($Command in $script:AllCommands) {
            if (($SearchFound -inotcontains $Computer) -and (
                ($Command.Name -imatch $CommandsTreeViewSearchComboBox.Text) -or
                ($Command.Type -imatch $CommandsTreeViewSearchComboBox.Text) -or
                ($Command.Description -imatch $CommandsTreeViewSearchComboBox.Text))) {
                if ($Command.Command_RPC_PoSh)     { Add-CommandTreeNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchComboBox.Text) -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh }
                if ($Command.Command_WMI)          { Add-CommandTreeNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchComboBox.Text) -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI }
                #if ($Command.Command_RPC_CMD)     { Add-CommandTreeNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchComboBox.Text) -Entry "(RPC) CMD -- $($Command.Name)" -ToolTip $Command.Command_RPC_CMD }
                #if ($Command.Command_WinRS_WMIC)  { Add-CommandTreeNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchComboBox.Text) -Entry "(WinRM) WMIC -- $($Command.Name)" -ToolTip $Command.Command_WinRS_WMIC }
                #if ($Command.Command_WinRS_CMD)   { Add-CommandTreeNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchComboBox.Text) -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRS_CMD }
                if ($Command.Command_WinRM_Script) { Add-CommandTreeNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchComboBox.Text) -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }        
                if ($Command.Command_WinRM_PoSh)   { Add-CommandTreeNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchComboBox.Text) -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh }
                if ($Command.Command_WinRM_WMI)    { Add-CommandTreeNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchComboBox.Text) -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI }
                if ($Command.Command_WinRM_CMD)    { Add-CommandTreeNode -RootNode $script:TreeNodeCommandSearch -Category $($CommandsTreeViewSearchComboBox.Text) -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD }
            }
        }
    }
    
    # Expands the search results
    [System.Windows.Forms.TreeNodeCollection]$AllCommandsNode = $script:CommandsTreeView.Nodes 
    foreach ($root in $AllCommandsNode) { 
        if ($root.text -match 'Search Results'){ 
            $root.Collapse()
            $root.Expand()
            foreach ($Category in $root.Nodes) {
                if ($CommandsTreeViewSearchComboBox.text -in $Category.text) { 
                    $Category.EnsureVisible()
                    $Category.Expand()
                }
                else {
                    $Category.Collapse()
                }
            }
        }
    }

    $CommandsTreeViewSearchComboBox.Text = ""
}
