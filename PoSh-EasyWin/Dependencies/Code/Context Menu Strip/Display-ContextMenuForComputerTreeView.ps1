
#--------------------------------------------------------------------------------------
# Context Menu Strip for when clicking within the treeview but not on an endpoint node
#--------------------------------------------------------------------------------------

$ComputerListContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip -Property @{
    ShowCheckMargin = $false
    ShowImageMargin = $false
    ShowItemToolTips = $True
    Width    = 100
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}


$ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
    Text      = "Select an Endpoint"
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
}
$ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)
$ComputerListContextMenuStrip.Items.Add('-')


$ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
    Text      = "Left-Click an Endpoint Node,`r`nthen Right-Click for more Options"
    ForeColor = 'DarkRed'
}
$ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)


. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListCollapseToolStripButton.ps1"
$ComputerListCollapseToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Collapse"
    Add_CLick = $ComputerListCollapseToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListCollapseToolStripButton)


. "$Dependencies\Code\Tree View\Computer\Message-HostAlreadyExists.ps1"
. "$Dependencies\Code\Tree View\Computer\AddHost-ComputerTreeNode.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListAddEndpointToolStripButton.ps1"
$ComputerListAddEndpointToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Add Endpoint"
    Add_CLick = $ComputerListAddEndpointToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListAddEndpointToolStripButton)


$ComputerListContextMenuStrip.Items.Add('-')
$ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
    Text      = 'Checked Endpoints'
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
}
$ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)
$ComputerListContextMenuStrip.Items.Add('-')


. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeselectAllToolStripButton.ps1"
$ComputerListDeselectAllToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Uncheck All"
    Add_CLick = $ComputerListDeselectAllToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListDeselectAllToolStripButton)

. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListNSLookupCheckedToolStripButton.ps1"
$ComputerListNSLookupCheckedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "NSLookup"
    Add_CLick = $ComputerListNSLookupCheckedToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListNSLookupCheckedToolStripButton)

. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListTagToolStripButton.ps1"
$ComputerListMassTagToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Tag All"
    Add_CLick = $ComputerListTagAllCheckedToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListMassTagToolStripButton)

. "$Dependencies\Code\Tree View\Computer\Move-ComputerTreeNodeSelected.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListMoveToolStripButton.ps1"
$ComputerListMoveToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Move All"
    Add_CLick = $ComputerListMoveAllCheckedToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListMoveToolStripButton)

. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListDeleteToolStripButton.ps1"
$ComputerListDeleteToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Delete All"
    Add_CLick = $ComputerListDeleteAllCheckedToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListDeleteToolStripButton)

# The following are used within Conduct-TreeNodeAction via the ContextMenuStips
# They're placed here to be loaded once, rather than multiple times 
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRenameToolStripButton.ps1"


$ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
    Text      = 'Test Connection'
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'black'
}
$ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)


# This function is the base code for testing various connections with remote computers
. "$Dependencies\Code\Execution\Action\Check-Connection.ps1"
. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListPingToolStripButton.ps1"
$ComputerListPingToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "   - Ping"
    Add_CLick = $ComputerListPingToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListPingToolStripButton)


. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListWinRMCheckToolStripButton.ps1"
$ComputerListWinRMCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "   - WinRM Check"
    Add_CLick = $ComputerListWinRMCheckToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListWinRMCheckToolStripButton)        


. "$Dependencies\Code\System.Windows.Forms\ToolStripButton\ComputerListRPCCheckToolStripButton.ps1"
$ComputerListRPCCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "   - RPC/DCOM Check"
    Add_CLick = $ComputerListRPCCheckToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListRPCCheckToolStripButton)



