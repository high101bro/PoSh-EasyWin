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


$ComputerListLeftClickToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
    Text      = "Left-Click an Endpoint Node,`nthen Right-Click for more Options"
    ForeColor = 'DarkRed'
}
$ComputerListContextMenuStrip.Items.Add($ComputerListLeftClickToolStripLabel)


$ComputerListCollapseToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Collapse"
    Add_CLick = $ComputerListCollapseToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListCollapseToolStripButton)


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


$ComputerListDeselectAllToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Uncheck All"
    Add_CLick = $ComputerListDeselectAllToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListDeselectAllToolStripButton)


$ComputerListNSLookupCheckedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "NSLookup"
    Add_CLick = $ComputerListNSLookupCheckedToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListNSLookupCheckedToolStripButton)


$ComputerListMassTagToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Tag All"
    Add_CLick = $ComputerListTagAllCheckedToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListMassTagToolStripButton)


$ComputerListMoveToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Move All"
    Add_CLick = $ComputerListMoveAllCheckedToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListMoveToolStripButton)


$ComputerListDeleteToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Delete All"
    Add_CLick = $ComputerListDeleteAllCheckedToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListDeleteToolStripButton)


$ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
    Text      = 'Test Connection'
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'black'
}
$ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)


$ComputerListPingToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "   - ICMP Ping"
    ForeColor = 'DarkRed'
    Add_CLick = $ComputerListPingToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListPingToolStripButton)


$ComputerListRPCCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "   - RPC Port Check"
    ForeColor = 'DarkRed'
    Add_CLick = $ComputerListRPCCheckToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListRPCCheckToolStripButton)


$ComputerListSMBCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "   - SMB Port Check"
    ForeColor = 'DarkRed'
    Add_CLick = $ComputerListSMBCheckToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListSMBCheckToolStripButton)


$ComputerListWinRMCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "   - WinRM Check"
    ForeColor = 'DarkRed'
    Add_CLick = $ComputerListWinRMCheckToolStripButtonAdd_Click
}
$ComputerListContextMenuStrip.Items.Add($ComputerListWinRMCheckToolStripButton)        


