function Display-ContextMenuForAccountsTreeNode {
    Create-TreeViewCheckBoxArray -Accounts

    $AccountsListContextMenuStrip.Items.Remove($AccountsListRenameToolStripButton)
    $AccountsListContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip -Property @{
        ShowCheckMargin = $false
        ShowImageMargin = $false
        ShowItemToolTips = $false
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
    }

    #$AccountsListContextMenuStrip.Items.Add("$($Entry.Text)")
    $script:AccountsListAccountNameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "$($Entry.Text)"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $AccountsListContextMenuStrip.Items.Add($script:AccountsListAccountNameToolStripLabel)

    $AccountsListContextMenuStrip.Items.Add('-')


    # if ($script:AccountsListPivotExecutionCheckbox.checked -eq $false) {
    #     $AccountsListRemoteDesktopToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    #         Text      = "Remote Desktop"
    #         ForeColor = 'DarkRed'
    #         Add_CLick = $AccountsListRDPButtonAdd_Click
    #     }
    #     $AccountsListContextMenuStrip.Items.Add($AccountsListRemoteDesktopToolStripButton)


    #     $AccountsListPSSessionToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    #         Text      = "PSSession"
    #         ForeColor = 'DarkRed'
    #         Add_CLick = $AccountsListPSSessionButtonAdd_Click
    #     }
    #     $AccountsListContextMenuStrip.Items.Add($AccountsListPSSessionToolStripButton)


    #     if (Test-Path $PsExecPath) {
    #         $AccountsListPSExecToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    #             Text      = "PSExec"
    #             ForeColor = 'DarkRed'
    #             Add_Click = $AccountsListPsExecButtonAdd_Click
    #         }
    #         $AccountsListContextMenuStrip.Items.Add($AccountsListPSExecToolStripButton)
    #     }


    #     if (Test-Path $kitty_ssh_client) {
    #         $AccountsListSSHToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    #             Text      = "SSH"
    #             ForeColor = 'DarkRed'
    #             Add_CLick = $AccountsListSSHButtonAdd_Click
    #         }
    #         $AccountsListContextMenuStrip.Items.Add($AccountsListSSHToolStripButton)
    #     }

        
    #     $EventViewerButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    #         Text      = "Event Viewer"
    #         ForeColor = 'DarkRed'
    #         Add_CLick = $EventViewerButtonAdd_Click
    #     }
    #     $AccountsListContextMenuStrip.Items.Add($EventViewerButton)
    # }
    # elseif ($script:AccountsListPivotExecutionCheckbox.checked -eq $true) {
    #     $AccountsListPSSessionPivotToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    #         Text      = "Pivot-PSSession"
    #         ForeColor = 'DarkRed'
    #         Add_Click = $AccountsListPSSessionPivotButtonAdd_Click
    #     }
    #     $AccountsListContextMenuStrip.Items.Add($AccountsListPSSessionPivotToolStripButton)
    # }

    
    $script:ExpandCollapseStatus = "Collapse"
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


    $AccountsListTagSelectedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Tag"
        Add_CLick = {
            $InformationTabControl.SelectedTab = $Section3HostDataTab

            if ($script:EntrySelected) {
                Show-TagForm
                if ($script:AccountsListMassTagValue) {
                    $script:Section3HostDataNameTextBox.Text  = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).Name
                    $Section3HostDataOSTextBox.Text    = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).OperatingSystem
                    $Section3HostDataOUTextBox.Text    = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).CanonicalName
                    $Section3HostDataIPTextBox.Text    = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).IPv4Address
                    $Section3HostDataMACTextBox.Text   = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).MACAddress
                    $Section3HostDataNotesRichTextBox.Text = "[$($script:AccountsListMassTagValue)] " + $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).Notes
                    Save-TreeViewData -Accounts
                    Check-HostDataIfModified
                    $StatusListBox.Items.clear()
                    $StatusListBox.Items.Add("Tag applied to: $($script:EntrySelected.text)")
                }
            }            
        }
    }
    $AccountsListContextMenuStrip.Items.Add($AccountsListTagSelectedToolStripButton)

    
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


    $AccountsListRenameToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Rename"
        Add_CLick = {
            # This brings specific tabs to the forefront/front view
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
    $AccountsListContextMenuStrip.Items.Add($AccountsListRenameToolStripButton)


    $AccountsListMoveToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Move"
        Add_CLick = {
            $InformationTabControl.SelectedTab = $Section3ResultsTab

            Create-TreeViewCheckBoxArray -Accounts
            if ($script:EntrySelected) {
                Show-MoveForm -Accounts -Title "Move: $($script:EntrySelected.Text)" -SelectedAccounts
        
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
                $StatusListBox.Items.Add("Moved:  $($script:EntrySelected.text)")
            }            
        }
    }
    $AccountsListContextMenuStrip.Items.Add($AccountsListMoveToolStripButton)


    $AccountsListDeleteSelectedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        #Text      = "Delete:  $($script:EntrySelected.text)"
        Text      = "Delete"
        Add_CLick = {
            # This brings specific tabs to the forefront/front view
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
                                        # Removes the host from the variable storing the all the Accountss
                                        $script:AccountsTreeViewData = $script:AccountsTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                                    }
                                }
                            }
                        }
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Deleted:  $($script:EntrySelected.text)")

                        $AccountsAndAccountTreeViewTabControl.SelectedTab = $AccountsTreeviewTab
                        $script:AccountsTreeNodeComboBox.SelectedItem = 'CanonicalName'

                        #This is a bit of a workaround, but it prevents the host data message from appearing after a Accounts node is deleted...
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
    }
    $AccountsListContextMenuStrip.Items.Add($AccountsListDeleteSelectedToolStripButton)


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


        # $AccountsListNSLookupCheckedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        #     Text      = "NSLookup"
        #     Add_CLick = {
        #         if ($script:AccountsTreeViewSelected.count -eq 0){
        #             [System.Windows.MessageBox]::Show('Error: You need to check at least one Account.','NSLookup')
        #         }
        #         else {
        #             $InformationTabControl.SelectedTab = $Section3HostDataTab
            
        #             $script:ProgressBarAccountsProgressBar.Value     = 0
        #             $script:ProgressBarQueriesProgressBar.Value       = 0
            
        #             Create-TreeViewCheckBoxArray -Accounts
        #             if ($script:AccountsTreeViewSelected.count -ge 0) {
            
        #                 $MessageBox = [System.Windows.Forms.MessageBox]::Show("Conduct an NSLookup of $($script:AccountsTreeViewSelected.count) Accounts?","NSLookup",'YesNo','Info')
        #                 Switch ( $MessageBox ) {
        #                     'Yes' {
        #                         $MessageBoxAnswer = $true
        #                     }
        #                     'No' {
        #                         $MessageBoxAnswer = $false
        #                         $StatusListBox.Items.Clear()
        #                         $StatusListBox.Items.Add('NSLookup Cancelled')
        #                     }
        #                 }
            
        #                 $script:ProgressBarAccountsProgressBar.Maximum  = $script:AccountsTreeViewSelected.count
        #                 [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:AccountsTreeView.Nodes
            
        #                 if ($MessageBoxAnswer -eq $true) {
        #                     $AccountsListNSLookupArray = @()
        #                     foreach ($node in $script:AccountsTreeViewSelected) {
        #                         foreach ($root in $AllTreeViewNodes) {
        #                             foreach ($Category in $root.Nodes) {
        #                                 foreach ($Entry in $Category.Nodes) {
        #                                     $LookupAccount = $null
            
        #                                     if ($Entry.Checked -and $Entry.Text -notin $AccountsListNSLookupArray) {
        #                                         $AccountsListNSLookupArray += $Entry.Text
        #                                         $script:Section3HostDataNameTextBox.Text = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
        #                                         $Section3HostDataOSTextBox.Text   = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
        #                                         $Section3HostDataOUTextBox.Text   = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
            
        #                                         $LookupAccount = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
        #                                         $NSlookup = $((Resolve-DnsName "$LookupAccount" | Sort-Object IPAddress | Select-Object -ExpandProperty IPAddress -Unique) -Join ', ')
        #                                         $Section3HostDataIPTextBox.Text   = $NSlookup
            
        #                                         $Section3HostDataMACTextBox.Text  = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
        #                                         $Section3HostDataNotesRichTextBox.Text = $($script:AccountsTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
        #                                         Save-TreeViewData -Accounts
            
        #                                     }
        #                                     $script:ProgressBarAccountsProgressBar.Value += 1
        #                                 }
        #                             }
        #                         }
        #                     }
        #      #               Save-TreeViewData -Accounts -SaveAllChecked
        #      #               Check-HostDataIfModified
        #                     $StatusListBox.Items.clear()
        #                     $StatusListBox.Items.Add("NSLookup Complete: $($script:AccountsTreeViewSelected.count) Accounts")
        #                 }
        #             }
        #         }                
        #     }
        # }
        # $AccountsListContextMenuStrip.Items.Add($AccountsListNSLookupCheckedToolStripButton)


        $AccountsListTagAllCheckedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
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
        $AccountsListContextMenuStrip.Items.Add($AccountsListTagAllCheckedToolStripButton)

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
                            AddTreeNodeTo-TreeViewData -Accounts -RootNode $script:TreeNodeAccountsList -Category $Accounts.CanonicalName -Entry $Accounts.Name -ToolTip 'No ToolTip Data' -Metadata $Accounts
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

        $AccountsListDeleteAllCheckedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
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
        $AccountsListContextMenuStrip.Items.Add($AccountsListDeleteAllCheckedToolStripButton)


        # $AccountsListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        #     Text      = 'Test Connection'
        #     Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        #     ForeColor = 'Black'
        # }
        # $AccountsListContextMenuStrip.Items.Add($AccountsListRenameToolStripLabel)


        # $AccountsListPingToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        #     Text      = "   - ICMP Ping"
        #     ForeColor = 'DarkRed'
        #     Add_CLick = {
        #         Create-TreeViewCheckBoxArray -Accounts

        #         if ($script:AccountsTreeViewSelected.count -eq 0){
        #             [System.Windows.MessageBox]::Show('Error: You need to check at least one Account.','Ping')
        #         }
        #         else {
        #             if (Verify-Action -Title "Verification: Ping Test" -Question "Conduct a Ping test to the following?" -Accounts $($script:AccountsTreeViewSelected -join ', ')) {
        #                 Check-Connection -CheckType "Ping" -MessageTrue "Able to Ping" -MessageFalse "Unable to Ping"
        #             }
        #             else {
        #                 [system.media.systemsounds]::Exclamation.play()
        #                 $StatusListBox.Items.Clear()
        #                 $StatusListBox.Items.Add("Ping:  Cancelled")
        #             }
        #         }            
        #     }
        # }
        # $AccountsListContextMenuStrip.Items.Add($AccountsListPingToolStripButton)


        # $AccountsListRPCCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        #     Text      = "   - RPC Port Check"
        #     ForeColor = 'DarkRed'
        #     Add_CLick = {
        #         Create-TreeViewCheckBoxArray -Accounts

        #         if ($AccountsListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
        #         else {$Username = $PoShEasyWinAccountLaunch }
            
        #         if ($script:AccountsTreeViewSelected.count -eq 0){
        #             [System.Windows.MessageBox]::Show('Error: You need to check at least one Account.','RPC Port Check')
        #         }
        #         else {
        #             if (Verify-Action -Title "Verification: RPC Port Check" -Question "Connecting Account:  $Username`n`nConduct a RPC Port Check to the following?" -Accounts $($script:AccountsTreeViewSelected -join ', ')) {
        #                 Check-Connection -CheckType "RPC Port Check" -MessageTrue "RPC Port 135 is Open" -MessageFalse "RPC Port 135 is Closed"
        #             }
        #             else {
        #                 [system.media.systemsounds]::Exclamation.play()
        #                 $StatusListBox.Items.Clear()
        #                 $StatusListBox.Items.Add("RPC Port Check:  Cancelled")
        #             }
        #         }            
        #     }
        # }
        # $AccountsListContextMenuStrip.Items.Add($AccountsListRPCCheckToolStripButton)


        # $AccountsListSMBCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        #     Text      = "   - SMB Port Check"
        #     ForeColor = 'DarkRed'
        #     Add_CLick = {
        #         Create-TreeViewCheckBoxArray -Accounts

        #         if ($AccountsListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
        #         else {$Username = $PoShEasyWinAccountLaunch }
            
        #         if ($script:AccountsTreeViewSelected.count -eq 0){
        #             [System.Windows.MessageBox]::Show('Error: You need to check at least one Account.','SMB Port Check')
        #         }
        #         else {
        #             if (Verify-Action -Title "Verification: SMB Port Check" -Question "Connecting Account:  $Username`n`nConduct a SMB Port Check to the following?" -Accounts $($script:AccountsTreeViewSelected -join ', ')) {
        #                 Check-Connection -CheckType "SMB Port Check" -MessageTrue "SMB Port 445 is Open" -MessageFalse "SMB Port 445 is Closed"
        #             }
        #             else {
        #                 [system.media.systemsounds]::Exclamation.play()
        #                 $StatusListBox.Items.Clear()
        #                 $StatusListBox.Items.Add("SMB Port Check:  Cancelled")
        #             }
        #         }                
        #     }
        # }
        # $AccountsListContextMenuStrip.Items.Add($AccountsListSMBCheckToolStripButton)


        # $AccountsListWinRMCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        #     Text      = "   - WinRM Check"
        #     ForeColor = 'DarkRed'
        #     Add_CLick = {
        #         Create-TreeViewCheckBoxArray -Accounts

        #         if ($AccountsListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
        #         else {$Username = $PoShEasyWinAccountLaunch }
            
        #         if ($script:AccountsTreeViewSelected.count -lt 1){
        #             [System.Windows.MessageBox]::Show('Error: You need to check at least one Account.','WinRM Check')
        #         }
        #         else {
        #             if (Verify-Action -Title "Verification: WinRM Check" -Question "Connecting Account:  $Username`n`nConduct a WinRM Check to the following?" -Accounts $($script:AccountsTreeViewSelected -join ', ')) {
        #                 Check-Connection -CheckType "WinRM Check" -MessageTrue "Able to Verify WinRM" -MessageFalse "Unable to Verify WinRM"
        #             }
        #             else {
        #                 [system.media.systemsounds]::Exclamation.play()
        #                 $StatusListBox.Items.Clear()
        #                 $StatusListBox.Items.Add("WinRM Check:  Cancelled")
        #             }
        #         }                
        #     }
        # }
        # $AccountsListContextMenuStrip.Items.Add($AccountsListWinRMCheckToolStripButton)



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


    $Entry.ContextMenuStrip = $AccountsListContextMenuStrip
}


