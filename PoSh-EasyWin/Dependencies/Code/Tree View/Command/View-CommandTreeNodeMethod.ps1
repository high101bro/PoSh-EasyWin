Function View-CommandTreeNodeMethod {
    # Adds Endpoint Command nodes
    Foreach( $Command in $script:AllEndpointCommands ) {
        if ($Command.Command_WinRM_PoSh)   { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets")                       -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation (WMI)") -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
        if ($Command.Command_WinRM_Cmd)    { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Native Windows Command")                   -Entry "(WinRM) CMD -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_CMD }
        if ($Command.Command_WinRM_Script) { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts")                       -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }
        if ($Command.Command_RPC_PoSh)     { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets")                         -Entry "(RPC) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_RPC_WMI)      { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation (WMI)")   -Entry "(RPC) WMI -- $($Command.Name)"      -ToolTip $Command.Command_RPC_WMI }
        # Not included in the treeview generation as the native Windows CMDs either don't natively support remoting or have non-standard switches/parameters
        #if ($Command.Command_RPC_CMD)      { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "Native Windows Command")                         -Entry "(RPC) CMD -- $($Command.Name)"      -ToolTip $Command.Command_RPC_CMD }
        if ($Command.Command_SMB_PoSh)     { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[SMB]", "PowerShell Cmdlets")                         -Entry "(SMB) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_SMB_PoSh }
        if ($Command.Command_SMB_WMI)      { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[SMB]", "Windows Management Instrumentation (WMI)")   -Entry "(SMB) WMI -- $($Command.Name)"      -ToolTip $Command.Command_SMB_WMI }
        if ($Command.Command_SMB_CMD)      { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[SMB]", "Native Windows Command")                     -Entry "(SMB) CMD -- $($Command.Name)"      -ToolTip $Command.Command_SMB_CMD }
    }
    # Adds Active Directory Command nodes
    Foreach($Command in $script:AllActiveDirectoryCommands) {
        if ($Command.Command_WinRM_PoSh)   { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets")                       -Entry "(WinRM) PoSh -- $($Command.Name)"   -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation (WMI)") -Entry "(WinRM) WMI -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_WMI }
        if ($Command.Command_WinRM_Cmd)    { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Native Windows Command")                   -Entry "(WinRM) CMD -- $($Command.Name)"    -ToolTip $Command.Command_WinRM_CMD }
        if ($Command.Command_WinRM_Script) { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts")                       -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }
        if ($Command.Command_RPC_PoSh)     { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets")                         -Entry "(RPC) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_RPC_WMI)      { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation (WMI)")   -Entry "(RPC) WMI -- $($Command.Name)"      -ToolTip $Command.Command_RPC_WMI }
        # Not included in the treeview generation as the native Windows CMDs either don't natively support remoting or have non-standard switches/parameters
        #if ($Command.Command_RPC_CMD)      { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "Native Windows Command")                         -Entry "(RPC) CMD -- $($Command.Name)"      -ToolTip $Command.Command_RPC_CMD }
        if ($Command.Command_SMB_PoSh)     { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[SMB]", "PowerShell Cmdlets")                         -Entry "(SMB) PoSh -- $($Command.Name)"     -ToolTip $Command.Command_SMB_PoSh }
        if ($Command.Command_SMB_WMI)      { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[SMB]", "Windows Management Instrumentation (WMI)")   -Entry "(SMB) WMI -- $($Command.Name)"      -ToolTip $Command.Command_SMB_WMI }
        if ($Command.Command_SMB_CMD)      { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[SMB]", "Native Windows Command")                     -Entry "(SMB) CMD -- $($Command.Name)"      -ToolTip $Command.Command_SMB_CMD }
    }
    # Adds the selected commands to the Query History Command Nodes
    foreach ($Command in $script:QueryHistoryCommands) { Add-CommandTreeNode -RootNode $script:TreeNodePreviouslyExecutedCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip "$($Command.Command)" }
}
