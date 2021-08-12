$AccountsTreeViewAdd_Click = {
    Update-TreeViewData -Accounts -TreeView $this.Nodes

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

$AccountsTreeViewAdd_AfterSelect = {
    Update-TreeViewData -Accounts -TreeView $this.Nodes

    # This will return data on hosts selected/highlight, but not necessarily checked
    [System.Windows.Forms.TreeNodeCollection]$AllTreeViewNodes = $this.Nodes
    foreach ($root in $AllTreeViewNodes) {
        if ($root.isselected) {
            $script:ComputerTreeViewSelected = ""
            $StatusListBox.Items.clear()
            $StatusListBox.Items.Add("Category:  $($root.Text)")
            #Removed For Testing#$ResultsListBox.Items.Clear()
            #$ResultsListBox.Items.Add("- Checkbox this Category to query all its hosts")

            $script:Section3AccountDataNameTextBox.Text             = 'N/A'
            $Section3AccountDataEnabledTextBox.Text                 = 'N/A'
            $Section3AccountDataOUTextBox.Text                      = 'N/A'
            $Section3AccountDataLockedOutTextBox.Text               = 'N/A'
            $Section3AccountDataSmartCardLogonRequiredTextBox.Text  = 'N/A'
            $Section3AccountDataCreatedTextBox.Text                 = 'N/A'
            $Section3AccountDataModifiedTextBox.Text                = 'N/A'
            $Section3AccountDataLastLogonDateTextBox.Text           = 'N/A'
            $Section3AccountDataLastBadPasswordAttemptTextBox.Text  = 'N/A'
            $Section3AccountDataBadLogonCountTextBox.Text           = 'N/A'
            $Section3AccountDataPasswordExpiredTextBox.Text         = 'N/A'
            $Section3AccountDataPasswordNeverExpiresTextBox.Text    = 'N/A'
            $Section3AccountDataPasswordNotRequiredTextBox.Text     = 'N/A'
            $Section3AccountDataMemberOfComboBox.Text               = 'N/A'
            $Section3AccountDataSIDTextBox.Text                     = 'N/A'
            $Section3AccountDataScriptPathTextBox.Text              = 'N/A'
            $Section3AccountDataHomeDriveTextBox.Text               = 'N/A'
            $script:Section3AccountDataNotesRichTextBox.Text        = 'N/A'

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
                $script:Section3AccountDataNameTextBox.Text             = 'N/A'
                $Section3AccountDataEnabledTextBox.Text                 = 'N/A'
                $Section3AccountDataOUTextBox.Text                      = 'N/A'
                $Section3AccountDataLockedOutTextBox.Text               = 'N/A'
                $Section3AccountDataSmartCardLogonRequiredTextBox.Text  = 'N/A'
                $Section3AccountDataCreatedTextBox.Text                 = 'N/A'
                $Section3AccountDataModifiedTextBox.Text                = 'N/A'
                $Section3AccountDataLastLogonDateTextBox.Text           = 'N/A'
                $Section3AccountDataLastBadPasswordAttemptTextBox.Text  = 'N/A'
                $Section3AccountDataBadLogonCountTextBox.Text           = 'N/A'
                $Section3AccountDataPasswordExpiredTextBox.Text         = 'N/A'
                $Section3AccountDataPasswordNeverExpiresTextBox.Text    = 'N/A'
                $Section3AccountDataPasswordNotRequiredTextBox.Text     = 'N/A'
                $Section3AccountDataMemberOfComboBox.Text               = 'N/A'
                $Section3AccountDataSIDTextBox.Text                     = 'N/A'
                $Section3AccountDataScriptPathTextBox.Text              = 'N/A'
                $Section3AccountDataHomeDriveTextBox.Text               = 'N/A'
                $script:Section3AccountDataNotesRichTextBox.Text        = 'N/A'
            }
            foreach ($Entry in $Category.nodes) {
                if ($Entry.isselected) {
                    $script:ComputerTreeViewSelected = $Entry.Text
                }
            }
        }
    }
    $InformationTabControl.SelectedTab = $Section3AccountDataTab
    Display-ContextMenuForAccountsTreeNode -ClickedOnArea
}


