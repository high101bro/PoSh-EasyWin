$ComputerListRenameButtonAdd_Click = {
    # This brings specific tabs to the forefront/front view
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab

    Create-ComputerNodeCheckBoxArray 
    if ($script:ComputerTreeViewSelected.count -eq 1) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Rename Selection:  ")
        $ResultsListBox.Items.Clear()
        $ResultsListBox.Items.Add("Enter a new name:")

        #----------------------------------
        # ComputerList TreeView Popup Form
        #----------------------------------
        $ComputerTreeNodeRenamePopup               = New-Object system.Windows.Forms.Form
        $ComputerTreeNodeRenamePopup.Text          = "Rename $($script:ComputerTreeViewSelected)"
        $ComputerTreeNodeRenamePopup.Size          = New-Object System.Drawing.Size(330,107)
        $ComputerTreeNodeRenamePopup.StartPosition = "CenterScreen"
        $ComputerTreeNodeRenamePopup.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)

        #---------------------------------------------
        # ComputerList TreeView Popup Execute TextBox
        #---------------------------------------------
        $ComputerTreeNodeRenamePopupTextBox          = New-Object System.Windows.Forms.TextBox
        $ComputerTreeNodeRenamePopupTextBox.Text     = "New Hostname/IP"
        $ComputerTreeNodeRenamePopupTextBox.Size     = New-Object System.Drawing.Size(300,25)
        $ComputerTreeNodeRenamePopupTextBox.Location = New-Object System.Drawing.Point(10,10)
        $ComputerTreeNodeRenamePopupTextBox.Font      = New-Object System.Drawing.Font("$Font",11,0,0,0)
        # Add_Load = {  }
        # Add_AfterSelect = {  }
        # Add_KeyDown = {  }
        # Add_Click = {  }
        # Add_MouseHover = {  }
        # Add_MouseEnter = {  }
        # Add_MouseLeave = {  }

        # Renames the computer treenode to the specified name
        . "$Dependencies\Code\Tree View\Computer\Rename-ComputerTreeNodeSelected.ps1"          
           
        # Moves the hostname/IPs to the new Category
        $ComputerTreeNodeRenamePopupTextBox.Add_KeyDown({ 
            if ($_.KeyCode -eq "Enter") { Rename-ComputerTreeNodeSelected }
        })
        $ComputerTreeNodeRenamePopup.Controls.Add($ComputerTreeNodeRenamePopupTextBox)

        #--------------------------------------------
        # ComputerList TreeView Popup Execute Button
        #--------------------------------------------
        $ComputerTreeNodeRenamePopupButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Execute"
            Location = @{ X = 210
                          Y = $ComputerTreeNodeRenamePopupTextBox.Location.X + $ComputerTreeNodeRenamePopupTextBox.Size.Height + 5 }
            Size     = @{ Width  = 100
                          Height = 22 }
        }
        CommonButtonSettings -Button $ComputerTreeNodeRenamePopupButton
        $ComputerTreeNodeRenamePopupButton.Add_Click({ Rename-ComputerTreeNodeSelected })
        $ComputerTreeNodeRenamePopup.Controls.Add($ComputerTreeNodeRenamePopupButton)

        $ComputerTreeNodeRenamePopup.ShowDialog()               
    }
    elseif ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Rename Selection' }
    elseif ($script:ComputerTreeViewSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Rename Selection' }
    AutoSave-HostData
}
