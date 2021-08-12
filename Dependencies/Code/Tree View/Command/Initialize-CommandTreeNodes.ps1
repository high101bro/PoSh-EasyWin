function Initialize-CommandTreeNodes {
    $script:TreeNodeCommandSearch = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "* Search Results          " -Property @{
        Tag       = "Search"
        NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeEndpointCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "1) Endpoint Commands          " -Property @{
        Tag       = "Endpoint Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeActiveDirectoryCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "2) Active Directory Commands          " -Property @{
        Tag       = "ADDS Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeCustomGroupCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "3) Custom Group Commands          " -Property @{
        Tag       = "Custom Group Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    $script:TreeNodeUserAddedCommands = New-Object -TypeName System.Windows.Forms.TreeNode -ArgumentList "4) User Added Commands          " -Property @{
        Tag       = "User Added Commands"
        NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
    }
    
    $script:UserAddedCommands = @()
    if (Test-Path $CommandsUserAdded){ 
        $script:UserAddedCommands += Import-Csv $CommandsUserAdded
        foreach ($command in $script:UserAddedCommands) {
            Add-NodeCommand -RootNode $script:TreeNodeUserAddedCommands -Category $("{0,-10}{1}" -f "[WinRM]", "PowerShell Cmdlets") -Entry "(WinRM) PoSh -- $($Command.Name)" -ToolTip "$($command.Command_WinRM_PoSh)"
        }
    }
    else {$script:UserAddedCommands = $null}
    
    $script:TreeNodeCommandSearch.Expand()
    $script:TreeNodeEndpointCommands.Expand()
    $script:TreeNodeActiveDirectoryCommands.Expand()
    $script:TreeNodeCustomGroupCommands.Expand()
    $script:TreeNodeUserAddedCommands.Expand()

    #$script:TreeNodeCustomGroupCommands.Collapse()
    $script:CommandsTreeView.Nodes.Clear()

#    UpdateState-TreeViewData -Endpoint
}


