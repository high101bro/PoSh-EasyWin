$ComputerListRenameToolStripButtonAdd_Click = {
    # This brings specific tabs to the forefront/front view
    $MainBottomTabControl.SelectedTab = $Section3ResultsTab

    Create-ComputerNodeCheckBoxArray
    if ($script:EntrySelected) {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add("Enter a new name:")

        #----------------------------------
        # ComputerList TreeView Popup Form
        #----------------------------------
        $ComputerTreeNodeRenamePopup               = New-Object system.Windows.Forms.Form
        $ComputerTreeNodeRenamePopup.Text          = "Rename $($script:EntrySelected.text)"
        $ComputerTreeNodeRenamePopup.Size          = New-Object System.Drawing.Size(($FormScale * 330),($FormScale * 107))
        $ComputerTreeNodeRenamePopup.StartPosition = "CenterScreen"
        $ComputerTreeNodeRenamePopup.Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        $ComputerTreeNodeRenamePopup.Add_Closing   = { $This.dispose() }

        #---------------------------------------------
        # ComputerList TreeView Popup Execute TextBox
        #---------------------------------------------
        $script:ComputerTreeNodeRenamePopupTextBox          = New-Object System.Windows.Forms.TextBox
        $script:ComputerTreeNodeRenamePopupTextBox.Text     = "New Hostname/IP"
        $script:ComputerTreeNodeRenamePopupTextBox.Size     = New-Object System.Drawing.Size(($FormScale * 300),($FormScale * 25))
        $script:ComputerTreeNodeRenamePopupTextBox.Location = New-Object System.Drawing.Point(($FormScale * 10),($FormScale * 10))
        $script:ComputerTreeNodeRenamePopupTextBox.Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)

        # Renames the computer treenode to the specified name
        . "$Dependencies\Code\Tree View\Computer\Rename-ComputerTreeNodeSelected.ps1"

        # Moves the hostname/IPs to the new Category
        $script:ComputerTreeNodeRenamePopupTextBox.Add_KeyDown({
            if ($_.KeyCode -eq "Enter") { Rename-ComputerTreeNodeSelected }
        })
        $ComputerTreeNodeRenamePopup.Controls.Add($script:ComputerTreeNodeRenamePopupTextBox)

        #--------------------------------------------
        # ComputerList TreeView Popup Execute Button
        #--------------------------------------------
        $ComputerTreeNodeRenamePopupButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Execute"
            Location = @{ X = $FormScale * 210
                          Y = $script:ComputerTreeNodeRenamePopupTextBox.Location.X + $script:ComputerTreeNodeRenamePopupTextBox.Size.Height + ($FormScale * 5) }
            Size     = @{ Width  = $FormScale * 100
                          Height = $FormScale * 22 }
        }
        CommonButtonSettings -Button $ComputerTreeNodeRenamePopupButton
        $ComputerTreeNodeRenamePopupButton.Add_Click({ Rename-ComputerTreeNodeSelected })
        $ComputerTreeNodeRenamePopup.Controls.Add($ComputerTreeNodeRenamePopupButton)

        $ComputerTreeNodeRenamePopup.ShowDialog()
    }
    else {
        $StatusListBox.Items.Clear()
        $StatusListBox.Items.Add($script:EntrySelected.text)
    }
    #elseif ($script:ComputerTreeViewSelected.count -lt 1) { ComputerNodeSelectedLessThanOne -Message 'Rename Selection' }
    #elseif ($script:ComputerTreeViewSelected.count -gt 1) { ComputerNodeSelectedMoreThanOne -Message 'Rename Selection' }

    Remove-EmptyCategory
    AutoSave-HostData
    Save-HostData
}


