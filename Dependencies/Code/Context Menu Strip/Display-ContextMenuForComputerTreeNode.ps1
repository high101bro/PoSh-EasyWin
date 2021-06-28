function Display-ContextMenuForComputerTreeNode {
    Create-TreeViewCheckBoxArray -Endpoint

    $ComputerListContextMenuStrip.Items.Remove($ComputerListRenameToolStripButton)
    $ComputerListContextMenuStrip = New-Object System.Windows.Forms.ContextMenuStrip -Property @{
        ShowCheckMargin = $false
        ShowImageMargin = $false
        ShowItemToolTips = $false
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
        ForeColor = 'Black'
    }

    #$ComputerListContextMenuStrip.Items.Add("Import Endpoints")
    $ComputerListImportEndpointsToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Import Endpoints"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListImportEndpointsToolStripLabel)

    $ComputerListImportEndpointsToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size = @{ Width  = $FormScale * 125 }
        Text = '   - Make a selection'
        ForeColor = 'DarkRed'
        ToolTipText = 'Import Endpoint Data from various sources. Duplicate names will not be imported.'
        Add_SelectedIndexChanged = {
            if ($This.selectedItem -eq 'Active Directory') { 
                & $ImportEndpointDataFromActiveDirectoryButtonAdd_Click
            }
            if ($This.selectedItem -eq 'Local .csv File')  { 
                & $ImportEndpointDataFromCsvButtonAdd_Click
            }
            if ($This.selectedItem -eq 'Local .txt File')  { 
                & $ImportEndpointDataFromTxtButtonAdd_Click
            }
        }
    }
    $ComputerListImportEndpointsToolStripComboBox.Items.Add('Active Directory')
    $ComputerListImportEndpointsToolStripComboBox.Items.Add('Local .csv File')
    $ComputerListImportEndpointsToolStripComboBox.Items.Add('Local .txt File')
    $ComputerListContextMenuStrip.Items.Add($ComputerListImportEndpointsToolStripComboBox)

    $ComputerListContextMenuStrip.Items.Add('-')


    $script:ComputerListEndpointNameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "$($Entry.Text)"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $ComputerListContextMenuStrip.Items.Add($script:ComputerListEndpointNameToolStripLabel)

    $ComputerListContextMenuStrip.Items.Add('-')


    if ($script:ComputerListPivotExecutionCheckbox.checked -eq $false) {
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


        if (Test-Path $PsExecPath) {
            $ComputerListPSExecToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
                Text      = "PSExec"
                ForeColor = 'DarkRed'
                Add_Click = $ComputerListPsExecButtonAdd_Click
            }
            $ComputerListContextMenuStrip.Items.Add($ComputerListPSExecToolStripButton)
        }


        if (Test-Path $kitty_ssh_client) {
            $ComputerListSSHToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
                Text      = "SSH"
                ForeColor = 'DarkRed'
                Add_CLick = $ComputerListSSHButtonAdd_Click
            }
            $ComputerListContextMenuStrip.Items.Add($ComputerListSSHToolStripButton)
        }

        
        $EventViewerButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Event Viewer"
            ForeColor = 'DarkRed'
            Add_CLick = $EventViewerButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($EventViewerButton)
    }
    elseif ($script:ComputerListPivotExecutionCheckbox.checked -eq $true) {
        $ComputerListPSSessionPivotToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
            Text      = "Pivot-PSSession"
            ForeColor = 'DarkRed'
            Add_Click = $ComputerListPSSessionPivotButtonAdd_Click
        }
        $ComputerListContextMenuStrip.Items.Add($ComputerListPSSessionPivotToolStripButton)
    }

    

    






















    $script:ExpandCollapseStatus = "Collapse"
    $ComputerListCollapseToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
        Text      = "Collapse"
        Add_CLick = {
            if ($script:ExpandCollapseStatus -eq "Collapse") {
                $script:ComputerTreeView.CollapseAll()
                [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                foreach ($root in $AllTreeViewNodes) {  $root.Expand() }
                $ComputerListCollapseToolStripButton.Text = "Expand"
                $script:ExpandCollapseStatus = "Expand"
            }
            elseif ($script:ExpandCollapseStatus -eq "Expand") {
                $script:ComputerTreeView.ExpandAll()
                $ComputerListCollapseToolStripButton.Text = "Collapse"
                $script:ExpandCollapseStatus = "Collapse"
            }
        }
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListCollapseToolStripButton)


    $ComputerListSelectedNodeActionsToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Selected Node Actions"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListSelectedNodeActionsToolStripLabel)


    $ComputerListSelectedNodeActionsToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size = @{ Width  = $FormScale * 125 }
        Text = '   - Make a selection'
        ForeColor = 'DarkRed'
        ToolTipText = 'Import Endpoint Data from various sources. Duplicate names will not be imported.'
        Add_SelectedIndexChanged = {
            if ($This.selectedItem -eq 'Tag') { 
                $InformationTabControl.SelectedTab = $Section3HostDataTab

                if ($script:EntrySelected) {
                    Show-TagForm
                    if ($script:ComputerListMassTagValue) {
                        $script:Section3HostDataNameTextBox.Text  = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).Name
                        $Section3HostDataOSTextBox.Text    = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).OperatingSystem
                        $Section3HostDataOUTextBox.Text    = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).CanonicalName
                        $Section3HostDataIPTextBox.Text    = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).IPv4Address
                        $Section3HostDataMACTextBox.Text   = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).MACAddress
                        $Section3HostDataNotesRichTextBox.Text = "[$($script:ComputerListMassTagValue)] " + $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $script:EntrySelected.Text}).Notes
                        Save-TreeViewData -Endpoint
                        Check-HostDataIfModified
                        $StatusListBox.Items.clear()
                        $StatusListBox.Items.Add("Tag applied to: $($script:EntrySelected.text)")
                    }
                }   
            }
            if ($This.selectedItem -eq 'Add Endpoint')  { 
                $StatusListBox.Items.Clear()
                $StatusListBox.Items.Add("Add hostname/IP:")
            
            
                $ComputerTreeNodePopup = New-Object system.Windows.Forms.Form -Property @{
                    Text          = "Add Hostname/IP"
                    Width  = $FormScale * 335
                    Height = $FormScale * 177
                    StartPosition = "CenterScreen"
                    Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    Icon          = [System.Drawing.Icon]::ExtractAssociatedIcon("$EasyWinIcon")
                    Add_Closing = { $This.dispose() }
                }
            
            
                $ComputerTreeNodePopupAddTextBox = New-Object System.Windows.Forms.TextBox -Property @{
                    Text     = "Enter a hostname/IP"
                    Location = @{ X = $FormScale * 10
                                  Y = $FormScale * 10 }
                    Width  = $FormScale * 300
                    Height = $FormScale * 25
                    Font     = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $ComputerTreeNodePopupAddTextBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AddHost-ComputerTreeNode } })
                $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupAddTextBox)
            
            
                $ComputerTreeNodePopupOSComboBox  = New-Object System.Windows.Forms.ComboBox -Property @{
                    Text = "Select an Operating System (or type in a new one)"
                    Location = @{ X = $FormScale * 10
                                  Y = $ComputerTreeNodePopupAddTextBox.Location.Y + $ComputerTreeNodePopupAddTextBox.Size.Height + $($FormScale * 10) }
                    Width  = $FormScale * 300
                    Height = $FormScale * 25
                    AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
                    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
                    Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $ComputerTreeNodeOSCategoryList = $script:ComputerTreeViewData | Select-Object -ExpandProperty OperatingSystem -Unique
            
            
                # Dynamically creates the OS Category combobox list used for OS Selection
                ForEach ($OS in $ComputerTreeNodeOSCategoryList) { $ComputerTreeNodePopupOSComboBox.Items.Add($OS) }
                $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupOSComboBox)
            
            
                $ComputerTreeNodePopupOUComboBox = New-Object System.Windows.Forms.ComboBox -Property @{
                    Text  = "Select an Organizational Unit / Canonical Name (or type a new one)"
                    Location = @{ X = $FormScale * 10
                                  Y = $ComputerTreeNodePopupOSComboBox.Location.Y + $ComputerTreeNodePopupOSComboBox.Size.Height + $($FormScale * 10) }
                    Width  = $FormScale * 300
                    Height = $FormScale * 25
                    AutoCompleteSource = "ListItems" # Options are: FileSystem, HistoryList, RecentlyUsedList, AllURL, AllSystemSources, FileSystemDirectories, CustomSource, ListItems, None
                    AutoCompleteMode   = "SuggestAppend" # Options are: "Suggest", "Append", "SuggestAppend"
                    Font               = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                }
                $ComputerTreeNodeOUCategoryList = $script:ComputerTreeViewData | Select-Object -ExpandProperty CanonicalName -Unique
                # Dynamically creates the OU Category combobox list used for OU Selection
                ForEach ($OU in $ComputerTreeNodeOUCategoryList) { $ComputerTreeNodePopupOUComboBox.Items.Add($OU) }
                $ComputerTreeNodePopupOUComboBox.Add_KeyDown({ if ($_.KeyCode -eq "Enter") { AddHost-ComputerTreeNode } })
                $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupOUComboBox)
            
                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
            
                if ($Script:CategorySelected){ $ComputerTreeNodePopupOUComboBox.Text = $Script:CategorySelected.text }
                elseif ($Script:EntrySelected){ $ComputerTreeNodePopupOUComboBox.Text = $Script:EntrySelected.text }
                else { $ComputerTreeNodePopupOUComboBox.Text  = "Select an Organizational Unit / Canonical Name (or type a new one)" }
            
            
                $ComputerTreeNodePopupAddHostButton = New-Object System.Windows.Forms.Button -Property @{
                    Text     = "Add Host"
                    Location = @{ X = $FormScale * 210
                                  Y = $ComputerTreeNodePopupOUComboBox.Location.Y + $ComputerTreeNodePopupOUComboBox.Size.Height + $($FormScale * 10) }
                    Width  = $FormScale * 100
                    Height = $FormScale * 25
                    Add_Click = { AddHost-ComputerTreeNode }
                    Add_KeyDown = { if ($_.KeyCode -eq "Enter") { AddHost-ComputerTreeNode } }    
                }
                CommonButtonSettings -Button $ComputerTreeNodePopupAddHostButton
                $ComputerTreeNodePopup.Controls.Add($ComputerTreeNodePopupAddHostButton)
            
                # $script:ComputerTreeView.ExpandAll()
                # Remove-EmptyCategory -Endpoint
                # Normalize-TreeViewData -Endpoint
                # Save-TreeViewData -Endpoint
                $ComputerTreeNodePopup.ShowDialog()
            }
            if ($This.selectedItem -eq 'Rename')  { 
                # This brings specific tabs to the forefront/front view
                $InformationTabControl.SelectedTab = $Section3ResultsTab

                Create-TreeViewCheckBoxArray -Endpoint
                if ($script:EntrySelected) {
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Enter a new name:")

                    $ComputerTreeNodeRenamePopup               = New-Object system.Windows.Forms.Form
                    $ComputerTreeNodeRenamePopup.Text          = "Rename $($script:EntrySelected.text)"
                    $ComputerTreeNodeRenamePopup.Size          = New-Object System.Drawing.Size(($FormScale * 330),($FormScale * 107))
                    $ComputerTreeNodeRenamePopup.StartPosition = "CenterScreen"
                    $ComputerTreeNodeRenamePopup.Font          = New-Object System.Drawing.Font("$Font",$($FormScale * 11),0,0,0)
                    $ComputerTreeNodeRenamePopup.Add_Closing   = { $This.dispose() }

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

                Remove-EmptyCategory -Endpoint
                Save-TreeViewData -Endpoint
            }
            if ($This.selectedItem -eq 'Move')  { 
                $InformationTabControl.SelectedTab = $Section3ResultsTab

                Create-TreeViewCheckBoxArray -Endpoint
                if ($script:EntrySelected) {
                    Show-MoveForm -Endpoint -Title "Move: $($script:EntrySelected.Text)" -SelectedEndpoint
            
                    $script:ComputerTreeView.Nodes.Clear()
                    Initialize-TreeViewData -Endpoint
            
                    $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                    $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
            
                    Foreach($Computer in $script:ComputerTreeViewData) {
                        AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip 'No ToolTip Data' -IPv4Address $Computer.IPv4Address  -Metadata $Computer
                    }
            
                    Remove-EmptyCategory -Endpoint
                    Save-TreeViewData -Endpoint
                    UpdateState-TreeViewData -Endpoint -NoMessage
            
                    $StatusListBox.Items.Clear()
                    $StatusListBox.Items.Add("Moved:  $($script:EntrySelected.text)")
                }
            }
            if ($This.selectedItem -eq 'Delete')  { 
                # This brings specific tabs to the forefront/front view
                $InformationTabControl.SelectedTab = $Section3ResultsTab

                Create-TreeViewCheckBoxArray -Endpoint
                if ($script:EntrySelected) {
                    $MessageBox = [System.Windows.MessageBox]::Show("Confirm Deletion of Endpoint Node: $($script:EntrySelected.text)`r`n`r`nAll Endpoint metadata and notes will be lost.`r`n`r`nAny previously collected data will still remain.",'Delete Endpoint','YesNo')

                    Switch ( $MessageBox ) {
                        'Yes' {
                            # Removes selected computer nodes
                            [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                            foreach ($root in $AllTreeViewNodes) {
                                foreach ($Category in $root.Nodes) {
                                    foreach ($Entry in $Category.nodes) {
                                        if ($Entry.text -eq $script:EntrySelected.text) {
                                            # Removes the node from the treeview
                                            $Entry.remove()
                                            # Removes the host from the variable storing the all the computers
                                            $script:ComputerTreeViewData = $script:ComputerTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                                        }
                                    }
                                }
                            }
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add("Deleted:  $($script:EntrySelected.text)")

                            $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                            $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'

                            #This is a bit of a workaround, but it prevents the host data message from appearing after a computer node is deleted...
                            $script:FirstCheck = $false

                            Remove-EmptyCategory -Endpoint
                            Save-TreeViewData -Endpoint
                        }
                        'No' {
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add('Endpoint Deletion Cancelled')
                        }
                    }
                }   
            }
        }
    }
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add('Tag')
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add('Add Endpoint')
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add('Rename')
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add('Move')
    $ComputerListSelectedNodeActionsToolStripComboBox.Items.Add('Delete')
    $ComputerListContextMenuStrip.Items.Add($ComputerListSelectedNodeActionsToolStripComboBox)


    $ComputerListContextMenuStrip.Items.Add('-')
    $ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = 'Checked Endpoints'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)


    $ComputerListContextMenuStrip.Items.Add('-')


    $ComputerListCheckedNodeActionsToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = "Checked Node Actions"
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListCheckedNodeActionsToolStripLabel)


    $ComputerListCheckedNodeActionsToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size = @{ Width  = $FormScale * 125 }
        Text = '   - Make a selection'
        ForeColor = 'DarkRed'
        ToolTipText = 'Import Endpoint Data from various sources. Duplicate names will not be imported.'
        Add_SelectedIndexChanged = {
            if ($This.selectedItem -eq 'Uncheck All') { 
                ### ... I didn't feel the need to error on unchecking... becuase it's not conducting any actions on the network
                #if ($script:ComputerTreeViewSelected.count -eq 0){
                #    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Uncheck All')
                #}
                #else {
                    Deselect-AllComputers
                #}
            }
            if ($This.selectedItem -eq 'NSLookup')  { 
                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','NSLookup')
                }
                else {
                    $InformationTabControl.SelectedTab = $Section3HostDataTab
            
                    $script:ProgressBarEndpointsProgressBar.Value     = 0
                    $script:ProgressBarQueriesProgressBar.Value       = 0
            
                    Create-TreeViewCheckBoxArray -Endpoint
                    if ($script:ComputerTreeViewSelected.count -ge 0) {
            
                        $MessageBox = [System.Windows.Forms.MessageBox]::Show("Conduct an NSLookup of $($script:ComputerTreeViewSelected.count) endpoints?","NSLookup",'YesNo','Info')
                        Switch ( $MessageBox ) {
                            'Yes' {
                                $MessageBoxAnswer = $true
                            }
                            'No' {
                                $MessageBoxAnswer = $false
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add('NSLookup Cancelled')
                            }
                        }
            
                        $script:ProgressBarEndpointsProgressBar.Maximum  = $script:ComputerTreeViewSelected.count
                        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            
                        if ($MessageBoxAnswer -eq $true) {
                            $ComputerListNSLookupArray = @()
                            foreach ($node in $script:ComputerTreeViewSelected) {
                                foreach ($root in $AllTreeViewNodes) {
                                    foreach ($Category in $root.Nodes) {
                                        foreach ($Entry in $Category.Nodes) {
                                            $LookupEndpoint = $null
            
                                            if ($Entry.Checked -and $Entry.Text -notin $ComputerListNSLookupArray) {
                                                $ComputerListNSLookupArray += $Entry.Text
                                                $script:Section3HostDataNameTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                                $Section3HostDataOSTextBox.Text   = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                                                $Section3HostDataOUTextBox.Text   = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
            
                                                $LookupEndpoint = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                                $NSlookup = $((Resolve-DnsName "$LookupEndpoint" | Sort-Object IPAddress | Select-Object -ExpandProperty IPAddress -Unique) -Join ', ')
                                                $Section3HostDataIPTextBox.Text   = $NSlookup
            
                                                $Section3HostDataMACTextBox.Text  = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                                                $Section3HostDataNotesRichTextBox.Text = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                                                Save-TreeViewData -Endpoint
            
                                            }
                                            $script:ProgressBarEndpointsProgressBar.Value += 1
                                        }
                                    }
                                }
                            }
                #               Save-TreeViewData -Endpoint -SaveAllChecked
                #               Check-HostDataIfModified
                            $StatusListBox.Items.clear()
                            $StatusListBox.Items.Add("NSLookup Complete: $($script:ComputerTreeViewSelected.count) Endpoints")
                        }
                    }
                }     
            }
            if ($This.selectedItem -eq 'Tag All')  { 
                Create-TreeViewCheckBoxArray -Endpoint
                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Tag All')
                }
                else {
                    $InformationTabControl.SelectedTab = $Section3HostDataTab
            
                    $script:ProgressBarEndpointsProgressBar.Value     = 0
                    $script:ProgressBarQueriesProgressBar.Value       = 0
            
                    Create-TreeViewCheckBoxArray -Endpoint
                    if ($script:ComputerTreeViewSelected.count -ge 0) {
                        Show-TagForm
            
                        $script:ProgressBarEndpointsProgressBar.Maximum  = $script:ComputerTreeViewSelected.count
                        [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
            
                        if ($script:ComputerListMassTagValue) {
                            $ComputerListMassTagArray = @()
                            foreach ($node in $script:ComputerTreeViewSelected) {
                                foreach ($root in $AllTreeViewNodes) {
                                    foreach ($Category in $root.Nodes) {
                                        foreach ($Entry in $Category.Nodes) {
                                            if ($Entry.Checked -and $Entry.Text -notin $ComputerListMassTagArray) {
                                                $ComputerListMassTagArray += $Entry.Text
                                                $script:Section3HostDataNameTextBox.Text      = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Name
                                                $Section3HostDataOSTextBox.Text        = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).OperatingSystem
                                                $Section3HostDataOUTextBox.Text        = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).CanonicalName
                                                $Section3HostDataIPTextBox.Text        = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).IPv4Address
                                                $Section3HostDataMACTextBox.Text       = $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).MACAddress
                                                $Section3HostDataNotesRichTextBox.Text = "[$($script:ComputerListMassTagValue)] " + $($script:ComputerTreeViewData | Where-Object {$_.Name -eq $Entry.Text}).Notes
                                            }
                                            $script:ProgressBarEndpointsProgressBar.Value += 1
                                        }
                                    }
                                }
                            }
                            Save-TreeViewData -Endpoint -SaveAllChecked
                            Check-HostDataIfModified
                            $StatusListBox.Items.clear()
                            $StatusListBox.Items.Add("Tag Complete: $($script:ComputerTreeViewSelected.count) Endpoints")
                        }
                    }
                }      
            }
            if ($This.selectedItem -eq 'Move All')  { 
                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Move All')
                }
                else {
                    $InformationTabControl.SelectedTab = $Section3ResultsTab
            
                    if ($script:ComputerTreeViewSelected.count -ge 0) {
                        Show-MoveForm -Endpoint -Title "Moving $($script:ComputerTreeViewSelected.count) Endpoints"
            
                        $script:ComputerTreeView.Nodes.Clear()
                        Initialize-TreeViewData -Endpoint
            
                        $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                        $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
            
                        Foreach($Computer in $script:ComputerTreeViewData) {
                            AddTreeNodeTo-TreeViewData -Endpoint -RootNode $script:TreeNodeComputerList -Category $Computer.CanonicalName -Entry $Computer.Name -ToolTip 'No ToolTip Data' -IPv4Address $Computer.IPv4Address  -Metadata $Computer
                        }
            
                        Remove-EmptyCategory -Endpoint
                        Save-TreeViewData -Endpoint
                        UpdateState-TreeViewData -Endpoint -NoMessage
            
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Moved $($script:ComputerTreeNodeToMove.Count) Endpoints")
                        $ResultsListBox.Items.Clear()
                        $ResultsListBox.Items.Add("The following hostnames/IPs have been moved to $($ComputerTreeNodePopupMoveComboBox.SelectedItem):")
                    }
                    else { ComputerNodeSelectedLessThanOne -Message 'Move Selection' }
                }      
            }
            if ($This.selectedItem -eq 'Delete All')  { 
                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Delete All')
                }
                else {
                    # This brings specific tabs to the forefront/front view
                    $InformationTabControl.SelectedTab = $Section3ResultsTab
            
                    if ($script:ComputerTreeViewSelected.count -eq 1) {
                        $MessageBox = [System.Windows.MessageBox]::Show("Confirm Deletion of $($script:ComputerTreeViewSelected.count) Endpoint Node.`r`n`r`nAll Endpoint metadata and notes will be lost.`r`nAny previously collected data will still remain.",'Delete Endpoint','YesNo')
                    }
                    elseif ($script:ComputerTreeViewSelected.count -gt 1) {
                        $MessageBox = [System.Windows.MessageBox]::Show("Confirm Deletion of $($script:ComputerTreeViewSelected.count) Endpoint Nodes.`r`n`r`nAll Endpoint metadata and notes will be lost.`r`nAny previously collected data will still remain.",'Delete Endpoints','YesNo')
                    }
            
                    Switch ( $MessageBox ) {
                        'Yes' {
                            if ($script:ComputerTreeViewSelected.count -gt 0) {
                                foreach ($i in $script:ComputerTreeViewSelected) {
                                    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $script:ComputerTreeView.Nodes
                                    foreach ($root in $AllTreeViewNodes) {
                                        foreach ($Category in $root.Nodes) {
                                            foreach ($Entry in $Category.nodes) {
                                                if ($Entry.checked) {
                                                    $Entry.remove()
                                                    # Removes the host from the variable storing the all the computers
                                                    $script:ComputerTreeViewData = $script:ComputerTreeViewData | Where-Object {$_.Name -ne $Entry.text}
                                                }
                                            }
                                        }
                                    }
                                }
                                # Removes selected category nodes - Note: had to put this in its own loop...
                                # the saving of nodes didn't want to work properly when use in the above loop when switching between treenode views.
                                foreach ($i in $script:ComputerTreeViewSelected) {
                                    foreach ($root in $AllTreeViewNodes) {
                                        foreach ($Category in $root.Nodes) {
                                            if ($Category.checked) { $Category.remove() }
                                        }
                                    }
                                }
                                # Removes selected root node - Note: had to put this in its own loop... see above category note
                                foreach ($i in $script:ComputerTreeViewSelected) {
                                    foreach ($root in $AllTreeViewNodes) {
                                        if ($root.checked) {
                                            foreach ($Category in $root.Nodes) { $Category.remove() }
                                            $root.remove()
                                            if ($i -eq "All Endpoints") { $script:ComputerTreeView.Nodes.Add($script:TreeNodeComputerList) }
                                        }
                                    }
                                }
            
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Deleted:  $($script:ComputerTreeViewSelected.Count) Selected Items")
                                #Removed For Testing#$ResultsListBox.Items.Clear()
                                $ResultsListBox.Items.Add("The following hosts have been deleted:  ")
                                $ComputerListDeletedArray = @()
                                foreach ($Node in $script:ComputerTreeViewSelected) {
                                    if ($Node -notin $ComputerListDeletedArray) {
                                        $ComputerListDeletedArray += $Node
                                        $ResultsListBox.Items.Add(" - $Node")
                                    }
                                }
            
                                $ComputerAndAccountTreeViewTabControl.SelectedTab = $ComputerTreeviewTab
                                $script:ComputerTreeNodeComboBox.SelectedItem = 'CanonicalName'
                
                                Remove-EmptyCategory -Endpoint
                                Save-TreeViewData -Endpoint
                            }
                            else { ComputerNodeSelectedLessThanOne -Message 'Delete Selection' }
                        }
                        'No' {
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add('Endpoint Deletion Cancelled')
                        }
                    }
                }      
            }
        }
    }
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add('Uncheck All')
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add('NSLookup')
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add('Tag All')
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add('Move All')
    $ComputerListCheckedNodeActionsToolStripComboBox.Items.Add('Delete All')
    $ComputerListContextMenuStrip.Items.Add($ComputerListCheckedNodeActionsToolStripComboBox)


    $ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = 'Test Connection'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Black'
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)

    $ComputerListTestConnectionToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size = @{ Width  = $FormScale * 125 }
        Text = '   - Make a selection'
        ForeColor = "DarkRed"
        Add_SelectedIndexChanged = {
            if ($This.selectedItem -eq 'ICMP Ping') { 
                Create-TreeViewCheckBoxArray -Endpoint

                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Ping')
                }
                else {
                    if (Verify-Action -Title "Verification: Ping Test" -Question "Conduct a Ping test to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "Ping" -MessageTrue "Able to Ping" -MessageFalse "Unable to Ping"
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Ping:  Cancelled")
                    }
                }            
            }
            if ($This.selectedItem -eq 'RPC Port Check')  { 
                Create-TreeViewCheckBoxArray -Endpoint

                if ($ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
                else {$Username = $PoShEasyWinAccountLaunch }
            
                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','RPC Port Check')
                }
                else {
                    if (Verify-Action -Title "Verification: RPC Port Check" -Question "Connecting Account:  $Username`n`nConduct a RPC Port Check to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "RPC Port Check" -MessageTrue "RPC Port 135 is Open" -MessageFalse "RPC Port 135 is Closed"
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("RPC Port Check:  Cancelled")
                    }
                }
            }
            if ($This.selectedItem -eq 'SMB Port Check')  { 
                Create-TreeViewCheckBoxArray -Endpoint

                if ($ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
                else {$Username = $PoShEasyWinAccountLaunch }
            
                if ($script:ComputerTreeViewSelected.count -eq 0){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','SMB Port Check')
                }
                else {
                    if (Verify-Action -Title "Verification: SMB Port Check" -Question "Connecting Account:  $Username`n`nConduct a SMB Port Check to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "SMB Port Check" -MessageTrue "SMB Port 445 is Open" -MessageFalse "SMB Port 445 is Closed"
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("SMB Port Check:  Cancelled")
                    }
                }
            }
            if ($This.selectedItem -eq 'WinRM Check')  { 
                Create-TreeViewCheckBoxArray -Endpoint

                if ($ComputerListProvideCredentialsCheckBox.Checked) { $Username = $script:Credential.UserName}
                else {$Username = $PoShEasyWinAccountLaunch }
            
                if ($script:ComputerTreeViewSelected.count -lt 1){
                    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','WinRM Check')
                }
                else {
                    if (Verify-Action -Title "Verification: WinRM Check" -Question "Connecting Account:  $Username`n`nConduct a WinRM Check to the following?" -Computer $($script:ComputerTreeViewSelected -join ', ')) {
                        Check-Connection -CheckType "WinRM Check" -MessageTrue "Able to Verify WinRM" -MessageFalse "Unable to Verify WinRM"
                    }
                    else {
                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("WinRM Check:  Cancelled")
                    }
                }
            }
        }
    }
    $ComputerListTestConnectionToolStripComboBox.Items.Add('ICMP Ping')
    $ComputerListTestConnectionToolStripComboBox.Items.Add('RPC Port Check')
    $ComputerListTestConnectionToolStripComboBox.Items.Add('SMB Port Check')
    $ComputerListTestConnectionToolStripComboBox.Items.Add('WinRM Check')
    $ComputerListContextMenuStrip.Items.Add($ComputerListTestConnectionToolStripComboBox)


    $ComputerListContextMenuStrip.Items.Add('-')


    $ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
        Text      = 'View Endpoint Data'
        Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
        ForeColor = 'Blue'
    }
    $ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)


    $ComputerListContextMenuStrip.Items.Add('-')

    $ComputerListViewEndpointDataToolStripComboBox = New-Object System.Windows.Forms.ToolStripComboBox -Property @{
        Size = @{ Width  = $FormScale * 125 }
        Text = '   - Make a selection'
        ForeColor = 'DarkRed'
        ToolTipText = 'Import Endpoint Data from various sources. Duplicate names will not be imported.'
        Add_SelectedIndexChanged = {
            if ($This.selectedItem -eq 'Out-GridView') { 
                Import-Csv -Path $script:EndpointTreeNodeFileSave | Out-GridView -Title 'Endpoint Data'
            }
            if ($This.selectedItem -eq 'Spreadsheet')  { 
                Invoke-Item -Path $script:EndpointTreeNodeFileSave
            }
            if ($This.selectedItem -eq 'Browser HTML View')  { 
                Import-Csv -Path $script:EndpointTreeNodeFileSave | Out-HTMLView -Title 'Endpoint Data'
            }
        }
    }
    $ComputerListViewEndpointDataToolStripComboBox.Items.Add('Out-GridView')
    $ComputerListViewEndpointDataToolStripComboBox.Items.Add('Spreadsheet')
    $ComputerListViewEndpointDataToolStripComboBox.Items.Add('Browser HTML View')
    $ComputerListContextMenuStrip.Items.Add($ComputerListViewEndpointDataToolStripComboBox)

    $ComputerListContextMenuStrip.Items.Add('-')
    

    $Entry.ContextMenuStrip = $ComputerListContextMenuStrip
}


