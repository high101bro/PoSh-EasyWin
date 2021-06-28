# Context Menu Strip for when clicking within the treeview but not on an Account node
#Display-ContextMenuForAccountsTreeView

$AccountsListContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip -Property @{
    ShowCheckMargin = $false
    ShowImageMargin = $false
    ShowItemToolTips = $True
    Width    = 100
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
    ForeColor = 'Black'
}


$AccountsListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
    Text      = "Select an Account"
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
}
$AccountsListContextMenuStrip.Items.Add($AccountsListRenameToolStripLabel)
$AccountsListContextMenuStrip.Items.Add('-')


$AccountsListLeftClickToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
    Text      = "Left-Click an Account Node,`nthen Right-Click for more Options"
    ForeColor = 'DarkRed'
}
$AccountsListContextMenuStrip.Items.Add($AccountsListLeftClickToolStripLabel)


$AccountsListCollapseToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Collapse"
    Add_CLick = {
        if ($script:ExpandCollapseStatus -eq "Collapse") {
            $script:AccountsTreeView.CollapseAll()
            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
            foreach ($root in $AllTreeViewNodes) {  $root.Expand() }
            $AccountsListCollapseToolStripButton.Text = "Expand"
            $script:ExpandCollapseStatus = "Expand"
        }
        elseif ($script:ExpandCollapseStatus -eq "Expand") {
            $script:AccountsTreeView.ExpandAll()
            $AccountsListCollapseToolStripButton.Text = "Collapse"
            $script:ExpandCollapseStatus = "Collapse"
        }
    }
}
$AccountsListContextMenuStrip.Items.Add($AccountsListCollapseToolStripButton)


$AccountsListAddAccountToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Add an Account"
    Add_CLick = {
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
    
    
        $AccountsTreeNodePopupAddHostButton = New-Object System.Windows.Forms.Button -Property @{
            Text     = "Add an Account"
            Location = @{ X = $FormScale * 210
                          Y = $AccountsTreeNodePopupOUComboBox.Location.Y + $AccountsTreeNodePopupOUComboBox.Size.Height + $($FormScale * 10) }
            Width  = $FormScale * 100
            Height = $FormScale * 25
            Add_Click = { AddAccount-AccountsTreeNode }
            Add_KeyDown = { if ($_.KeyCode -eq "Enter") { AddAccount-AccountsTreeNode } }    
        }
        CommonButtonSettings -Button $AccountsTreeNodePopupAddHostButton
        $AccountsTreeNodePopup.Controls.Add($AccountsTreeNodePopupAddHostButton)
    
        # $script:AccountsTreeView.ExpandAll()
        # Remove-EmptyCategory -Accounts
        # Normalize-TreeViewData -Accounts
        # Save-TreeViewData -Accounts
        $AccountsTreeNodePopup.ShowDialog()        
    }
}
$AccountsListContextMenuStrip.Items.Add($AccountsListAddAccountToolStripButton)


$AccountsListContextMenuStrip.Items.Add('-')
$AccountsListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
    Text      = 'Checked Accounts'
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
}
$AccountsListContextMenuStrip.Items.Add($AccountsListRenameToolStripLabel)
$AccountsListContextMenuStrip.Items.Add('-')


$AccountsListDeselectAllToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Uncheck All"
    Add_CLick = {
        ### ... I didn't feel the need to error on unchecking... becuase it's not conducting any actions on the network
        #if ($script:AccountsTreeViewSelected.count -eq 0){
        #    [System.Windows.MessageBox]::Show('Error: You need to check at least one Account.','Uncheck All')
        #}
        #else {
            Deselect-AllAccounts
        #}
    }
}
$AccountsListContextMenuStrip.Items.Add($AccountsListDeselectAllToolStripButton)


$AccountsListMassTagToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Tag All"
    Add_CLick = {
        Create-TreeViewCheckBoxArray -Accounts
        if ($script:AccountsTreeViewSelected.count -eq 0){
            [System.Windows.MessageBox]::Show('Error: You need to check at least one Account.','Tag All')
        }
        else {
            $InformationTabControl.SelectedTab = $Section3HostDataTab
    
            $script:ProgressBarAccountsProgressBar.Value     = 0
            $script:ProgressBarQueriesProgressBar.Value       = 0
    
            Create-TreeViewCheckBoxArray -Accounts
            if ($script:AccountsTreeViewSelected.count -ge 0) {
                Show-TagForm
    
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
                                        $script:Section3HostDataNameTextBox.Text      = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                        $Section3HostDataOSTextBox.Text        = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                                        $Section3HostDataOUTextBox.Text        = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
                                        $Section3HostDataIPTextBox.Text        = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).IPv4Address
                                        $Section3HostDataMACTextBox.Text       = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                                        $Section3HostDataNotesRichTextBox.Text = "[$($script:AccountsListMassTagValue)] " + $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                                    }
                                    $script:ProgressBarAccountsProgressBar.Value += 1
                                }
                            }
                        }
                    }
                    Save-TreeViewData -Accounts -SaveAllChecked
                    Check-HostDataIfModified
                    $StatusListBox.Items.clear()
                    $StatusListBox.Items.Add("Tag Complete: $($script:AccountsTreeViewSelected.count) Accounts")
                }
            }
        }        
    }
}
$AccountsListContextMenuStrip.Items.Add($AccountsListMassTagToolStripButton)

<#
$AccountsListMoveToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Move All"
    Add_CLick = {
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
                    AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Accounts.CanonicalName -Entry $Accounts.Name -ToolTip 'No ToolTip Data' -IPv4Address $Accounts.IPv4Address  -Metadata $Accounts
                }
    
                Remove-EmptyCategory -Accounts
                Save-TreeViewData -Accounts
                UpdateState-TreeViewData -Accounts -NoMessage
    
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Moved $($script:AccountsTreeNodeToMove.Count) Accounts")
                $ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add("The following hostnames/IPs have been moved to $($AccountsTreeNodePopupMoveComboBox.SelectedItem):")
            }
            else { AccountsNodeSelectedLessThanOne -Message 'Move Selection' }
        }        
    }
}
$AccountsListContextMenuStrip.Items.Add($AccountsListMoveToolStripButton)
#>

$AccountsListDeleteToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Delete All"
    Add_CLick = {
        Create-TreeViewCheckBoxArray -Accounts

        if ($script:AccountsTreeViewSelected.count -eq 0){
            [System.Windows.MessageBox]::Show('Error: You need to check at least one Account.','Delete All')
        }
        else {
            # This brings specific tabs to the forefront/front view
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
                                            # Removes the host from the variable storing the all the Accountss
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
                        $ResultsListBox.Items.Add("The following hosts have been deleted:  ")
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
$AccountsListContextMenuStrip.Items.Add($AccountsListDeleteToolStripButton)


$AccountsListContextMenuStrip.Items.Add('-')
$AccountsListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
    Text      = 'View Account Data'
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
}
$AccountsListContextMenuStrip.Items.Add($AccountsListRenameToolStripLabel)
$AccountsListContextMenuStrip.Items.Add('-')


$AccountsListOpenGridViewCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Out-GridView"
    Add_CLick = {
        Import-Csv -Path $script:AccountsTreeNodeFileSave | Out-GridView -Title 'Account Data'
    }
}
$AccountsListContextMenuStrip.Items.Add($AccountsListOpenGridViewCheckToolStripButton)

$AccountsListOpenSpreadsheetCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Spreadsheet"
    Add_CLick = {
        Invoke-Item -Path $script:AccountsTreeNodeFileSave
    }
}
$AccountsListContextMenuStrip.Items.Add($AccountsListOpenSpreadsheetCheckToolStripButton)


$AccountsListOpenHtmlViewCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Browser HTML View"
    Add_CLick = {
        Import-Csv -Path $script:AccountsTreeNodeFileSave | Out-HTMLView -Title 'Account Data'
    }
}
$AccountsListContextMenuStrip.Items.Add($AccountsListOpenHtmlViewCheckToolStripButton)

