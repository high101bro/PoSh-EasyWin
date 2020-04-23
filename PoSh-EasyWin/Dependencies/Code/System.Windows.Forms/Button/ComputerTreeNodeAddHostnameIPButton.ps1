$ComputerTreeNodeAddHostnameIPButtonAdd_Click = {
    $StatusListBox.Items.Clear()
    $StatusListBox.Items.Add("Add hostname/IP:")
    $ResultsListBox.Items.Clear()
    $ResultsListBox.Items.Add("Enter a hostname/IP")

    #----------------------------------
    # ComputerList TreeView Popup Form
    #----------------------------------
    $ComputerTreeNodePopup = New-Object system.Windows.Forms.Form -Property @{
        Text          = "Add Hostname/IP"
        Size          = New-Object System.Drawing.Size(335,177)
        StartPosition = "CenterScreen"
        Font          = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    #-----------------------------------------------------
    # ComputerList TreeView Popup Add Hostname/IP TextBox
    #-----------------------------------------------------
    $ComputerTreeNodePopupAddTextBox = New-Object System.Windows.Forms.TextBox -Property @{
        Text     = "Enter a hostname/IP"
        Location = @{ X = 10
                      Y = 10 }
        Size     = @{ Width  = 300
                      Height = 25 }
        Font     = New-Object System.Drawing.Font("$Font",11,0,0,0)
        # Add_Load = {  }
        # Add_AfterSelect = {  }
        # Add_KeyDown = {  }
        # Add_Click = {  }
        # Add_MouseHover = {  }
        # Add_MouseEnter = {  }
        # Add_MouseLeave = {  }
    }
    $ComputerTreeNodePopupAddTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AddHost-ComputerTreeNode } })
    $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupAddTextBox)

    #-----------------------------------------
    # ComputerList TreeView Popup OS ComboBox
    #-----------------------------------------
    $ComputerTreeNodePopupOSComboBox  = New-Object System.Windows.Forms.ComboBox -Property @{
        Text     = "Select an Operating System (or type in a new one)"
        Location = @{ X = 10
                      Y = $ComputerTreeNodePopupAddTextBox.Location.Y + $ComputerTreeNodePopupAddTextBox.Size.Height + 10 }
        Size     = @{ Width  = 300
                      Height = 25 }
        AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $ComputerTreeNodeOSCategoryList = $script:ComputerTreeViewData | Select-Object -ExpandProperty OperatingSystem -Unique
    # Dynamically creates the OS Category combobox list used for OS Selection
    ForEach ($OS in $ComputerTreeNodeOSCategoryList) { $ComputerTreeNodePopupOSComboBox.Items.Add($OS) }
    $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupOSComboBox)

    #-----------------------------------------
    # ComputerList TreeView Popup OU ComboBox
    #-----------------------------------------
    $ComputerTreeNodePopupOUComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
        Text     = "Select an Organizational Unit / Canonical Name (or type a new one)"
        Location = @{ X = 10
                      Y = $ComputerTreeNodePopupOSComboBox.Location.Y + $ComputerTreeNodePopupOSComboBox.Size.Height + 10 }
        Size     = @{ Width  = 300
                      Height = 25 }
        AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
        AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
        Font               = New-Object System.Drawing.Font("$Font",11,0,0,0)
    }
    $ComputerTreeNodeOUCategoryList = $script:ComputerTreeViewData | Select-Object -ExpandProperty CanonicalName -Unique
    # Dynamically creates the OU Category combobox list used for OU Selection
    ForEach ($OU in $ComputerTreeNodeOUCategoryList) { $ComputerTreeNodePopupOUComboBox.Items.Add($OU) }
    $ComputerTreeNodePopupOUComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AddHost-ComputerTreeNode } })
    $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupOUComboBox)

    #---------------------------------------------
    # ComputerList TreeView Popup Add Host Button
    #---------------------------------------------
    $ComputerTreeNodePopupAddHostButton = New-Object System.Windows.Forms.Button -Property @{
        Text     = "Add Host"
        Location = @{ X = 210
                      Y = $ComputerTreeNodePopupOUComboBox.Location.Y + $ComputerTreeNodePopupOUComboBox.Size.Height + 10 }
        Size     = @{ Width  = 100
                      Height = 25 }
    }
    CommonButtonSettings -Button $ComputerTreeNodePopupAddHostButton
    $ComputerTreeNodePopupAddHostButton.Add_Click({ AddHost-ComputerTreeNode })
    $ComputerTreeNodePopupAddHostButton.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AddHost-ComputerTreeNode } })    
    $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupAddHostButton)

    $script:ComputerTreeView.ExpandAll()
    Populate-ComputerTreeNodeDefaultData
    AutoSave-HostData
    $ComputerTreeNodePopup.ShowDialog()               
}
