$ComputerTreeViewAdd_Click = {
    Update-TreeViewData -Endpoint -TreeView $this.Nodes

    # When the node is checked, it updates various items
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $this.Nodes
    foreach ($root in $AllTreeViewNodes) {
        if ($root.checked) {
            $root.Expand()
            foreach ($Category in $root.Nodes) {
                $Category.Expand()
                foreach ($Entry in $Category.nodes) {
                    $Entry.Checked      = $True
                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }
            }
        }
        foreach ($Category in $root.Nodes) {
            $EntryNodeCheckedCount = 0
            if ($Category.checked) {
                $Category.Expand()
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                foreach ($Entry in $Category.nodes) {
                    $EntryNodeCheckedCount  += 1
                    $Entry.Checked      = $True
                    $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }
            }
            if (!($Category.checked)) {
                foreach ($Entry in $Category.nodes) {
                    #if ($Entry.isselected) {
                    if ($Entry.checked) {
                        $EntryNodeCheckedCount  += 1
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                        $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    }
                    elseif (!($Entry.checked)) {
                        if ($CategoryCheck -eq $False) {$Category.Checked = $False}
                        $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                        $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                    }
                }
            }
            if ($EntryNodeCheckedCount -gt 0) {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }
}

$ComputerTreeViewAdd_AfterSelect = {
    Update-TreeViewData -Endpoint -TreeView $this.Nodes

    # This will return data on hosts selected/highlight, but not necessarily checked
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $this.Nodes
    foreach ($root in $AllTreeViewNodes) {
        if ($root.isselected) {
            $script:ComputerTreeViewSelected = ""
            $StatusListBox.Items.clear()
            $StatusListBox.Items.Add("Category:  $($root.Text)")
            #Removed For Testing#$ResultsListBox.Items.Clear()
            #$ResultsListBox.Items.Add("- Checkbox this Category to query all its hosts")

            $script:Section3HostDataNameTextBox.Text                     = 'N/A'
            $Section3HostDataOUTextBox.Text                              = 'N/A'
            $Section3EndpointDataCreatedTextBox.Text                     = 'N/A'
            $Section3EndpointDataModifiedTextBox.Text                    = 'N/A'
            $Section3EndpointDataLastLogonDateTextBox.Text               = 'N/A'
            $Section3HostDataIPTextBox.Text                              = 'N/A'
            $Section3HostDataMACTextBox.Text                             = 'N/A'
            $Section3EndpointDataEnabledTextBox.Text                     = 'N/A'
            $Section3EndpointDataisCriticalSystemObjectTextBox.Text      = 'N/A'
            $Section3EndpointDataSIDTextBox.Text                         = 'N/A'
            $Section3EndpointDataOperatingSystemTextBox.Text             = 'N/A'
            $Section3EndpointDataOperatingSystemHotfixComboBox.Text      = 'N/A'
            $Section3EndpointDataOperatingSystemServicePackComboBox.Text = 'N/A'
            $Section3EndpointDataMemberOfComboBox.Text                   = 'N/A'
            $Section3EndpointDataLockedOutTextBox.Text                   = 'N/A'
            $Section3EndpointDataLogonCountTextBox.Text                  = 'N/A'
            $Section3EndpointDataPortScanComboBox.Text                   = 'N/A'
            $Section3HostDataSelectionComboBox.Text                      = 'N/A'
            $Section3HostDataSelectionDateTimeComboBox.Text              = 'N/A'
            $Section3HostDataNotesRichTextBox.Text                       = 'N/A'

            # Brings the Host Data Tab to the forefront/front view
            $InformationTabControl.SelectedTab   = $Section3HostDataTab
        }
        foreach ($Category in $root.Nodes) {
            if ($Category.isselected) {
                $script:ComputerTreeViewSelected = ""
                $StatusListBox.Items.clear()
                $StatusListBox.Items.Add("Category:  $($Category.Text)")
                #Removed For Testing#$ResultsListBox.Items.Clear()
                #$ResultsListBox.Items.Add("- Checkbox this Category to query all its hosts")

                # The follwing fields are filled out with N/A when host nodes are not selected
                $script:Section3HostDataNameTextBox.Text                     = 'N/A'
                $Section3HostDataOUTextBox.Text                              = 'N/A'
                $Section3EndpointDataCreatedTextBox.Text                     = 'N/A'
                $Section3EndpointDataModifiedTextBox.Text                    = 'N/A'
                $Section3EndpointDataLastLogonDateTextBox.Text               = 'N/A'
                $Section3HostDataIPTextBox.Text                              = 'N/A'
                $Section3HostDataMACTextBox.Text                             = 'N/A'
                $Section3EndpointDataEnabledTextBox.Text                     = 'N/A'
                $Section3EndpointDataisCriticalSystemObjectTextBox.Text      = 'N/A'
                $Section3EndpointDataSIDTextBox.Text                         = 'N/A'
                $Section3EndpointDataOperatingSystemTextBox.Text             = 'N/A'
                $Section3EndpointDataOperatingSystemHotfixComboBox.Text      = 'N/A'
                $Section3EndpointDataOperatingSystemServicePackComboBox.Text = 'N/A'
                $Section3EndpointDataMemberOfComboBox.Text                   = 'N/A'
                $Section3EndpointDataLockedOutTextBox.Text                   = 'N/A'
                $Section3EndpointDataLogonCountTextBox.Text                  = 'N/A'
                $Section3EndpointDataPortScanComboBox.Text                   = 'N/A'
                $Section3HostDataSelectionComboBox.Text                      = 'N/A'
                $Section3HostDataSelectionDateTimeComboBox.Text              = 'N/A'
                $Section3HostDataNotesRichTextBox.Text                       = 'N/A'

                # Brings the Host Data Tab to the forefront/front view
                $InformationTabControl.SelectedTab = $Section3HostDataTab
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.isselected) {
                    $InformationTabControl.SelectedTab = $Section3HostDataTab
                    $script:ComputerTreeViewSelected = $Entry.Text
                }
            }
        }
    }
    $InformationTabControl.SelectedTab = $Section3HostDataTab
    Display-ContextMenuForComputerTreeNode -ClickedOnArea
}


