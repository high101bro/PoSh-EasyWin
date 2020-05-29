function Conduct-NodeAction {
    param(
        $TreeView,
        [switch]$Commands,
        [switch]$ComputerList
        )
    if ($Commands)     { $script:TreeeViewCommandsCount = 0 }
    if ($ComputerList) { $script:TreeeViewComputerListCount = 0 }

    $EntryQueryHistoryChecked = 0
    #$EnsureViisible = $null

    # Resets the RPC command count each time
    if ($Commands) {$script:RpcCommandCount = 0}

    # This will return data on hosts selected/highlight, but not necessarily checked
    [System.Windows.Forms.TreeNodeCollection]$AllNodes = $TreeView
    foreach ($root in $AllNodes) { 
        $EntryNodeCheckedCountforRoot = 0
        #if ($root.Text -match 'Search Results') { $EnsureViisible = $root }
        if ($root.Checked) { 
            $Root.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
            $Root.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
            #$Root.Expand()
            foreach ($Category in $root.Nodes) { 
                #$Category.Expand()
                $Category.checked = $true
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                foreach ($Entry in $Category.nodes) {
                    if ($Commands)     { $script:TreeeViewCommandsCount += 1 }
                    if ($ComputerList) { $script:TreeeViewComputerListCount += 1 }
                    $Entry.Checked   = $True
                    $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                    $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                }          
            }
        }
        if ($root.isselected) {
            $script:rootSelected     = $root
            $script:CategorySelected = $null
            $script:EntrySelected    = $null
            Display-ContextMenu

            $script:HostQueryTreeViewSelected = ""
            $StatusListBox.Items.clear()
            $StatusListBox.Items.Add("Category:  $($root.Text)")
            $ResultsListBox.Items.Clear()
            $ResultsListBox.Items.Add("- Checkbox This Node to Execute All Commands Within")

            $Section3QueryExplorationName.Text      = "N/A"
            $Section3QueryExplorationTypeTextBox.Text      = "N/A"
            $Section3QueryExplorationWinRMPoShTextBox.Text = "N/A"
            $Section3QueryExplorationWinRMWMITextBox.Text  = "N/A"
            $Section3QueryExplorationRPCPoShTextBox.Text   = "N/A"
            $Section3QueryExplorationRPCWMITextBox.Text    = "N/A"

            $MainBottomTabControl.SelectedTab = $Section3ResultsTab
        }

        foreach ($Category in $root.Nodes) { 
            $EntryNodeCheckedCountforCategory = 0

            if ($Category.Checked) {
            #    $Category.Expand()
                if ($Category.Text -match '[\[(]rpc[)\]]' ) {
                    $script:RpcCommandCount += 1
                    if ($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                        # This brings specific tabs to the forefront/front view
                        $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
                        $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                        [system.media.systemsounds]::Exclamation.play()
                        $StatusListBox.Items.Clear()
                        $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                        $ResultsListBox.Items.Clear()
                        $ResultsListBox.Items.Add("The collection mode '$($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC protocol and has been changed to")
                        $ResultsListBox.Items.Add("'Individual Execution' which supports both RPC and WinRM, but at the cost of being slower.")
                        $CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Individual Execution'
                        $EventLogRPCRadioButton.checked         = $true
                        $ExternalProgramsRPCRadioButton.checked = $true
                    }
                }

                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)

                foreach ($Entry in $Category.nodes) {
                    if ($Commands)     { $script:TreeeViewCommandsCount += 1 }
                    if ($ComputerList) { $script:TreeeViewComputerListCount += 1 }
                    if ($Entry.Text -match '[\[(]rpc[)\]]') {
                        $script:RpcCommandCount += 1
                        if ($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                            # This brings specific tabs to the forefront/front view
                            $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
                            $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                            [system.media.systemsounds]::Exclamation.play()
                            $StatusListBox.Items.Clear()
                            $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                            $ResultsListBox.Items.Clear()
                            $ResultsListBox.Items.Add("The collection mode '$($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC protocol and has been changed to")
                            $ResultsListBox.Items.Add("'Individual Execution' which supports both RPC and WinRM, but at the cost of being slower.")
                            $CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Individual Execution'
                            $EventLogRPCRadioButton.checked         = $true
                            $ExternalProgramsRPCRadioButton.checked = $true
                        }
                    }
                    $EntryNodeCheckedCountforCategory += 1
                    $EntryNodeCheckedCountforRoot     += 1
                    $Entry.Checked   = $True
                    $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
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
                        if ($Entry.Text -match '[\[(]rpc[)\]]') {
                            $script:RpcCommandCount += 1
                            if ($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem -eq 'Session Based') {
                                # This brings specific tabs to the forefront/front view
                                $MainLeftTabControl.SelectedTab = $Section1CollectionsTab
                                $MainBottomTabControl.SelectedTab = $Section3ResultsTab

                                [system.media.systemsounds]::Exclamation.play()
                                $StatusListBox.Items.Clear()
                                $StatusListBox.Items.Add("Collection Mode Changed to: Individual Execution")
                                $ResultsListBox.Items.Clear()
                                $ResultsListBox.Items.Add("The collection mode '$($CommandTreeViewQueryMethodSelectionComboBox.SelectedItem)' does not support the RPC protocol and has been changed to")
                                $ResultsListBox.Items.Add("'Individual Execution' which supports both RPC and WinRM, but at the cost of being slower.")
                                $CommandTreeViewQueryMethodSelectionComboBox.SelectedIndex = 0 #'Individual Execution'
                                $EventLogRPCRadioButton.checked         = $true
                                $ExternalProgramsRPCRadioButton.checked = $true
                            }
                        }
                        if ($Commands)     { $script:TreeeViewCommandsCount += 1 }
                        if ($ComputerList) { $script:TreeeViewComputerListCount += 1 }
                        $EntryNodeCheckedCountforCategory += 1
                        $EntryNodeCheckedCountforRoot     += 1
                        $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                    }
                    elseif (!($Entry.checked)) { 
                        if ($CategoryCheck -eq $False) {$Category.Checked = $False}
                        $Entry.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                        $Entry.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
                    } 
                }        
                if ($EntryQueryHistoryChecked -eq 0) {
                    $Section1CommandsTab.Controls.Remove($CommandsTreeViewQueryHistoryRemovalButton)
                }
            }            
            if ($Category.isselected) { 
                $script:rootSelected     = $null
                $script:CategorySelected = $Category
                $script:EntrySelected    = $null
                Display-ContextMenu

                $script:HostQueryTreeViewSelected = ""
                $StatusListBox.Items.clear()
                $StatusListBox.Items.Add("Category:  $($Category.Text)")
                $ResultsListBox.Items.Clear()
                $ResultsListBox.Items.Add("- Checkbox This Node to Execute All Commands Within")

                $Section3QueryExplorationName.Text             = "N/A"
                $Section3QueryExplorationTypeTextBox.Text      = "N/A"
                $Section3QueryExplorationWinRMPoShTextBox.Text = "N/A"
                $Section3QueryExplorationWinRMWMITextBox.Text  = "N/A"
                $Section3QueryExplorationRPCPoShTextBox.Text   = "N/A"
                $Section3QueryExplorationRPCWMITextBox.Text    = "N/A"

                $MainBottomTabControl.SelectedTab   = $Section3ResultsTab
            }

            foreach ($Entry in $Category.nodes) { 
                $EntryNodesWithinCategory += 1

                if ($Entry.isselected) {
                    $script:rootSelected     = $null
                    $script:CategorySelected = $Category
                    $script:EntrySelected    = $Entry
                            Display-ContextMenu

                    $script:HostQueryTreeViewSelected = $Entry.Text
                    $StatusListBox.Items.clear()
                    $StatusListBox.Items.Add("$($Entry.Text)")
                    $ResultsListBox.Items.clear()
                    $ResultsListBox.Items.Add("$((($Entry.Text) -split ' -- ')[-1])")
                    if ($root.text -match 'Endpoint Commands') {
                        $Section3QueryExplorationNameTextBox.Text           = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Name                    
                        $Section3QueryExplorationTagWordsTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Type
                        $Section3QueryExplorationWinRMPoShTextBox.Text      = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_PoSh
                        $Section3QueryExplorationWinRMWMITextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_WMI
                        $Section3QueryExplorationWinRMCmdTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_Cmd
                        $Section3QueryExplorationRPCPoShTextBox.Text        = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_PoSh
                        $Section3QueryExplorationRPCWMITextBox.Text         = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WMI
                        $Section3QueryExplorationPropertiesPoshTextBox.Text = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_PoSh
                        $Section3QueryExplorationPropertiesWMITextBox.Text  = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_WMI
                        $Section3QueryExplorationWinRSWmicTextBox.Text      = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_WMIC
                        $Section3QueryExplorationWinRSCmdTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_CMD
                        $Section3QueryExplorationDescriptionTextbox.Text    = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Description
                    }
                    elseif ($root.text -match 'Active Directory Commands') {
                        $Section3QueryExplorationNameTextBox.Text           = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Name                    
                        $Section3QueryExplorationTagWordsTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Type
                        $Section3QueryExplorationWinRMPoShTextBox.Text      = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_PoSh
                        $Section3QueryExplorationWinRMWMITextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_WMI
                        $Section3QueryExplorationWinRMCmdTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_Cmd
                        $Section3QueryExplorationRPCPoShTextBox.Text        = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_PoSh
                        $Section3QueryExplorationRPCWMITextBox.Text         = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WMI
                        $Section3QueryExplorationPropertiesPoshTextBox.Text = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_PoSh
                        $Section3QueryExplorationPropertiesWMITextBox.Text  = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_WMI
                        $Section3QueryExplorationWinRSWmicTextBox.Text      = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_WMIC
                        $Section3QueryExplorationWinRSCmdTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_CMD
                        $Section3QueryExplorationDescriptionTextbox.Text    = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Description                    
                    }
                    elseif ($root.text -match 'Search Results'){
                        if ($($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Name) {
                            $Section3QueryExplorationNameTextBox.Text           = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Name                    
                            $Section3QueryExplorationTagWordsTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Type
                            $Section3QueryExplorationWinRMPoShTextBox.Text      = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_PoSh
                            $Section3QueryExplorationWinRMWMITextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_WMI
                            $Section3QueryExplorationWinRMCmdTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_Cmd
                            $Section3QueryExplorationRPCPoShTextBox.Text        = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_PoSh
                            $Section3QueryExplorationRPCWMITextBox.Text         = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WMI
                            $Section3QueryExplorationPropertiesPoshTextBox.Text = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_PoSh
                            $Section3QueryExplorationPropertiesWMITextBox.Text  = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_WMI
                            $Section3QueryExplorationWinRSWmicTextBox.Text      = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_WMIC
                            $Section3QueryExplorationWinRSCmdTextBox.Text       = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_CMD
                            $Section3QueryExplorationDescriptionTextbox.Text    = $($script:AllEndpointCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Description
                        }
                        else {
                            $Section3QueryExplorationNameTextBox.Text           = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Name                    
                            $Section3QueryExplorationTagWordsTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Type
                            $Section3QueryExplorationWinRMPoShTextBox.Text      = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_PoSh
                            $Section3QueryExplorationWinRMWMITextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_WMI
                            $Section3QueryExplorationWinRMCmdTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRM_Cmd
                            $Section3QueryExplorationRPCPoShTextBox.Text        = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_RPC_PoSh
                            $Section3QueryExplorationRPCWMITextBox.Text         = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WMI
                            $Section3QueryExplorationPropertiesPoshTextBox.Text = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_PoSh
                            $Section3QueryExplorationPropertiesWMITextBox.Text  = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Properties_WMI
                            $Section3QueryExplorationWinRSWmicTextBox.Text      = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_WMIC
                            $Section3QueryExplorationWinRSCmdTextBox.Text       = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Command_WinRS_CMD
                            $Section3QueryExplorationDescriptionTextbox.Text    = $($script:AllActiveDirectoryCommands | Where-Object {$($Entry.Text) -like "*$($_.Name)" }).Description                        
                        }
                    }
                    
                    if ($Category.text -match 'PowerShell Scripts'){
                        $Section3QueryExplorationTabPage.Controls.Remove($Section3QueryExplorationEditCheckBox) 
                        $Section3QueryExplorationTabPage.Controls.Remove($Section3QueryExplorationSaveButton) 
                        $Section3QueryExplorationTabPage.Controls.Add($Section3QueryExplorationViewScriptButton) 
                    }
                    else { 
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
                            $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                            $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                            $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
                            $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                            $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
                        }
                        if (!($entry.checked)) {
                            $Entry.NodeFont     = New-Object System.Drawing.Font("$Font",10,1,1,1)
                            $Entry.ForeColor    = [System.Drawing.Color]::FromArgb(0,0,0,0)
                        }
                    }
                }
            }
            if ($EntryNodeCheckedCountforCategory -gt 0) {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Category.NodeFont  = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Category.ForeColor = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
            if ($EntryNodeCheckedCountforRoot -gt 0) {
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,224)
            }
            else {
                $Root.NodeFont      = New-Object System.Drawing.Font("$Font",10,1,1,1)
                $Root.ForeColor     = [System.Drawing.Color]::FromArgb(0,0,0,0)
            }
        }
    }
    #$EnsureViisible.EnsureVisible()
 
    # Note: If adding new checkboxes to other areas, make sure also add it to the script handler
    if ($Commands) {
        if ($RegistrySearchCheckbox.checked)                         { $script:TreeeViewCommandsCount++ }
        if ($EventLogsEventIDsManualEntryCheckbox.Checked)           { $script:TreeeViewCommandsCount++ }
        if ($EventLogsEventIDsToMonitorCheckbox.Checked)             { $script:TreeeViewCommandsCount++ }
        if ($EventLogsQuickPickSelectionCheckbox.Checked)            { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchRemoteIPAddressCheckbox.checked) { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchRemotePortCheckbox.checked)      { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchLocalPortCheckbox.checked)       { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchProcessCheckbox.checked)         { $script:TreeeViewCommandsCount++ }
        if ($NetworkConnectionSearchDNSCacheCheckbox.checked)        { $script:TreeeViewCommandsCount++ }
        if ($FileSearchDirectoryListingCheckbox.Checked)             { $script:TreeeViewCommandsCount++ }
        if ($FileSearchFileSearchCheckbox.Checked)                   { $script:TreeeViewCommandsCount++ }
        if ($FileSearchAlternateDataStreamCheckbox.Checked)          { $script:TreeeViewCommandsCount++ }
        if ($SysinternalsSysmonCheckbox.Checked)                     { $script:TreeeViewCommandsCount++ }
        if ($SysinternalsAutorunsCheckbox.Checked)                   { $script:TreeeViewCommandsCount++ }
        if ($SysinternalsProcessMonitorCheckbox.Checked)             { $script:TreeeViewCommandsCount++ }
    }
    # Updates the color of the button if there is at least one query and endpoint selected
    if ($script:TreeeViewCommandsCount -gt 0 -and $script:TreeeViewComputerListCount -gt 0) { 
        $ComputerListExecuteButton.Enabled   = $true
        $ComputerListExecuteButton.forecolor = 'Black'
        $ComputerListExecuteButton.backcolor = 'lightgreen' 
    }
    else { 
        $ComputerListExecuteButton.Enabled   = $true 
        CommonButtonSettings -Button $ComputerListExecuteButton
    }
}
