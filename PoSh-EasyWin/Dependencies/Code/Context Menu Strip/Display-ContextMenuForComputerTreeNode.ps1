function Display-ContextMenuForComputerTreeNode {
    Create-ComputerNodeCheckBoxArray

    $ComputerListContextMenuStrip.Items.Remove($ComputerListRenameToolStripButton)
    $ComputerListContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip -Property @{
        ShowCheckMargin = $false
        ShowImageMargin = $false
        ShowItemToolTips = $false
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
    }

    #$ComputerListContextMenuStrip.Items.Add("$($Entry.Text)")
    $script:ComputerListEndpointNameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "$($Entry.Text)"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $ComputerListContextMenuStrip.Items.Add($script:ComputerListEndpointNameToolStripLabel)

    #$comboBoxMenuItem = New-Object System.Windows.Forms.ToolStripComboBox
    #$comboBoxMenuItem.Items.Add('Option 1')
    #$comboBoxMenuItem.Items.Add('Option 2')
    #$ComputerListContextMenuStrip.Items.Add($comboBoxMenuItem)

    $ComputerListContextMenuStrip.Items.Add('-')


    $ComputerListRemoteDesktopToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Remote Desktop"
        ForeColor = 'DarkRed'
        Add_CLick = $ComputerListRDPButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListRemoteDesktopToolStripButton)


    $ComputerListPSSessionToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "PSSession"
        ForeColor = 'DarkRed'
        Add_CLick = $ComputerListPSSessionButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListPSSessionToolStripButton)


    $ComputerListPSExecToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "PSExec"
        ForeColor = 'DarkRed'
        Add_CLick = $ComputerListPsExecButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListPSExecToolStripButton)


    $script:ExpandCollapseStatus = "Collapse"
    $ComputerListCollapseToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Collapse"
        Add_CLick = $ComputerListCollapseToolStripButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListCollapseToolStripButton)


    $ComputerListTagSelectedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Tag"
        Add_CLick = $ComputerListTagSelectedToolStripButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListTagSelectedToolStripButton)


    $ComputerListAddEndpointToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Add Endpoint"
        Add_CLick = $ComputerListAddEndpointToolStripButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListAddEndpointToolStripButton)


    $ComputerListRenameToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Rename"
        Add_CLick = $ComputerListRenameToolStripButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripButton)


    $ComputerListMoveToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Move"
        Add_CLick = $ComputerListMoveSelectedToolStripButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListMoveToolStripButton)


    $ComputerListDeleteSelectedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        #Text      = "Delete:  $($script:EntrySelected.text)"
        Text      = "Delete"
        Add_CLick = $ComputerListDeleteSelectedToolStripButtonAdd_Click
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListDeleteSelectedToolStripButton)


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


        $ComputerListTagAllCheckedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Tag All"
            Add_CLick = $ComputerListTagAllCheckedToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListTagAllCheckedToolStripButton)


        $ComputerListMoveToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Move All"
            Add_CLick = $ComputerListMoveAllCheckedToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListMoveToolStripButton)


        $ComputerListDeleteAllCheckedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Delete All"
            Add_CLick = $ComputerListDeleteAllCheckedToolStripButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListDeleteAllCheckedToolStripButton)


        $ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
            Text      = 'Test Connection'
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
            ForeColor = 'Black'
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

    $Entry.ContextMenuStrip = $ComputerListContextMenuStrip
}


