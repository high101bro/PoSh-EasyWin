Function View-CommandTreeNodeMethod {
    # Adds Endpoint Command nodes
    Foreach( $Command in $script:AllEndpointCommands ) {
        if ($Command.Command_RPC_PoSh)     { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets") -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_WMI)          { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation (WMI)") -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI }
        if ($Command.Command_WinRM_Script) { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts") -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }
        if ($Command.Command_WinRM_PoSh)   { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation (WMI)") -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI }
        if ($Command.Command_WinRM_CMD)    { Add-CommandTreeNode -RootNode $script:TreeNodeEndpointCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows CMD") -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD }
    }
    # Adds Active Directory Command nodes
    Foreach($Command in $script:AllActiveDirectoryCommands) {
        if ($Command.Command_RPC_PoSh)     { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "PowerShell Cmdlets") -Entry "(RPC) PoSh -- $($Command.Name)" -ToolTip $Command.Command_RPC_PoSh }
        if ($Command.Command_WMI)          { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-13}{1}" -f "[RPC]", "Windows Management Instrumentation (WMI)") -Entry "(RPC) WMI -- $($Command.Name)" -ToolTip $Command.Command_WMI }
        if ($Command.Command_WinRM_Script) { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Scripts") -Entry "(WinRM) Script -- $($Command.Name)" -ToolTip $Command.Command_WinRM_Script }
        if ($Command.Command_WinRM_PoSh)   { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip $Command.Command_WinRM_PoSh }
        if ($Command.Command_WinRM_WMI)    { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows Management Instrumentation (WMI)") -Entry "(WinRM) WMI -- $($Command.Name)" -ToolTip $Command.Command_WinRM_WMI }
        if ($Command.Command_WinRM_CMD)    { Add-CommandTreeNode -RootNode $script:TreeNodeActiveDirectoryCommands -Category $("{0,-10}{1}" -f "[WinRM]", "Windows CMD") -Entry "(WinRM) CMD -- $($Command.Name)" -ToolTip $Command.Command_WinRM_CMD }

    }
    # Adds the selected commands to the Query History Command Nodes
    foreach ($Command in $script:QueryHistoryCommands) { Add-CommandTreeNode -RootNode $script:TreeNodePreviouslyExecutedCommands -Category "$($Command.CategoryName)" -Entry "$($Command.Name)" -ToolTip "$($Command.Command)" }
}
