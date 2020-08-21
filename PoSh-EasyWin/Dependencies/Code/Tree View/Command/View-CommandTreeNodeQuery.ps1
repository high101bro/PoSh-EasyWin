Function View-CommandTreeNodeQuery {
    # Adds Endpoint Command nodes
    Foreach($Command in $script:AllEndpointCommands) {
        if ($Command.Command_WinRM_PoSh)   { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
        if ($Command.Command_WinRM_CMD)    { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_CMD }
        if ($Command.Command_WinRM_Script) { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }        
        if ($Command.Command_RPC_PoSh)     { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_RPC_WMI)      { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) WMI -- $($Command.Name)"      -ToolTip $Command.Command_RPC_WMI }
        # Not included in the treeview generation as the native Windows CMDs either don't natively support remoting or have non-standard switches/parameters
        #if ($Command.Command_RPC_CMD)      { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(RPC) CMD -- $($Command.Name)"      -ToolTip $Command.Command_RPC_CMD }
        if ($Command.Command_SMB_PoSh)     { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(SMB) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_SMB_PoSh }
        if ($Command.Command_SMB_WMI)      { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(SMB) WMI -- $($Command.Name)"      -ToolTip $Command.Command_SMB_WMI }
        if ($Command.Command_SMB_CMD)      { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $Command.Name -Entry "(SMB) CMD -- $($Command.Name)"      -ToolTip $Command.Command_SMB_CMD }
    }
    # Adds Active Directory Command nodes
    Foreach($Command in $script:AllActiveDirectoryCommands) {
        if ($Command.Command_WinRM_PoSh)   { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
        if ($Command.Command_WinRM_CMD)    { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) CMD -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_CMD }
        if ($Command.Command_WinRM_Script) { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }        
        if ($Command.Command_RPC_PoSh)     { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_RPC_WMI)      { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) WMI -- $($Command.Name)"      -ToolTip $Command.Command_RPC_WMI }
        # Not included in the treeview generation as the native Windows CMDs either don't natively support remoting or have non-standard switches/parameters
        #if ($Command.Command_RPC_CMD)      { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(RPC) CMD -- $($Command.Name)"      -ToolTip $Command.Command_RPC_CMD }
        if ($Command.Command_SMB_PoSh)     { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(SMB) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_SMB_PoSh }
        if ($Command.Command_SMB_WMI)      { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(SMB) WMI -- $($Command.Name)"      -ToolTip $Command.Command_SMB_WMI }
        if ($Command.Command_SMB_CMD)      { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $Command.Name -Entry "(SMB) CMD -- $($Command.Name)"      -ToolTip $Command.Command_SMB_CMD }
    }
    # Adds the selected commands to the Query History Command Nodes
    foreach ($Command in $script:QueryHistoryCommands) {
        Add-CommandTreeNode -RootNode $script:TreeNodePreviouslyExecutedCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip "$($Command.Command)"
    }
}