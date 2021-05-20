#--------------------------------------------------------------------------------------
# Context Menu Strip for when clicking within the treeview but not on an endpoint node
#--------------------------------------------------------------------------------------
#Display-ContextMenuForComputerTreeView

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


$ComputerListAddEndpointToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Add Endpoint"
    Add_CLick = {
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
    Add_CLick = {
        ### ... I didn't feel the need to error on unchecking... becuase it's not conducting any actions on the network
        #if ($script:ComputerTreeViewSelected.count -eq 0){
        #    [System.Windows.MessageBox]::Show('Error: You need to check at least one endpoint.','Uncheck All')
        #}
        #else {
            Deselect-AllComputers
        #}
    }
}
$ComputerListContextMenuStrip.Items.Add($ComputerListDeselectAllToolStripButton)


$ComputerListNSLookupCheckedToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "NSLookup"
    Add_CLick = {
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
}
$ComputerListContextMenuStrip.Items.Add($ComputerListNSLookupCheckedToolStripButton)


$ComputerListMassTagToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Tag All"
    Add_CLick = {
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
}
$ComputerListContextMenuStrip.Items.Add($ComputerListMassTagToolStripButton)


$ComputerListMoveToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Move All"
    Add_CLick = {
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
}
$ComputerListContextMenuStrip.Items.Add($ComputerListMoveToolStripButton)


$ComputerListDeleteToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Delete All"
    Add_CLick = {
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
    Add_CLick = {
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
}
$ComputerListContextMenuStrip.Items.Add($ComputerListPingToolStripButton)


$ComputerListRPCCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "   - RPC Port Check"
    ForeColor = 'DarkRed'
    Add_CLick = {
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
}
$ComputerListContextMenuStrip.Items.Add($ComputerListRPCCheckToolStripButton)


$ComputerListSMBCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "   - SMB Port Check"
    ForeColor = 'DarkRed'
    Add_CLick = {
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
}
$ComputerListContextMenuStrip.Items.Add($ComputerListSMBCheckToolStripButton)


$ComputerListWinRMCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "   - WinRM Check"
    ForeColor = 'DarkRed'
    Add_CLick = {
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
$ComputerListContextMenuStrip.Items.Add($ComputerListWinRMCheckToolStripButton)

$ComputerListContextMenuStrip.Items.Add('-')
$ComputerListRenameToolStripLabel = New-Object System.Windows.Forms.ToolStripLabel -Property @{
    Text      = 'View Endpoint Data'
    Font      = New-Object System.Drawing.Font("$Font",$($FormScale * 11),1,2,1)
    ForeColor = 'Blue'
}
$ComputerListContextMenuStrip.Items.Add($ComputerListRenameToolStripLabel)
$ComputerListContextMenuStrip.Items.Add('-')


$ComputerListOpenGridViewCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Out-GridView"
    Add_CLick = {
        Import-Csv -Path $script:EndpointTreeNodeFileSave | Out-GridView -Title 'Endpoint Data'
    }
}
$ComputerListContextMenuStrip.Items.Add($ComputerListOpenGridViewCheckToolStripButton)

$ComputerListOpenSpreadsheetCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Spreadsheet"
    Add_CLick = {
        Invoke-Item -Path $script:EndpointTreeNodeFileSave
    }
}
$ComputerListContextMenuStrip.Items.Add($ComputerListOpenSpreadsheetCheckToolStripButton)


$ComputerListOpenHtmlViewCheckToolStripButton = New-Object System.Windows.Forms.ToolStripButton -Property @{
    Text      = "Browser HTML View"
    Add_CLick = {
        Import-Csv -Path $script:EndpointTreeNodeFileSave | Out-HTMLView -Title 'Endpoint Data'
    }
}
$ComputerListContextMenuStrip.Items.Add($ComputerListOpenHtmlViewCheckToolStripButton)

