function Display-ContextMenuForAccountsTreeNode {
    param(
        [switch]$ClickedOnNode,
        [switch]$ClickedOnArea
    )

    Create-TreeViewCheckBoxArray -Accounts

    $script:AccountsListContextMenuStrip.Items.Remove($AccountsListRenameToolStripButton)
    $script:AccountsListContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip -Property @{
        ShowCheckMargin = $false
        ShowImageMargin = $false
        ShowItemToolTips = $false
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
    }

    #$script:AccountsListContextMenuStrip.Items.Add("$($Entry.Text)")
    $script:AccountsListAccountNameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "$($Entry.Text)"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $script:AccountsListContextMenuStrip.Items.Add($script:AccountsListAccountNameToolStripLabel)


    $script:AccountsListContextMenuStrip.Items.Add('-')


    $AccountsListInteractWithAccountToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Interact With Account"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListInteractWithAccountToolStripLabel)


    $AccountsListInteractWithAccountNoActionToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "  - Under Development"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'DarkRed'
    }
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListInteractWithAccountNoActionToolStripLabel)


    $AccountsListSelectedNodeActionsToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Node Actions"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListSelectedNodeActionsToolStripLabel)


    $AccountsListSelectedNodeActionsToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 150 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'Conduct various actions against a single node.'
        Add_SelectedIndexChanged = {
            $script:AccountsListContextMenuStrip.Close()

            if ($This.selectedItem -eq " - Add New Account Node") { 
                $script:AccountsListContextMenuStrip.Close()

                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Add an Account:")           
            
                $AccountsTreeNodePopup = New-Object system.Windows.Forms.Form -Property @{
                    Text          = "Add an Account"
                    Width  = $FormScale * 335
                    Height = $FormScale * 157
                    StartPosition = "CenterScreen"
                    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
                    Add_Closing = { $This.dispose() }
                }
            
            
                $AccountsTreeNodePopupAddTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                    Text     = "Enter an Account"
                    Location = @{ X = $FormScale * 10
                                  Y = $FormScale * 10 }
                    Width  = $FormScale * 300
                    Height = $FormScale * 25
                    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $AccountsTreeNodePopupAddTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AddAccount-AccountsTreeNode } })
                $AccountsTreeNodePopup.Controls.Add($AccountsTreeNodePopupAddTextBox)
                   
            
                $AccountsTreeNodePopupOUComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                    Text  = "Select an Organizational Unit / Canonical Name (or type a new one)"
                    Location = @{ X = $FormScale * 10
                                  Y = $AccountsTreeNodePopupAddTextBox.Location.Y + $AccountsTreeNodePopupAddTextBox.Size.Height + $($FormScale * 10) }
                    Width  = $FormScale * 300
                    Height = $FormScale * 25
                    AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
                    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
                    Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $AccountsTreeNodeOUCategoryList = $script:AccountsTreeViewData | Select-Object -ExpandProperty CanonicalName -Unique
                # Dynamically creates the OU Category combobox list used for OU Selection
                ForEach ($OU in $AccountsTreeNodeOUCategoryList) { $AccountsTreeNodePopupOUComboBox.Items.Add($OU) }
                $AccountsTreeNodePopupOUComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AddAccount-AccountsTreeNode } })
                $AccountsTreeNodePopup.Controls.Add($AccountsTreeNodePopupOUComboBox)
            
                $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'
            
                if ($Script:CategorySelected){ $AccountsTreeNodePopupOUComboBox.Text = $Script:CategorySelected.text }
                elseif ($Script:EntrySelected){ $AccountsTreeNodePopupOUComboBox.Text = $Script:EntrySelected.text }
                else { $AccountsTreeNodePopupOUComboBox.Text  = "Select an Organizational Unit / Canonical Name (or type a new one)" }
            
            
                $AccountsTreeNodePopupAddAccountButton = New-Object System.Windows.Forms.Button -Property @{
                    Text     = "Add an Account"
                    Location = @{ X = $FormScale * 210
                                  Y = $AccountsTreeNodePopupOUComboBox.Location.Y + $AccountsTreeNodePopupOUComboBox.Size.Height + $($FormScale * 10) }
                    Width  = $FormScale * 100
                    Height = $FormScale * 25
                    Add_Click = { AddAccount-AccountsTreeNode }
                    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { AddAccount-AccountsTreeNode } }    
                }
                CommonButtonSettings -Button $AccountsTreeNodePopupAddAccountButton
                $AccountsTreeNodePopup.Controls.Add($AccountsTreeNodePopupAddAccountButton)
            
                # $script:AccountsTreeView.ExpandAll()
                # Remove-EmptyCategory -Accounts
                # Normalize-TreeViewData -Accounts
                # Save-TreeViewData -Accounts
                $AccountsTreeNodePopup.ShowDialog()
            }
            if ($This.selectedItem -eq " - Tag Node With Metadata") { 
                $script:AccountsListContextMenuStrip.Close()

                $InformationTabControl.SelectedTab = $Section3AccountDataTab

                if ($script:EntrySelected) {
                    Show-TagForm -Accounts
                    if ($script:AccountsListMassTagValue) {
                        #batman
                        $script:Section3AccountDataNameTextBox.Text = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).Name
                        $Section3AccountDataOSTextBox.Text          = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).OperatingSystem
                        $Section3AccountDataOUTextBox.Text          = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).CanonicalName
                        $Section3AccountDataIPTextBox.Text          = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).IPv4Address
                        $Section3AccountDataMACTextBox.Text         = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).MACAddress
                        $script:Section3AccountDataNotesRichTextBox.Text   = "[$($script:AccountsListMassTagValue)] " + $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).Notes
                        Save-TreeViewData -Accounts
                        $StatusListBox.Items.clear()
                        $StatusListBox.Items.Add("Tag applied to: $($script:EntrySelected.text)")
                    }
                }       
            }
            if ($This.selectedItem -eq " - Move Node To New OU/CN") { 
                $script:AccountsListContextMenuStrip.Close()

                $InformationTabControl.SelectedTab = $Section3ResultsTab

                Create-TreeViewCheckBoxArray -Accounts
                if ($script:EntrySelected) {
                    Show-MoveForm -Accounts -Title "Move: $($script:EntrySelected.Text)" -SelectedAccounts
            
                    $script:AccountsTreeView.Nodes.Clear()
                    Initialize-TreeViewData -Accounts
            
                    $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                    $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'
            
                    Foreach($Accounts in $script:AccountsTreeViewData) {
                        AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Accounts.CanonicalName -Entry $Accounts.Name -ToolTip $Accounts.SID -Metadata $Accounts
                    }
            
                    Remove-EmptyCategory -Accounts
                    Save-TreeViewData -Accounts
                    UpdateState-TreeViewData -Accounts -NoMessage
            
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Moved:  $($script:EntrySelected.text)")
                }
            }
            if ($This.selectedItem -eq " - Delete Selected Node") { 
                $script:AccountsListContextMenuStrip.Close()

                $InformationTabControl.SelectedTab = $Section3ResultsTab

                Create-TreeViewCheckBoxArray -Accounts
                if ($script:EntrySelected) {
                    $MessageBox = [System.Windows.MessageBox]::Show("Confirm Deletion of Account Node: $($script:EntrySelected.text)`r`n`r`nAll Account metadata and notes will be lost.`r`n`r`nAny previously collected data will still remain.",'Delete Account','YesNo')
    
                    Switch ( $MessageBox ) {
                        'Yes' {
                            # Removes selected Accounts nodes
                            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
                            foreach ($root in $AllTreeViewNodes) {
                                foreach ($Category in $root.Nodes) {
                                    foreach ($Entry in $Category.nodes) {
                                        if ($Entry.text -eq $script:EntrySelected.text) {
                                            # Removes the node from the treeview
                                            $Entry.remove()
                                            # Removes the Account from the variable storing the all the Accountss
                                            $script:AccountsTreeViewData = $script:AccountsTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                                        }
                                    }
                                }
                            }
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add("Deleted:  $($script:EntrySelected.text)")
    
                            $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                            $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'
    
                            #This is a bit of a workaround, but it prevents the Account data message from appearing after a Accounts node is deleted...
                            $script:FirstCheck = $false
    
                            Remove-EmptyCategory -Accounts
                            Save-TreeViewData -Accounts
                        }
                        'No' {
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add('Account Deletion Cancelled')
                        }
                    }
                }
            }
            if ($This.selectedItem -eq " - Rename Selected Node") { 
                $script:AccountsListContextMenuStrip.Close()

                $InformationTabControl.SelectedTab = $Section3ResultsTab

                Create-TreeViewCheckBoxArray -Accounts
                if ($script:EntrySelected) {
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Enter a new name:")

                    $AccountsTreeNodeRenamePopup               = New-Object system.Windows.Forms.Form
                    $AccountsTreeNodeRenamePopup.Text          = "Rename $($script:EntrySelected.text)"
                    $AccountsTreeNodeRenamePopup.Size          = New-Object System.Drawing.Size(($FormScale * 330),($FormScale * 107))
                    $AccountsTreeNodeRenamePopup.StartPosition = "CenterScreen"
                    $AccountsTreeNodeRenamePopup.Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    $AccountsTreeNodeRenamePopup.Add_Closing   = { $This.dispose() }

                    $script:AccountsTreeNodeRenamePopupTextBox          = New-Object System.Windows.Forms.TextBox
                    $script:AccountsTreeNodeRenamePopupTextBox.Text     = "New Account"
                    $script:AccountsTreeNodeRenamePopupTextBox.Size     = New-Object System.Drawing.Size(($FormScale * 300),($FormScale * 25))
                    $script:AccountsTreeNodeRenamePopupTextBox.Location = New-Object System.Drawing.Point(($FormScale * 10),($FormScale * 10))
                    $script:AccountsTreeNodeRenamePopupTextBox.Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)


                    # Renames the Accounts treenode to the specified name
                    . "$Dependencies\Code\Tree View\Accounts\Rename-AccountsTreeNodeSelected.ps1"

                    # Moves the Accounts to the new Category
                    $script:AccountsTreeNodeRenamePopupTextBox.Add_KeyDown({
                        if ($_.KeyCode -eq "Enter") { Rename-AccountsTreeNodeSelected }
                    })
                    $AccountsTreeNodeRenamePopup.Controls.Add($script:AccountsTreeNodeRenamePopupTextBox)


                    $AccountsTreeNodeRenamePopupButton = New-Object System.Windows.Forms.Button -Property @{
                        Text     = "Execute"
                        Location = @{ X = $FormScale * 210
                                    Y = $script:AccountsTreeNodeRenamePopupTextBox.Location.X + $script:AccountsTreeNodeRenamePopupTextBox.Size.Height + ($FormScale * 5) }
                        Size     = @{ Width  = $FormScale * 100
                                    Height = $FormScale * 22 }
                    }
                    CommonButtonSettings -Button $AccountsTreeNodeRenamePopupButton
                    $AccountsTreeNodeRenamePopupButton.Add_Click({ Rename-AccountsTreeNodeSelected })
                    $AccountsTreeNodeRenamePopup.Controls.Add($AccountsTreeNodeRenamePopupButton)

                    $AccountsTreeNodeRenamePopup.ShowDialog()
                }
                else {
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add($script:EntrySelected.text)
                }
                #elseif ($script:AccountsTreeViewSelected.count -lt 1) { AccountsNodeSelectedLessThanOne -Message 'Rename Selection' }
                #elseif ($script:AccountsTreeViewSelected.count -gt 1) { AccountsNodeSelectedMoreThanOne -Message 'Rename Selection' }

                Remove-EmptyCategory -Accounts
                Save-TreeViewData -Accounts
            }
        }
    }
    $AccountsListSelectedNodeActionsToolStripComboBox.Items.Add(" - Add New Account Node")
    $AccountsListSelectedNodeActionsToolStripComboBox.Items.Add(" - Tag Node With Metadata")
    $AccountsListSelectedNodeActionsToolStripComboBox.Items.Add(" - Move Node To New OU/CN")
    $AccountsListSelectedNodeActionsToolStripComboBox.Items.Add(" - Delete Selected Node")
    $AccountsListSelectedNodeActionsToolStripComboBox.Items.Add(" - Rename Selected Node")
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListSelectedNodeActionsToolStripComboBox)


    $script:AccountsListContextMenuStrip.Items.Add('-')
    $AccountsListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = 'Checked Accounts'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListRenameToolStripLabel)
    $script:AccountsListContextMenuStrip.Items.Add('-')


    $AccountsListCheckedNodeActionsToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Node Actions"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListCheckedNodeActionsToolStripLabel)


    $AccountsListCheckeddNodeActionsToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 150 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'Conduct various actions against a single node.'
        Add_SelectedIndexChanged = {
            $script:AccountsListContextMenuStrip.Close()

            if ($This.selectedItem -eq " - Uncheck All Nodes") { 
                $script:AccountsListContextMenuStrip.Close()

                ### ... I didn't feel the need to error on unchecking... becuase it's not conducting any actions on the network
                #if ($script:AccountsTreeViewSelected.count -eq 0){
                #    [System.Windows.MessageBox]::Show('Error: You need to check at least one Account.','Uncheck All')
                #}
                #else {
                    Deselect-AllAccounts
                #}
            }
            if ($This.selectedItem -eq " - Tag Nodes With Metadata") { 
                $script:AccountsListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Accounts
                if ($script:AccountsTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one Account.','Tag All')
                }
                else {
                    $InformationTabControl.SelectedTab = $Section3AccountDataTab
            
                    $script:ProgressBarAccountsProgressBar.Value = 0
                    $script:ProgressBarQueriesProgressBar.Value  = 0
            
                    Create-TreeViewCheckBoxArray -Accounts
                    if ($script:AccountsTreeViewSelected.count -ge 0) {
                        Show-TagForm -Accounts
            
                        $script:ProgressBarAccountsProgressBar.Maximum  = $script:AccountsTreeViewSelected.count
                        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
            
                        if ($script:AccountsListMassTagValue) {
                            $AccountsListMassTagArray = @()
                            foreach ($node in $script:AccountsTreeViewSelected) {
                                foreach ($root in $AllTreeViewNodes) {
                                    foreach ($Category in $root.Nodes) {
                                        foreach ($Entry in $Category.Nodes) {
                                            if ($Entry.Checked -and $Entry.Text -notin $AccountsListMassTagArray) {
                                                $AccountsListMassTagArray += $Entry.Text
                                                #batman
                                                $script:Section3AccountDataNameTextBox.Text = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                                $Section3AccountDataOSTextBox.Text          = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                                                $Section3AccountDataOUTextBox.Text          = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
                                                $Section3AccountDataIPTextBox.Text          = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).IPv4Address
                                                $Section3AccountDataMACTextBox.Text         = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                                                $script:Section3AccountDataNotesRichTextBox.Text   = "[$($script:AccountsListMassTagValue)] " + $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                                            }
                                            $script:ProgressBarAccountsProgressBar.Value += 1
                                        }
                                    }
                                }
                            }
                            Save-TreeViewData -Accounts -SaveAllChecked
                            $StatusListBox.Items.clear()
                            $StatusListBox.Items.Add("Tag Complete: $($script:AccountsTreeViewSelected.count) Accounts")
                        }
                    }
                }
            }
            if ($This.selectedItem -eq " - Move Nodes To New OU/CN") {
                $script:AccountsListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Accounts

                if ($script:AccountsTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one Account.','Move All')
                }
                else {
                    $InformationTabControl.SelectedTab = $Section3ResultsTab
            
                    if ($script:AccountsTreeViewSelected.count -ge 0) {
                        Show-MoveForm -Accounts -Title "Moving $($script:AccountsTreeViewSelected.count) Accounts"
            
                        $script:AccountsTreeView.Nodes.Clear()
                        Initialize-TreeViewData -Accounts
            
                        $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                        $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'
            
                        Foreach($Accounts in $script:AccountsTreeViewData) {
                            AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Accounts.CanonicalName -Entry $Accounts.Name -ToolTip $Accounts.SID -Metadata $Accounts
                        }
            
                        Remove-EmptyCategory -Accounts
                        Save-TreeViewData -Accounts
                        UpdateState-TreeViewData -Accounts -NoMessage
            
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Moved $($script:AccountsTreeNodeToMove.Count) Accounts")
                        $ResultsListBox.Items.Clear()
                        $ResultsListBox.Items.Add("The following accounts have been moved to $($AccountsTreeNodePopupMoveComboBox.SelectedItem):")
                    }
                    else { AccountsNodeSelectedLessThanOne -Message 'Move Selection' }
                }
            }
            if ($This.selectedItem -eq " - Delete Checked Nodes") { 
                $script:AccountsListContextMenuStrip.Close()

                Create-TreeViewCheckBoxArray -Accounts

                if ($script:AccountsTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one Account.','Delete All')
                }
                else {
                    
                    $InformationTabControl.SelectedTab = $Section3ResultsTab
            
                    if ($script:AccountsTreeViewSelected.count -eq 1) {
                        $MessageBox = [System.Windows.MessageBox]::Show("Confirm Deletion of $($script:AccountsTreeViewSelected.count) Account Node.`r`n`r`nAll Account metadata and notes will be lost.`r`nAny previously collected data will still remain.",'Delete Account','YesNo')
                    }
                    elseif ($script:AccountsTreeViewSelected.count -gt 1) {
                        $MessageBox = [System.Windows.MessageBox]::Show("Confirm Deletion of $($script:AccountsTreeViewSelected.count) Account Nodes.`r`n`r`nAll Account metadata and notes will be lost.`r`nAny previously collected data will still remain.",'Delete Accounts','YesNo')
                    }
            
                    Switch ( $MessageBox ) {
                        'Yes' {
                            if ($script:AccountsTreeViewSelected.count -gt 0) {
                                foreach ($i in $script:AccountsTreeViewSelected) {
                                    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
                                    foreach ($root in $AllTreeViewNodes) {
                                        foreach ($Category in $root.Nodes) {
                                            foreach ($Entry in $Category.nodes) {
                                                if ($Entry.checked) {
                                                    $Entry.remove()
                                                    # Removes the Account from the variable storing the all the Accountss
                                                    $script:AccountsTreeViewData = $script:AccountsTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                                                }
                                            }
                                        }
                                    }
                                }
                                # Removes selected category nodes - Note: had to put this in its own loop...
                                # the saving of nodes didn't want to work properly when use in the above loop when switching between treenode views.
                                foreach ($i in $script:AccountsTreeViewSelected) {
                                    foreach ($root in $AllTreeViewNodes) {
                                        foreach ($Category in $root.Nodes) {
                                            if ($Category.checked) { $Category.remove() }
                                        }
                                    }
                                }
                                # Removes selected root node - Note: had to put this in its own loop... see above category note
                                foreach ($i in $script:AccountsTreeViewSelected) {
                                    foreach ($root in $AllTreeViewNodes) {
                                        if ($root.checked) {
                                            foreach ($Category in $root.Nodes) { $Category.remove() }
                                            $root.remove()
                                            if ($i -eq "All Accounts") { $script:AccountsTreeView.Nodes.Add($script:TreeNodeAccountsList) }
                                        }
                                    }
                                }
            
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Deleted:  $($script:AccountsTreeViewSelected.Count) Selected Items")
                                #Removed For Testing#$ResultsListBox.Items.Clear()
                                $ResultsListBox.Items.Add("The following accounts have been deleted:  ")
                                $AccountsListDeletedArray = @()
                                foreach ($Node in $script:AccountsTreeViewSelected) {
                                    if ($Node -notin $AccountsListDeletedArray) {
                                        $AccountsListDeletedArray += $Node
                                        $ResultsListBox.Items.Add(" - $Node")
                                    }
                                }
            
                                $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                                $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'
                
                                Remove-EmptyCategory -Accounts
                                Save-TreeViewData -Accounts
                            }
                            else { AccountsNodeSelectedLessThanOne -Message 'Delete Selection' }
                        }
                        'No' {
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add('Account Deletion Cancelled')
                        }
                    }
                }
            }
        }
    }
    $AccountsListCheckeddNodeActionsToolStripComboBox.Items.Add(" - Uncheck All Nodes")
    $AccountsListCheckeddNodeActionsToolStripComboBox.Items.Add(" - Tag Nodes With Metadata")
    $AccountsListCheckeddNodeActionsToolStripComboBox.Items.Add(" - Move Nodes To New OU/CN")
    $AccountsListCheckeddNodeActionsToolStripComboBox.Items.Add(" - Delete Checked Nodes")
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListCheckeddNodeActionsToolStripComboBox)

    




















    $AccountsListAccountsAdditionalActionsToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Additional Actions"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListAccountsAdditionalActionsToolStripLabel)


    $script:AccountsListContextMenuStrip.Items.Add('-')


    $AccountsListImportAccountDataToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Import Account Data"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListImportAccountDataToolStripLabel)


    $AccountsListImportAccountsDataToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 150 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'Import Account Data from various sources. Conflicting account names will not be imported.'
        Add_SelectedIndexChanged = {
            $script:AccountsListContextMenuStrip.Close()

            if ($This.selectedItem -eq ' - Active Directory') { 
                $script:AccountsListContextMenuStrip.Close()
                Import-DataFromActiveDirectory -Accounts
            }
            if ($This.selectedItem -eq ' - Local .csv File')  { 
                $script:AccountsListContextMenuStrip.Close()
                Import-DataFromCsv -Accounts
            }
            if ($This.selectedItem -eq ' - Local .txt File')  { 
                $script:AccountsListContextMenuStrip.Close()
                Import-DataFromTxt -Accounts
            }
        }
    }
    $AccountsListImportAccountsDataToolStripComboBox.Items.Add(' - Active Directory')
    $AccountsListImportAccountsDataToolStripComboBox.Items.Add(' - Local .csv File')
    $AccountsListImportAccountsDataToolStripComboBox.Items.Add(' - Local .txt File')
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListImportAccountsDataToolStripComboBox)


    $AccountsListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = 'View Account Data'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListRenameToolStripLabel)


    $AccountsListViewAccountsDataToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 150 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'View the local data for all accounts that populates the treeview.'
        Add_SelectedIndexChanged = {
            $script:AccountsListContextMenuStrip.Close()

            if ($This.selectedItem -eq ' - Out-GridView') { 
                $script:AccountsListContextMenuStrip.Close()
                Import-Csv -Path $script:AccountsTreeNodeFileSave | Out-GridView -Title 'Account Data'
            }
            if ($This.selectedItem -eq ' - Spreadsheet Software')  { 
                $script:AccountsListContextMenuStrip.Close()
                Invoke-Item -Path $script:AccountsTreeNodeFileSave
            }
            if ($This.selectedItem -eq ' - Browser HTML View')  { 
                $script:AccountsListContextMenuStrip.Close()
                Import-Csv -Path $script:AccountsTreeNodeFileSave | Out-HTMLView -Title 'Account Data'
            }
        }
    }
    $AccountsListViewAccountsDataToolStripComboBox.Items.Add(' - Out-GridView')
    $AccountsListViewAccountsDataToolStripComboBox.Items.Add(' - Spreadsheet Software')
    $AccountsListViewAccountsDataToolStripComboBox.Items.Add(' - Browser HTML View')
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListViewAccountsDataToolStripComboBox)    


    $AccountsListAccountsUpdateTreeviewToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = 'Update TreeView'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListAccountsUpdateTreeviewToolStripLabel)


    $AccountsListAccountsUpdateTreeviewToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size        = @{ Width  = $FormScale * 150 }
        Text        = '  - Make a selection'
        ForeColor   = 'Black'
        ToolTipText = 'Quickly modify the account treeview to better manage and find nodes.'
        Add_SelectedIndexChanged = {
            $script:AccountsListContextMenuStrip.Close()
            
            if ($This.selectedItem -eq ' - Collapsed View') { 
                $script:AccountsListContextMenuStrip.Close()

                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
                $script:AccountsTreeView.CollapseAll()
                foreach ($root in $AllTreeViewNodes) { $root.Expand() }
            }
            if ($This.selectedItem -eq ' - Normal View')  { 
                $script:AccountsListContextMenuStrip.Close()

                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
                $script:AccountsTreeView.CollapseAll()
                foreach ($root in $AllTreeViewNodes) {  
                    $root.Expand() 
                    foreach ($Category in $root.nodes) {
                        $Category.Expand()
                    }
                }
            }
            if ($This.selectedItem -eq ' - Expanded View')  { 
                $script:AccountsListContextMenuStrip.Close()

                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
                foreach ($root in $AllTreeViewNodes) {  
                    $root.Expand() 
                    foreach ($Category in $root.nodes) {
                        $Category.Expand()
                        foreach ($Entry in $Category.nodes){
                            $Entry.Expand()
                            foreach($Metadata in $Entry.nodes){
                                $Metadata.Expand()
                                foreach($Data in $Metadata.nodes){
                                    $Data.Expand()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    $AccountsListAccountsUpdateTreeviewToolStripComboBox.Items.Add(' - Collapsed View')
    $AccountsListAccountsUpdateTreeviewToolStripComboBox.Items.Add(' - Normal View')
    $AccountsListAccountsUpdateTreeviewToolStripComboBox.Items.Add(' - Expanded View')
    $script:AccountsListContextMenuStrip.Items.Add($AccountsListAccountsUpdateTreeviewToolStripComboBox)    


    $script:AccountsListContextMenuStrip.Items.Add('-')




















        $script:AccountsListContextMenuStrip.Items.Add('-')
        $AccountsListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
            Text      = 'View Account Data'
            Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
            ForeColor = 'Blue'
        }
        $script:AccountsListContextMenuStrip.Items.Add($AccountsListRenameToolStripLabel)
        $script:AccountsListContextMenuStrip.Items.Add('-')
        
        
        $AccountsListOpenGridViewCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Out-GridView"
            Add_CLick = {
                Import-Csv -Path $script:AccountsTreeNodeFileSave | Out-GridView -Title 'Account Data'
            }
        }
        $script:AccountsListContextMenuStrip.Items.Add($AccountsListOpenGridViewCheckToolStripButton)
        
        $AccountsListOpenSpreadsheetCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Spreadsheet"
            Add_CLick = {
                Invoke-Item -Path $script:AccountsTreeNodeFileSave
            }
        }
        $script:AccountsListContextMenuStrip.Items.Add($AccountsListOpenSpreadsheetCheckToolStripButton)
        
        
        $AccountsListOpenHtmlViewCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Browser HTML View"
            Add_CLick = {
                Import-Csv -Path $script:AccountsTreeNodeFileSave | Out-HTMLView -Title 'Account Data'
            }
        }
        $script:AccountsListContextMenuStrip.Items.Add($AccountsListOpenHtmlViewCheckToolStripButton)


    $Entry.ContextMenuStrip = $script:AccountsListContextMenuStrip
}


