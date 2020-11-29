function Conduct-NodeAction {
    param(
        $TreeView,
        [switch]$Commands,
        [switch]$ComputerList
    )
    if ($Commands)     { $script:TreeeViewCommandsCount = 0 }
    if ($ComputerList) { $script:TreeeViewComputerListCount = 0 }

    $EntryQueryHistoryChecked = 0

    # Resets the SMB and RPC command count each time
    if ($Commands) {
        $script:RpcCommandCount   = 0
        $script:SmbCommandCount   = 0
        $script:WinRMCommandCount = 0
    }

    # This will return data on hosts selected/highlight, but not necessarily checked
    [System.Windows.Forms.TreeNodeCollection]$AllNodes = $TreeView
    foreach ($root in $AllNodes) {
        $EntryNodeCheckedCountforRoot = 0

        #if ($Commands)     { if ($root.Text -match 'Search Results') { $EnsureViisible = $root } }
        #if ($ComputerList) { if ($root.Text -match 'All Endpoints')  { $EnsureViisible = $root } }

        if ($root.Checked) {
            $Root.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
            $Root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
            #$Root.Expand()
            foreach ($Category in $root.Nodes) {
                #$Category.Expand()
                $Category.checked = $true
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                foreach ($Entry in $Category.nodes) {
                    if ($Commands)     { $script:TreeeViewCommandsCount += 1 }
                    if ($ComputerList) { $script:TreeeViewComputerListCount += 1 }
                    $Entry.Checked   = $True
                    $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }
            }
        }
        if ($root.isselected) {
            $script:rootSelected      = $root
            $script:CategorySelected  = $null
            $script:EntrySelected     = $null

            Display-ContextMenuForComputerTreeNode

            $script:HostQueryTreeViewSelected              = ""
            $Section3QueryExplorationName.Text             = "N/A"
            $Section3QueryExplorationTypeTextBox.Text      = "N/A"
            $Section3QueryExplorationWinRMPoShTextBox.Text = "N/A"
            $Section3QueryExplorationWinRMWMITextBox.Text  = "N/A"
            $Section3QueryExplorationRPCPoShTextBox.Text   = "N/A"
            $Section3QueryExplorationRPCWMITextBox.Text    = "N/A"
        }

        foreach ($Category in $root.Nodes) {
            $EntryNodeCheckedCountforCategory = 0

            if ($Category.Checked) {
            #    $Category.Expand()
                if ($Category.Text -match '[\[(]WinRM[)\]]' ) {
                    $script:WinRMCommandCount += 10
                }
                if ($Category.Text -match '[\[(]rpc[)\]]' ) {
                    $script:RpcCommandCount += 1
                    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                        # This brings specific tabs to the forefront/front view
                        $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
                        $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                        #Removed For Testing#$ResultsListBox.Items.Clear()
                        $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                        $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                        $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Monitor Jobs'
                        $EventLogRPCRadioButton.checked         = $true
                        $ExternalProgramsRPCRadioButton.checked = $true
                    }
                }
                if ($Category.Text -match '[\[(]smb[)\]]' ) {
                    $script:SmbCommandCount += 1
                    if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                        # This brings specific tabs to the forefront/front view
                        $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
                        $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                        #Removed For Testing#$ResultsListBox.Items.Clear()
                        $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                        $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                        $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Monitor Jobs'
                    }
                }

                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)

                foreach ($Entry in $Category.nodes) {
                    if ($Commands)     { $script:TreeeViewCommandsCount += 1 }
                    if ($ComputerList) { $script:TreeeViewComputerListCount += 1 }

                    if ($Entry.Text -match '[\[(]WinRM[)\]]' ) {
                        $script:WinRMCommandCount += 1
                    }
                    if ($Entry.Text -match '[\[(]rpc[)\]]') {
                        $script:RpcCommandCount += 1
                        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                            # This brings specific tabs to the forefront/front view
                            $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
                            $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                            [system.media.systemsounds]::Exclamation.play()
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                            #Removed For Testing#$ResultsListBox.Items.Clear()
                            $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                            $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                            $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Monitor Jobs'
                            $EventLogRPCRadioButton.checked         = $true
                            $ExternalProgramsRPCRadioButton.checked = $true
                        }
                    }
                    if ($Entry.Text -match '[\[(]smb[)\]]') {
                        $script:SmbCommandCount += 1
                        if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                            # This brings specific tabs to the forefront/front view
                            $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
                            $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                            [system.media.systemsounds]::Exclamation.play()
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                            #Removed For Testing#$ResultsListBox.Items.Clear()
                            $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                            $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                            $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Monitor Jobs'
                        }
                    }

                    $EntryNodeCheckedCountforCategory += 1
                    $EntryNodeCheckedCountforRoot     += 1
                    $Entry.Checked   = $True
                    $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                    $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }
                if ($root.text -match 'Query History') {
                    $EntryQueryHistoryChecked++
                    $Section1CommandsTab.Controls.Add($CommandsTreeViewQueryHistoryRemovalButton)
                    $CommandsTreeViewQueryHistoryRemovalButton.bringtofront()
                }
            }
            elseif (!($Category.checked)) {
                foreach ($Entry in $Category.nodes) {
                    if ($Entry.checked) {
                        # Currently used to support cmdkey /delete:$script:EntryChecked to clear out credentials when using Remote Desktop
                        $script:EntryChecked = $entry.text

                        if ($Entry.Text -match '[\[(]WinRM[)\]]' ) {
                            $script:WinRMCommandCount += 1
                        }
                        if ($Entry.Text -match '[\[(]rpc[)\]]') {
                            $script:RpcCommandCount += 1
                            if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                                # This brings specific tabs to the forefront/front view
                                $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
                                $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                                [system.media.systemsounds]::Exclamation.play()
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                                #Removed For Testing#$ResultsListBox.Items.Clear()
                                $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                                $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                                $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Monitor Jobs'
                                $EventLogRPCRadioButton.checked         = $true
                                $ExternalProgramsRPCRadioButton.checked = $true
                            }
                        }
                        if ($Entry.Text -match '[\[(]smb[)\]]') {
                            $script:SmbCommandCount += 1
                            if ($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                                # This brings specific tabs to the forefront/front view
                                $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
                                $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                                [system.media.systemsounds]::Exclamation.play()
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                                #Removed For Testing#$ResultsListBox.Items.Clear()
                                $ResultsListBox.Items.Add("The collection mode '$($script:CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC and SMB protocols and has been changed to")
                                $ResultsListBox.Items.Add("'Monitor Jobs' which supports RPC, SMB, and WinRM - but may be slower and noisier on the network.")
                                $script:CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Monitor Jobs'
                            }
                        }


                        if ($Commands) { $script:TreeeViewCommandsCount += 1 }
                        if ($ComputerList) { $script:TreeeViewComputerListCount += 1 }
                        $EntryNodeCheckedCountforCategory += 1
                        $EntryNodeCheckedCountforRoot     += 1
                        $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                        $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    }
                    elseif (!($Entry.checked)) {
                        if ($CategoryCheck -eq $False) {$Category.Checked = $False}
                        $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                        $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                    }
                }
                if ($EntryQueryHistoryChecked -eq 0) {
                    $Section1CommandsTab.Controls.Remove($CommandsTreeViewQueryHistoryRemovalButton)
                }
            }
            if ($Category.isselected) {
                $script:rootSelected      = $null
                $script:CategorySelected  = $Category
                $script:EntrySelected     = $null

                Display-ContextMenuForComputerTreeNode

                $script:HostQueryTreeViewSelected = ""
                #$StatusListBox.Items.clear()
                #$StatusListBox.Items.Add("Category:  $($Category.Text)")
                ##Removed For Testing#$ResultsListBox.Items.Clear()
                #$ResultsListBox.Items.Add("- Checkbox This Node to Execute All Commands Within")

                $Section3QueryExplorationName.Text             = "N/A"
                $Section3QueryExplorationTypeTextBox.Text      = "N/A"
                $Section3QueryExplorationWinRMPoShTextBox.Text = "N/A"
                $Section3QueryExplorationWinRMWMITextBox.Text  = "N/A"
                $Section3QueryExplorationRPCPoShTextBox.Text   = "N/A"
                $Section3QueryExplorationRPCWMITextBox.Text    = "N/A"

                #$MainBottomTabControl.SelectedTab   = $Section3ResultsTab
            }

            foreach ($Entry in $Category.nodes) {
                $EntryNodesWithinCategory += 1

                if ($Entry.isselected) {
                    $script:rootSelected      = $null
                    $script:CategorySelected  = $Category
                    $script:EntrySelected     = $Entry

                    Display-ContextMenuForComputerTreeNode

                    $script:HostQueryTreeViewSelected = $Entry.Text

                    if ($root.text -match 'Endpoint Commands') {
                        $Section3QueryExplorationNameTextBox.Text            = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Name
                        $Section3QueryExplorationTagWordsTextBox.Text        = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Type
                        $Section3QueryExplorationWinRMPoShTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_PoSh
                        $Section3QueryExplorationWinRMWMITextBox.Text        = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_WMI
                        $Section3QueryExplorationWinRMCmdTextBox.Text        = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_SMB_CMD
                        $Section3QueryExplorationRPCPoShTextBox.Text         = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_PoSh
                        $Section3QueryExplorationRPCWMITextBox.Text          = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_WMI
                        $Section3QueryExplorationPropertiesPoshTextBox.Text  = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_PoSh
                        $Section3QueryExplorationPropertiesWMITextBox.Text   = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_WMI
                        $Section3QueryExplorationWinRSWmicTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_WMIC
                        $Section3QueryExplorationWinRSCmdTextBox.Text        = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_CMD
                        $Section3QueryExplorationDescriptionRichTextbox.Text = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Description
                    }
                    elseif ($root.text -match 'Active Directory Commands') {
                        $Section3QueryExplorationNameTextBox.Text            = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Name
                        $Section3QueryExplorationTagWordsTextBox.Text        = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Type
                        $Section3QueryExplorationWinRMPoShTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_PoSh
                        $Section3QueryExplorationWinRMWMITextBox.Text        = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_WMI
                        $Section3QueryExplorationWinRMCmdTextBox.Text        = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_SMB_CMD
                        $Section3QueryExplorationRPCPoShTextBox.Text         = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_PoSh
                        $Section3QueryExplorationRPCWMITextBox.Text          = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_WMI
                        $Section3QueryExplorationPropertiesPoshTextBox.Text  = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_PoSh
                        $Section3QueryExplorationPropertiesWMITextBox.Text   = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_WMI
                        $Section3QueryExplorationWinRSWmicTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_WMIC
                        $Section3QueryExplorationWinRSCmdTextBox.Text        = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_CMD
                        $Section3QueryExplorationDescriptionRichTextbox.Text = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Description
                    }
                    elseif ($root.text -match 'Search Results'){
                        if ($($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Name) {
                            $Section3QueryExplorationNameTextBox.Text            = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Name
                            $Section3QueryExplorationTagWordsTextBox.Text        = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Type
                            $Section3QueryExplorationWinRMPoShTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_PoSh
                            $Section3QueryExplorationWinRMWMITextBox.Text        = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_WMI
                            $Section3QueryExplorationWinRMCmdTextBox.Text        = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_SMB_CMD
                            $Section3QueryExplorationRPCPoShTextBox.Text         = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_PoSh
                            $Section3QueryExplorationRPCWMITextBox.Text          = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_WMI
                            $Section3QueryExplorationPropertiesPoshTextBox.Text  = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_PoSh
                            $Section3QueryExplorationPropertiesWMITextBox.Text   = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_WMI
                            $Section3QueryExplorationWinRSWmicTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_WMIC
                            $Section3QueryExplorationWinRSCmdTextBox.Text        = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_CMD
                            $Section3QueryExplorationDescriptionRichTextbox.Text = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Description
                        }
                        else {
                            $Section3QueryExplorationNameTextBox.Text            = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Name
                            $Section3QueryExplorationTagWordsTextBox.Text        = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Type
                            $Section3QueryExplorationWinRMPoShTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_PoSh
                            $Section3QueryExplorationWinRMWMITextBox.Text        = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_WMI
                            $Section3QueryExplorationWinRMCmdTextBox.Text        = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_SMB_CMD
                            $Section3QueryExplorationRPCPoShTextBox.Text         = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_PoSh
                            $Section3QueryExplorationRPCWMITextBox.Text          = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_WMI
                            $Section3QueryExplorationPropertiesPoshTextBox.Text  = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_PoSh
                            $Section3QueryExplorationPropertiesWMITextBox.Text   = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_WMI
                            $Section3QueryExplorationWinRSWmicTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_WMIC
                            $Section3QueryExplorationWinRSCmdTextBox.Text        = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_CMD
                            $Section3QueryExplorationDescriptionRichTextbox.Text = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Description
                        }
                    }

                    if ($Category.text -match 'PowerShell Scripts'){
                        # Replaces the edit checkbox and save button with View Script button
                        $Section3QueryExplorationTabPage.Controls.Remove($Section3QueryExplorationEditCheckBox)
                        $Section3QueryExplorationTabPage.Controls.Remove($Section3QueryExplorationSaveButton)
                        $Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationViewScriptButton)
                    }
                    else {
                        # Replaces the View Script button with the edit checkbox and save button
                        $Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationEditCheckBox)
                        $Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationSaveButton)
                        $Section3QueryExplorationTabPage.Controls.Remove($Section3QueryExplorationViewScriptButton)
                    }
                    if ($TreeView -match 'Command') { $MainBottomTabControl.SelectedTab   = $Section3QueryExplorationTabPage }

                    foreach ($Entry in $Category.nodes) {
                        if ($entry.checked) {
                            if ($Commands)     { $script:TreeeViewCommandsCount += 1 }
                            if ($ComputerList) { $script:TreeeViewComputerListCount += 1 }
                            $EntryNodeCheckedCountforCategory += 1
                            $EntryNodeCheckedCountforRoot     += 1
                            $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        }
                        if (!($entry.checked)) {
                            $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                            $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                        }
                    }
                }
            }
            if ($EntryNodeCheckedCountforCategory -gt 0) {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
            if ($EntryNodeCheckedCountforRoot -gt 0) {
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",$($FormScale * 10),1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }
    #$EnsureViisible.EnsureVisible()

    # Note: If adding new checkboxes to other areas, make sure also add it to the script handler
    if ($Commands) {
        if ($CustomQueryScriptBlockCheckBox.checked)                    { $script:TreeeViewCommandsCount++ }
        if ($RegistrySearchCheckbox.checked)                            { $script:TreeeViewCommandsCount++ }
        if ($AccountsCurrentlyLoggedInConsoleCheckbox.checked)          { $script:TreeeViewCommandsCount++ }
        if ($AccountsCurrentlyLoggedInPSSessionCheckbox.checked)        { $script:TreeeViewCommandsCount++ }
        if ($AccountActivityCheckbox.checked)                           { $script:TreeeViewCommandsCount++ }
        if ($EventLogsEventIDsManualEntryCheckbox.Checked)              { $script:TreeeViewCommandsCount++ }
        if ($EventLogsEventIDsToMonitorCheckbox.Checked)                { $script:TreeeViewCommandsCount++ }
        if ($EventLogsQuickPickSelectionCheckbox.Checked)               { $script:TreeeViewCommandsCount++ }
        if ($NetworkEndpointPacketCaptureCheckBox.Checked)              { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchRemoteIPAddressCheckbox.checked)    { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchRemotePortCheckbox.checked)         { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchLocalPortCheckbox.checked)          { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchProcessCheckbox.checked)            { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchDNSCacheCheckbox.checked)           { $script:TreeeViewCommandsCount++ }
        if ($FileSearchDirectoryListingCheckbox.Checked)                { $script:TreeeViewCommandsCount++ }
        if ($FileSearchFileSearchCheckbox.Checked)                      { $script:TreeeViewCommandsCount++ }
        if ($FileSearchAlternateDataStreamCheckbox.Checked)             { $script:TreeeViewCommandsCount++ }
        if ($SysinternalsSysmonCheckbox.Checked)                        { $script:TreeeViewCommandsCount++ }
        if ($SysinternalsAutorunsCheckbox.Checked)                      { $script:TreeeViewCommandsCount++ }
        if ($SysinternalsProcessMonitorCheckbox.Checked)                { $script:TreeeViewCommandsCount++ }
        if ($ExeScriptUserSpecifiedExecutableAndScriptCheckbox.checked) { $script:TreeeViewCommandsCount++ }
    }


    # Updates the color of the button if there is at least one query and endpoint selected
    if ($script:TreeeViewCommandsCount -gt 0 -and $script:TreeeViewComputerListCount -gt 0) {
        $script:ComputerListExecuteButton.Enabled   = $true
        $script:ComputerListExecuteButton.forecolor = 'Black'
        $script:ComputerListExecuteButton.backcolor = 'lightgreen'
    }
    else {
        $script:ComputerListExecuteButton.Enabled   = $false
        CommonButtonSettings -Button $script:ComputerListExecuteButton
    }
    $StatisticsRefreshButton.PerformClick()

    # Updates the color of the button if there is at least one endpoint selected
    if ($script:TreeeViewComputerListCount -gt 0) {
        $ActionsTabProcessKillerButton.forecolor = 'Black'
        $ActionsTabProcessKillerButton.backcolor = 'lightgreen'

        $ActionsTabServiceKillerButton.forecolor = 'Black'
        $ActionsTabServiceKillerButton.backcolor = 'lightgreen'

        $ActionsTabAccountLogoutButton.forecolor = 'Black'
        $ActionsTabAccountLogoutButton.backcolor = 'lightgreen'

        $ActionsTabSelectNetworkConnectionsToKillButton.forecolor = 'Black'
        $ActionsTabSelectNetworkConnectionsToKillButton.backcolor = 'lightgreen'

        $ActionsTabQuarantineEndpointsButton.forecolor = 'Black'
        $ActionsTabQuarantineEndpointsButton.backcolor = 'lightgreen'
    }
    else {
        CommonButtonSettings -Button $ActionsTabProcessKillerButton
        CommonButtonSettings -Button $ActionsTabServiceKillerButton
        CommonButtonSettings -Button $ActionsTabAccountLogoutButton
        CommonButtonSettings -Button $ActionsTabSelectNetworkConnectionsToKillButton
        CommonButtonSettings -Button $ActionsTabQuarantineEndpointsButton
    }


    # Code Testing
    # [system.windows.forms.messagebox]::show("$script:TreeeViewCommandsCount -- $script:TreeeViewComputerListCount")

}


